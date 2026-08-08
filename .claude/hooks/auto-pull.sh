#!/usr/bin/env bash
# .claude/hooks/auto-pull.sh
#
# Triggered by SessionStart.
#
# 1. Sweep: commits any uncommitted working-tree changes before pulling.
#    Mobile edits arrive via Obsidian Sync as plain filesystem writes. The
#    Stop-driven commit hook never sees them, so without this sweep they drift
#    from git HEAD until some later Claude turn happens to touch the repo.
# 2. Pull: rebase + autostash from origin/main so this machine catches up to
#    commits made elsewhere (phone, web, scheduled remote agents).
# 3. Push: if the sweep left us ahead of upstream, push it back up.
#
# Failure modes mirror commit-on-stop.sh: log to .claude/sync-failures.log,
# never corrupt repo state, exit 0 so session start is never blocked.

set -e
cd "$CLAUDE_PROJECT_DIR" || exit 0

[ -d ".git" ] || exit 0
[ -f ".claude/IMPORT_IN_PROGRESS" ] && exit 0

# Bail if mid-merge or mid-rebase — user must resolve manually
if [ -f ".git/MERGE_HEAD" ] || [ -d ".git/rebase-merge" ] || [ -d ".git/rebase-apply" ]; then
  echo "auto-pull skipped: repo mid-merge/rebase, resolve manually" >&2
  exit 0
fi

# Bail if no upstream configured
if ! git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  exit 0
fi

# Sweeping, pulling and pushing this branch is right in any checkout, so those
# run unconditionally below. Anything that touches OTHER sessions' branches is
# only ever the business of a checkout that outlives sessions, and gates on
# checkout_is_shared. If the detector is missing, assume shared.
if [ -r ".claude/hooks/checkout-role.sh" ]; then
  # shellcheck disable=SC1091
  . ".claude/hooks/checkout-role.sh"
else
  checkout_is_shared() { return 0; }
fi

# Serialize against commit-on-stop.sh — both touch git. Reuse its lock dir.
# mkdir is atomic on POSIX and Git Bash. If a Stop-driven commit is already
# running, skip this session's sweep+pull; the next session catches up.
LOCK_DIR=".claude/.commit.lock.d"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  if find "$LOCK_DIR" -maxdepth 0 -mmin +10 2>/dev/null | grep -q .; then
    rmdir "$LOCK_DIR" 2>/dev/null || true
    mkdir "$LOCK_DIR" 2>/dev/null || exit 0
  else
    exit 0
  fi
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

# --- Sweep: commit uncommitted changes (e.g. mobile edits via Obsidian Sync) ---
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  git add -A 2>/dev/null || true
  if ! git diff --cached --quiet 2>/dev/null; then
    CHANGED_FILES=$(git diff --cached --name-only | head -n 5 | tr '\n' ' ')
    FILE_COUNT=$(git diff --cached --name-only | wc -l | tr -d ' ')
    if [ "$FILE_COUNT" -le 5 ]; then
      MESSAGE="auto: pre-session sweep (mobile sync) ${CHANGED_FILES}"
    else
      MESSAGE="auto: pre-session sweep (mobile sync) ${FILE_COUNT} files (${CHANGED_FILES}...)"
    fi
    MESSAGE=$(echo "$MESSAGE" | sed 's/[[:space:]]*$//')
    if ! git commit -m "$MESSAGE" --quiet; then
      mkdir -p .claude
      echo "$(date "+%Y-%m-%dT%H:%M:%S%z") auto-pull pre-session sweep commit failed" >> .claude/sync-failures.log
    fi
  fi
fi

# --- Pull with rebase + autostash. Capture failure for visibility. ---
if ! git pull --rebase --autostash --quiet 2>/dev/null; then
  # Abort any in-progress rebase to leave repo clean
  git rebase --abort 2>/dev/null || true
  mkdir -p .claude
  echo "$(date "+%Y-%m-%dT%H:%M:%S%z") auto-pull failed at session start" >> .claude/sync-failures.log
  echo "WARNING: git pull failed at session start; repo may be out of sync with origin" >&2
  echo "         see .claude/sync-failures.log" >&2
  exit 0
fi

# --- Push if the sweep left us ahead of upstream, with one rebase retry. ---
if [ -n "$(git rev-list '@{u}..HEAD' 2>/dev/null)" ]; then
  if ! git push --quiet 2>>.claude/sync-failures.log; then
    if git fetch --quiet 2>>.claude/sync-failures.log \
       && git rebase --quiet '@{u}' 2>>.claude/sync-failures.log \
       && git push --quiet 2>>.claude/sync-failures.log; then
      :
    else
      if [ -d ".git/rebase-merge" ] || [ -d ".git/rebase-apply" ]; then
        git rebase --abort 2>/dev/null || true
      fi
      echo "$(date "+%Y-%m-%dT%H:%M:%S%z") auto-pull push failed after rebase retry" >> .claude/sync-failures.log
    fi
  fi
fi

# --- Absorb stale session branches -------------------------------------------
# Primary mechanism for folding cloud/mobile Claude session branches back into
# the default branch: merge any origin/claude/* branch whose tip is older than
# 12 hours, skipping branches already merged. Self-contained git that runs at
# SessionStart — no external routine or scheduler is required for this to run.
#
# Shared-checkout only. An ephemeral sandbox works in its own throwaway clone
# on its own claude/* branch and has no business merging anyone else's.
# checkout_is_shared (sourced above from checkout-role.sh) decides which of the
# two this checkout is.
if checkout_is_shared; then
  DEFAULT_BRANCH=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
  [ -n "$DEFAULT_BRANCH" ] || DEFAULT_BRANCH=main
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  # Only from a clean, fully pushed default branch. Never stack a merge on
  # unpushed local state: discarding a failed merge would discard those
  # commits with it.
  if [ "$BRANCH" = "$DEFAULT_BRANCH" ] && [ -z "$(git rev-list '@{u}..HEAD' 2>/dev/null)" ]; then
    NOW=$(date +%s)
    SESSION_REFS=$(git for-each-ref --format='%(refname:short)' 'refs/remotes/origin/claude/*' 2>/dev/null || true)
    for REF in $SESSION_REFS; do
      # Already merged: skip. Keeps this idempotent across sessions.
      if git merge-base --is-ancestor "$REF" "$DEFAULT_BRANCH" 2>/dev/null; then
        continue
      fi
      # Tip younger than 12h: may belong to an in-flight cloud/mobile session.
      TIP=$(git log -1 --format=%ct "$REF" 2>/dev/null || echo "$NOW")
      if [ $((NOW - TIP)) -lt 43200 ]; then
        continue
      fi
      if ! git merge --no-edit --quiet "$REF" 2>/dev/null; then
        git merge --abort 2>/dev/null || true
        echo "$(date "+%Y-%m-%dT%H:%M:%S%z") auto-pull: $REF did not merge cleanly, left in place" >> .claude/sync-failures.log
        continue
      fi
      # Push straight away. On failure (a concurrent push, say) drop only the
      # local merge commit and stop: the branch is untouched on the remote, so
      # the next session retries. Never fetch+rebase here, that would flatten
      # the merge commit.
      if git push --quiet origin "$DEFAULT_BRANCH" 2>>.claude/sync-failures.log; then
        echo "auto-pull: absorbed $REF into $DEFAULT_BRANCH" >&2
      else
        git reset --keep '@{u}' 2>/dev/null || true
        echo "$(date "+%Y-%m-%dT%H:%M:%S%z") auto-pull: push failed after merging $REF, merge discarded, retry next session" >> .claude/sync-failures.log
        break
      fi
    done
  fi
fi

exit 0
