#!/usr/bin/env bash
# .claude/hooks/commit-on-stop.sh
#
# Triggered by Stop (once per Claude turn).
# If the .dirty marker exists (set by mark-dirty.sh on any Write|Edit|MultiEdit),
# stages everything, commits with an auto-generated message, and pushes — all
# under a flock so concurrent Stops can't race.
#
# Why one commit per turn instead of one per edit: a single Claude response can
# touch 5+ files. The old per-edit hook produced 5 commits and 5 racing
# background pushes. This produces 1 commit and 1 push, with no races.
#
# Failure modes:
#   - Push rejected → fetch + rebase + push (one retry)
#   - Still failing → log to .claude/sync-failures.log (gitignored), leave
#     .dirty marker in place so the next Stop retries
#   - Mid-merge / mid-rebase → exit cleanly, do not corrupt state
#
# To disable: rename this file or remove its entry from .claude/settings.json

set -e

cd "$CLAUDE_PROJECT_DIR" || exit 0

# No marker → nothing to commit this turn → exit instantly
[ -f ".claude/.dirty" ] || exit 0

# Bail if not a git repo
[ -d ".git" ] || exit 0

# Bail out if disabled by sentinel — a bulk import or an external agent can
# own its own commits this way. Both sentinels are gitignored, so a disable
# state can never propagate to other machines via git.
[ -f ".claude/IMPORT_IN_PROGRESS" ] && exit 0
[ -f ".claude/.no-autocommit" ] && exit 0

# Bail out for automation that owns its own commits (e.g. a scheduled cloud
# routine committing under its own prefix). Keyed on git config rather than a
# sentinel file: a sandbox that rejects writes into .claude/ cannot create a
# sentinel, and a routine whose first mandated action is a rejected write dies
# on a cosmetic step. Reading git config needs no filesystem write.
[ "$(git config claudeHooks.autocommit 2>/dev/null)" = "off" ] && exit 0

# Bail if mid-merge or mid-rebase to avoid corrupting state
if [ -f ".git/MERGE_HEAD" ] || [ -d ".git/rebase-merge" ] || [ -d ".git/rebase-apply" ]; then
  exit 0
fi

# Lock so concurrent Stops (e.g. subagent + parent, or two open sessions)
# serialize. mkdir is atomic on POSIX and Windows/Git Bash — flock isn't
# available on Git Bash. If another commit is already running, exit silently;
# the .dirty marker stays in place so the next Stop will pick up our changes.
LOCK_DIR=".claude/.commit.lock.d"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  # Stale-lock recovery: if the lock directory is older than 10 minutes,
  # something crashed without cleaning up. Force-remove and retry once.
  if find "$LOCK_DIR" -maxdepth 0 -mmin +10 2>/dev/null | grep -q .; then
    rmdir "$LOCK_DIR" 2>/dev/null || true
    mkdir "$LOCK_DIR" 2>/dev/null || exit 0
  else
    exit 0
  fi
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

# --- Branch-drift guard --------------------------------------------------
# A resumed cloud/mobile session can leave a shared checkout on a claude/*
# branch mid-session, after SessionStart's ensure-main.sh has already run. If
# we are on one now, return the checkout to the default branch (sweeping any
# changes onto the session branch first so nothing is lost), then continue the
# commit there. We already hold the shared lock, so do this inline rather than
# calling ensure-main.sh (which would deadlock trying to re-acquire it).
#
# Inside an ephemeral sandbox that same branch is the one the task harness
# assigned, so the guard stands down and the stage/commit/push below just runs
# on it. checkout-role.sh decides which of the two this checkout is; its header
# explains why the test is provenance and not the operating system. If the
# detector is missing, assume shared so the guard stays on.
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
if [ -r ".claude/hooks/checkout-role.sh" ]; then
  # shellcheck disable=SC1091
  . ".claude/hooks/checkout-role.sh"
else
  checkout_is_shared() { return 0; }
