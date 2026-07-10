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

# Bail out if disabled by sentinel (e.g. during bulk imports)
[ -f ".claude/IMPORT_IN_PROGRESS" ] && exit 0

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

# Stage everything
git add -A

# If nothing actually staged (e.g. only ignored files were touched), clear
# the marker and exit.
if git diff --cached --quiet; then
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

# Try push, with one retry on rejection (rebase against origin/main)
if git push --quiet 2>>.claude/sync-failures.log; then
  rm -f .claude/.dirty
  exit 0
fi

if git fetch --quiet origin main 2>>.claude/sync-failures.log \
   && git rebase --quiet origin/main 2>>.claude/sync-failures.log \
   && git push --quiet 2>>.claude/sync-failures.log; then
  rm -f .claude/.dirty
  exit 0
fi

# Final failure: clean up any in-progress rebase, log it. Leave .dirty in
# place so the next Stop retries the push.
if [ -d ".git/rebase-merge" ] || [ -d ".git/rebase-apply" ]; then
  git rebase --abort 2>/dev/null || true
fi
echo "$(date -Iseconds) commit-on-stop push failed after rebase retry" >> .claude/sync-failures.log

exit 0
