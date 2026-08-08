#!/usr/bin/env bash
# .claude/hooks/session-briefing.sh
#
# Triggered by SessionStart.
# Prints a short situational briefing to stdout, which Claude Code adds
# to its context for the new session.
#
# Output is intentionally compact — under 30 lines, focused on:
#   - Recent vault activity (last 7 days of commits)
#   - Inbox status
#   - Stale projects (untouched in 30+ days)
#
# To disable: rename this file or remove its entry from .claude/settings.json

set -e

cd "$CLAUDE_PROJECT_DIR" || exit 0

# Bail silently if not a git repo (briefing requires git)
if [ ! -d ".git" ]; then
  exit 0
fi

echo "## Session briefing"
echo ""

# --- Recent commits (last 7 days, max 10) ---
echo "### Recent vault activity"
RECENT_COMMITS=$(git log --oneline --since="7 days ago" -n 10 2>/dev/null || true)
if [ -z "$RECENT_COMMITS" ]; then
  echo "No commits in the last 7 days."
else
  echo "$RECENT_COMMITS" | sed 's/^/- /'
fi
echo ""

# --- Unmerged session branches (cloud/mobile work not yet in main) ---
# auto-pull.sh's stale-branch absorber merges these, so anything still
# listed here slipped past it. Silent when there's nothing to say.
NOW=$(date +%s)
SESSION_REFS=$(git for-each-ref --format='%(refname:short)' 'refs/remotes/origin/claude/*' 2>/dev/null || true)
BRANCH_HEADER_PRINTED=0
for REF in $SESSION_REFS; do
  if git merge-base --is-ancestor "$REF" HEAD 2>/dev/null; then
    continue
  fi
  TIP=$(git log -1 --format=%ct "$REF" 2>/dev/null || echo "$NOW")
  AGE_DAYS=$(( (NOW - TIP) / 86400 ))
  if [ "$BRANCH_HEADER_PRINTED" -eq 0 ]; then
    echo "### Unmerged session branches"
    BRANCH_HEADER_PRINTED=1
  fi
  echo "- ${REF#origin/} (tip ${AGE_DAYS}d old)"
done
if [ "$BRANCH_HEADER_PRINTED" -eq 1 ]; then
  echo ""
fi

# --- Inbox status ---
echo "### Inbox"
INBOX_DIR="0-Inbox"
if [ -d "$INBOX_DIR" ]; then
  # Count files excluding README.md, dotfiles, and pending-distill files (counted separately below)
  INBOX_COUNT=$(find "$INBOX_DIR" -maxdepth 1 -type f ! -name "README.md" ! -name ".*" ! -name "_distill-pending-*.md" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$INBOX_COUNT" -eq 0 ]; then
    echo "Empty."
  elif [ "$INBOX_COUNT" -lt 10 ]; then
    echo "$INBOX_COUNT items."
  else
    echo "$INBOX_COUNT items — consider running /weekly-review."
  fi
else
  echo "Inbox folder not found."
fi
echo ""

# --- Pending distill proposal ---
PENDING_DISTILL=$(find "$INBOX_DIR" -maxdepth 1 -type f -name "_distill-pending-*.md" 2>/dev/null | sort | tail -1)
if [ -n "$PENDING_DISTILL" ]; then
  echo "### Pending distill proposal"
  PENDING_BASE=$(basename "$PENDING_DISTILL")
  # Try to pull a one-line summary from the file (the line under the H1)
  PENDING_SUMMARY=$(awk '/^# Distill proposal/{getline; while ($0 ~ /^[[:space:]]*$/) getline; print; exit}' "$PENDING_DISTILL" 2>/dev/null)
  if [ -n "$PENDING_SUMMARY" ]; then
    echo "${PENDING_BASE} — ${PENDING_SUMMARY}"
  else
    echo "${PENDING_BASE}"
  fi
  echo "Run \`/distill --review\` to walk through it."
  echo ""
fi

# --- Stale projects (untouched 30+ days) ---
echo "### Stale projects (30+ days untouched)"
STALE_FOUND=0
if [ -d "1-Areas" ]; then
  for AREA in 1-Areas/*/; do
    PROJECTS_DIR="${AREA}projects"
    if [ -d "$PROJECTS_DIR" ]; then
      for PROJECT in "$PROJECTS_DIR"/*/; do
        if [ -d "$PROJECT" ]; then
          # Portable staleness check: -mtime works everywhere, unlike GNU
          # find's -printf (absent on macOS/BSD). Stale = has files, but
          # none modified in the last 31 days.
          RECENT=$(find "$PROJECT" -type f ! -name ".gitkeep" -mtime -31 2>/dev/null | head -1)
          ANY=$(find "$PROJECT" -type f ! -name ".gitkeep" 2>/dev/null | head -1)
          if [ -z "$RECENT" ] && [ -n "$ANY" ]; then
            PROJECT_NAME=$(basename "$PROJECT")
            AREA_NAME=$(basename "$AREA")
            # Age label from git history; falls back to "30+" if untracked
            LAST_TS=$(git log -1 --format=%ct -- "$PROJECT" 2>/dev/null || true)
            if [ -n "$LAST_TS" ]; then
              AGE_DAYS=$(( ($(date +%s) - LAST_TS) / 86400 ))
            else
              AGE_DAYS="30+"
            fi
            echo "- ${AREA_NAME}/${PROJECT_NAME} (${AGE_DAYS} days)"
            STALE_FOUND=1
          fi
        fi
      done
    fi
  done
fi
if [ "$STALE_FOUND" -eq 0 ]; then
  echo "None."
fi
echo ""

exit 0
