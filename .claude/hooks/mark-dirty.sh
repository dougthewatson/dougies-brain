#!/usr/bin/env bash
# .claude/hooks/mark-dirty.sh
#
# Triggered by PostToolUse on Write|Edit|MultiEdit.
# Touches .claude/.dirty so the Stop hook knows there are uncommitted edits
# from this turn. The actual commit + push happens in commit-on-stop.sh,
# which fires once per Claude turn instead of once per edit.
#
# This is a microsecond-cost no-op — just `touch`. The git work is deferred to
# the end of the turn so multi-edit responses produce one commit, not many.
#
# To disable: rename this file or remove its entry from .claude/settings.json

cd "$CLAUDE_PROJECT_DIR" || exit 0

# Bail if not a git repo
[ -d ".git" ] || exit 0

# Bail out if disabled by sentinel (e.g. during bulk imports)
[ -f ".claude/IMPORT_IN_PROGRESS" ] && exit 0

mkdir -p .claude
touch .claude/.dirty

exit 0
