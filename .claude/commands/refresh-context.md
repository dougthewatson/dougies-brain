---
description: Refresh CLAUDE.md files for Areas touched by recent work
argument-hint: [area-name | --since=7d]
---

# /refresh-context

Read `config/stack.md`. This command is structural (vault-only) and does not require an external tool role. If the vault root is not set, stop and tell the user to set `vault_root` in `config/stack.md` (running `/setup` fills it automatically), then exit.

You're refreshing the CLAUDE.md files for Areas where recent work has drifted away from what the CLAUDE.md currently says. The goal is to keep each Area's context accurate so future sessions start with the right picture, not to rewrite everything.

This is interactive. Propose changes, show diffs, let the user approve each one. Don't silently edit CLAUDE.md files.

## What to do

### Phase 1: Determine scope

1. If an Area name was passed as an argument, scope to just that Area.
2. If `--since=Nd` was passed (e.g. `--since=14d`), use that window. Default is 7 days.
3. If no argument, scope to every Area touched in the last 7 days.

### Phase 2: Collect recent activity per Area

For each in-scope Area:

1. Run `git log --since="[window]" --name-only -- 1-Areas/[Area]/` to get the list of touched files.
2. Filter out auto-commit noise (index regenerations, trivial fixes). Focus on files with substantive edits.
3. Read the Area's current `CLAUDE.md` fully.
4. Read the files most likely to carry context drift:
   - New files in `projects/` or `ongoing/` that didn't exist at the last CLAUDE.md touch
   - Files with `Current state`, `Open decisions`, `Advisors`, `Vendors`, or `Status` sections
   - Anything flagged in commit messages as a decision or status change

### Phase 3: Identify drift

For each Area, compare what the CLAUDE.md says against what the recent activity suggests. Look specifically for:

- **Status changes**: project moved from planning to active, or active to stalled
- **New entities**: advisors, vendors, clients, contacts mentioned in recent notes but not in CLAUDE.md
- **Resolved decisions**: something the CLAUDE.md lists as "Open" that has been decided
- **New open decisions**: things recent notes are deliberating that aren't tracked yet
- **Scope shifts**: the Area's focus has moved (a new workstream has taken priority)
- **Stale references**: CLAUDE.md points to projects or files that have been archived or moved

Ignore cosmetic drift. Don't propose edits for phrasing preferences, reordering sections, or polishing language.

### Phase 4: Propose updates

For each Area with real drift, produce a proposal in this format:

```
## [Area Name]: proposed CLAUDE.md updates

**What's changed since the CLAUDE.md was last updated:**
- [One-line bullets of the substantive changes]

**Proposed edits:**

1. [Section name]: [one-line summary of the edit]
   Diff preview:
   - [- old line]
   + [+ new line]

2. [Section name]: [one-line summary]
   [diff preview]

Approve all / pick numbers / skip Area?
```

Wait for the user's response. Apply the edits they approve. Skip the ones they decline.

### Phase 5: Wrap-up

End with a short summary:

```
Context refresh complete.
- Areas reviewed: [list]
- Areas updated: [list with edit counts]
- Areas unchanged: [list]
```

The auto-commit hook will handle the commit. Don't commit manually.

## Decision rules

- **Nothing changed in an Area?** Don't mention it in proposals. Just list it as "unchanged" in the wrap-up.
- **Change is uncertain?** Ask a single clarifying question before proposing the edit. Don't make assumptions about status.
- **Area has no CLAUDE.md yet?** Propose creating one, but only if the Area has meaningful structure. Don't generate boilerplate.
- **Root CLAUDE.md drift?** Out of scope for this command. The root CLAUDE.md changes rarely and deliberately. If you notice drift there, flag it in the wrap-up but don't propose edits.

## Don't

- Don't edit CLAUDE.md files without showing the diff first
- Don't rewrite sections that haven't drifted, even if the wording could be improved
- Don't propose edits based solely on commit messages, read the actual file changes
- Don't update `_index.md` files during this command (that's the auto-index hook's job, or `/weekly-review`)
- Don't process the Inbox or archive projects during this command
- Don't add new sections to CLAUDE.md unless recent work clearly requires a new category (first advisor, first vendor, etc.)
- Don't recap what you changed at length. The diff is the recap.
