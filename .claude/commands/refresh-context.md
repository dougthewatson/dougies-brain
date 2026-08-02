---
description: Refresh CLAUDE.md files for Areas touched by recent work
argument-hint: [area-name | --since=7d]
---

# /refresh-context

Read `config/stack.md`. This command is structural (vault-only) and does not require an external tool role. If the vault root is not set, stop and tell the user to set `vault_root` in `config/stack.md` (running `/setup` fills it automatically), then exit.

You're refreshing the CLAUDE.md files for Areas where recent work has drifted away from what the CLAUDE.md currently says. The goal is to keep each Area's context accurate so future sessions start with the right picture, not to rewrite everything.

This command acts first and reports after, per the review-and-revert principle. Apply evidenced edits directly, then show what changed so the user can correct anything that came out wrong. Every edit lands in the end-of-turn commit, so one `git revert` undoes the whole pass. Two things still stop for input: an uncertain change, and a section removal (see Decision rules).

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

Ignore cosmetic drift. Don't make edits for phrasing preferences, reordering sections, or polishing language.

### Phase 4: Apply updates

For each Area with real drift, apply the edits directly, under these rules:

- **Evidence rule.** Only write facts directly evidenced in vault files or git history. Never infer status, sentiment, or outcomes from absence of activity or from tone. If a change is plausible but not directly evidenced, ask instead of writing (see Decision rules).
- **Surgical edits only.** Replace the stale fact in place. Never rewrite sections that haven't drifted. Deleting a whole section is not surgical: that removes context the user may rely on, so ask first.
- **Additive default.** New entities, newly opened or resolved decisions, status updates: write them. They are revertible.

Then report per Area, in this format:

```
## [Area Name]: CLAUDE.md updated

1. [Section name]: [one-line summary of the edit]
   - [- old line]
   + [+ new line]

2. [Section name]: [one-line summary]
   [diff]
```

The diff is the recap. If anything came out wrong, the user says so and it gets fixed in the same session.

### Phase 5: Wrap-up

End with a short summary:

```
Context refresh complete.
- Areas reviewed: [list]
- Areas updated: [list with edit counts]
- Areas unchanged: [list]
- Undo: git revert the end-of-turn commit to unwind the whole pass.
```

The auto-commit hook will handle the commit. Don't commit manually.

## Decision rules

- **Nothing changed in an Area?** Don't mention it beyond listing it as "unchanged" in the wrap-up.
- **Change is uncertain?** Ask a single clarifying question before writing it. Don't make assumptions about status. This is a judgment call the system can't settle from evidence.
- **A section looks like it should be removed?** Ask first. Updating in place and adding are the act-first moves; removal is an overwrite of context the user may rely on.
- **Area has no CLAUDE.md yet?** Create one if the Area has meaningful structure, and say so in the report. Don't generate boilerplate for a thin Area.
- **Root CLAUDE.md drift?** Out of scope for this command. The root CLAUDE.md changes rarely and deliberately. If you notice drift there, flag it in the wrap-up but don't edit it.

## Don't

- Don't rewrite sections that haven't drifted, even if the wording could be improved
- Don't write edits based solely on commit messages, read the actual file changes
- Don't delete sections, or whole files, without asking first
- Don't update `_index.md` files during this command (that's the auto-index hook's job, or `/weekly-review`)
- Don't process the Inbox or archive projects during this command
- Don't add new sections to CLAUDE.md unless recent work clearly requires a new category (first advisor, first vendor, etc.)
- Don't recap what you changed at length. The diff is the recap.
