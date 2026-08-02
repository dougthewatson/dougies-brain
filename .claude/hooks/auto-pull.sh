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

exit 0