fi
case "$BRANCH" in
  claude/*)
    if checkout_is_shared; then
      DEFAULT_BRANCH=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
      [ -n "$DEFAULT_BRANCH" ] || DEFAULT_BRANCH=main
      if git rev-parse --verify --quiet "$DEFAULT_BRANCH" >/dev/null; then
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
          git add -A 2>/dev/null || true
          git commit -m "auto: sweep before returning checkout to $DEFAULT_BRANCH" --quiet 2>/dev/null || true
        fi
        if git checkout "$DEFAULT_BRANCH" --quiet 2>/dev/null; then
          if git merge --no-edit --quiet "$BRANCH" 2>/dev/null; then
            git push origin "$DEFAULT_BRANCH" --quiet 2>/dev/null || true
            git branch -D "$BRANCH" --quiet 2>/dev/null || true
            echo "commit-on-stop: checkout was on $BRANCH; merged into $DEFAULT_BRANCH and restored it" >&2
          else
            git merge --abort 2>/dev/null || true
            echo "$(date "+%Y-%m-%dT%H:%M:%S%z") commit-on-stop: $BRANCH did not merge cleanly, left in place" >> .claude/sync-failures.log
            echo "WARNING: commit-on-stop: $BRANCH did not merge cleanly; restored $DEFAULT_BRANCH, branch left in place" >&2
          fi
        fi
      fi
    fi
    ;;
esac
# ------------------------------------------------------------------------

# Stage everything
git add -A

# If nothing actually staged (e.g. only ignored files were touched), clear
# the marker and exit — but first retry the push if an earlier turn's commit
# never made it upstream (e.g. the machine was offline).
if git diff --cached --quiet; then
  if [ -n "$(git rev-list '@{u}..HEAD' 2>/dev/null)" ]; then
    git push --quiet 2>>.claude/sync-failures.log || true
  fi
  rm -f .claude/.dirty
  exit 0
fi

# Build a concise commit message from changed file paths (max 5 listed)
CHANGED_FILES=$(git diff --cached --name-only | head -n 5 | tr '\n' ' ')
FILE_COUNT=$(git diff --cached --name-only | wc -l | tr -d ' ')

if [ "$FILE_COUNT" -le 5 ]; then
  MESSAGE="auto: update ${CHANGED_FILES}"
else
  MESSAGE="auto: update ${FILE_COUNT} files (${CHANGED_FILES}...)"
fi

# Trim trailing whitespace
MESSAGE=$(echo "$MESSAGE" | sed 's/[[:space:]]*$//')

git commit -m "$MESSAGE" --quiet || true

# Push the branch we are actually on. A branch the task harness created for this
# session has no upstream on its first turn, and a bare `git push` cannot make
# one, so fall back to `-u origin HEAD`, which pushes and sets the tracking ref
# in one go. Where an upstream already exists, use it: `push origin HEAD` would
# open a second remote branch on a checkout whose local and upstream names
# differ. `origin` matches the remote the rest of these hooks assume.
push_current_branch() {
  if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
    git push --quiet 2>>.claude/sync-failures.log
  else
    git push -u origin HEAD --quiet 2>>.claude/sync-failures.log
  fi
}

# Try push, with one retry on rejection.
if push_current_branch; then
  rm -f .claude/.dirty
  exit 0
fi

# Retry against whatever this branch actually tracks, never a hardcoded
# origin/main: on a session branch that would replay the branch's work onto the
# default branch.
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)
if [ -n "$UPSTREAM" ]; then
  if git fetch --quiet 2>>.claude/sync-failures.log \
     && git rebase --quiet "$UPSTREAM" 2>>.claude/sync-failures.log \
     && push_current_branch; then
    rm -f .claude/.dirty
    exit 0
  fi
else
  # No upstream at all, so the first push of a fresh branch failed and there is
  # nothing to rebase onto. Try once more to create it.
  if push_current_branch; then
    rm -f .claude/.dirty
    exit 0
  fi
fi

# Final failure: clean up any in-progress rebase, log it. Leave .dirty in
# place so the next Stop retries the push.
if [ -d ".git/rebase-merge" ] || [ -d ".git/rebase-apply" ]; then
  git rebase --abort 2>/dev/null || true
fi
echo "$(date "+%Y-%m-%dT%H:%M:%S%z") commit-on-stop push failed after rebase retry" >> .claude/sync-failures.log

exit 0
