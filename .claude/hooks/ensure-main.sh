#!/usr/bin/env bash
# .claude/hooks/ensure-main.sh
#
# Triggered by SessionStart, before auto-pull.sh.
#
# Guard against session-branch hijacking: resuming a cloud/mobile Claude session
# on the desktop checks out its claude/* session branch in this shared working
# copy. Every desktop session shares the checkout, and commit-on-stop.sh pushes
# whatever branch is checked out, so all desktop commits silently divert to the
# session branch. The invariant is: the working copy stays on the default branch.
#
# If we find ourselves on a claude/* branch: sweep uncommitted changes onto it
# (nothing is ever lost), switch to the default branch, merge the session branch
# (clean merges only; a conflict leaves the default branch untouched and the
# session branch in place), push, and drop the local branch pointer.
#
# Note: this only fires at SessionStart. commit-on-stop.sh carries the same
# guard at commit time, which catches drift that happens mid-session (a resume
# after SessionStart has already run). Both are needed.

set -e
cd "$CLAUDE_PROJECT_DIR" || exit 0
[ -d .git ] || exit 0
[ -f ".claude/IMPORT_IN_PROGRESS" ] && exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
case "$BRANCH" in claude/*) ;; *) exit 0 ;; esac

# Mid-merge or mid-rebase: user must resolve manually, don't touch
if [ -f ".git/MERGE_HEAD" ] || [ -d ".git/rebase-merge" ] || [ -d ".git/rebase-apply" ]; then
  exit 0
fi

# Resolve the default branch rather than assuming "main" — a user's repo may
# be on master or something else. Fall back to main if origin/HEAD isn't set.
DEFAULT_BRANCH=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
[ -n "$DEFAULT_BRANCH" ] || DEFAULT_BRANCH=main
# If the resolved branch doesn't exist locally, there is nothing safe to do.
git rev-parse --verify --quiet "$DEFAULT_BRANCH" >/dev/null || exit 0

# Serialize against the other git hooks via their shared lock
LOCK_DIR=".claude/.commit.lock.d"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

# Sweep uncommitted changes onto the session branch so the merge carries them
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  git add -A 2>/dev/null || true
  git commit -m "auto: sweep before returning checkout to $DEFAULT_BRANCH" --quiet 2>/dev/null || true
fi

git checkout "$DEFAULT_BRANCH" --quiet 2>/dev/null || exit 0
if git merge --no-edit --quiet "$BRANCH" 2>/dev/null; then
  git push origin "$DEFAULT_BRANCH" --quiet 2>/dev/null || true
  # -D not -d: the sweep commit may not be on the branch's upstream, which
  # makes -d refuse. We only get here after the merge succeeded, so nothing
  # is lost.
  git branch -D "$BRANCH" --quiet 2>/dev/null || true
  echo "ensure-main: checkout was on $BRANCH; merged it into $DEFAULT_BRANCH and restored the checkout" >&2
else
  git merge --abort 2>/dev/null || true
  mkdir -p .claude
  echo "$(date -Iseconds) ensure-main: $BRANCH did not merge cleanly, left in place" >> .claude/sync-failures.log
  echo "WARNING: ensure-main: $BRANCH did not merge cleanly; checkout restored to $DEFAULT_BRANCH, branch left in place" >&2
fi

exit 0
