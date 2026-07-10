---
description: Load deep context for a specific Area and brief you on current state
argument-hint: [area-name]
---

# /focus

Read `config/stack.md`. This command is structural (vault-only) and does not require an external tool role. If the vault root is not set, stop and tell the user to set `vault_root` in `config/stack.md` (running `/setup` fills it automatically), then exit.

You're loading deep context for an Area so you can start focused work. The goal is a sharp briefing, not a data dump, so you know where things stand before you start.

## What to do

1. **Identify the target Area.**
   - If you provided an Area name as an argument, use it.
   - If not, list available Areas and ask which one.
   - Match loosely: "writing", "Writing", "writ" should all resolve to `1-Areas/Writing/`.

2. **Read the Area's full context:**
   - `1-Areas/[Area]/CLAUDE.md`: load this fully
   - `1-Areas/[Area]/_index.md`: load this fully
   - List the contents of `projects/`, `ongoing/`, and `archive/` subfolders
   - Check the most recent 5-10 file modifications across the Area
   - Read any files modified in the last 7 days

3. **Check git history.** Run `git log --oneline --since="14 days ago" -- 1-Areas/[Area]/` to see what has changed recently.

4. **Produce the briefing.** Format exactly as below. Keep it under one screen.

```
# Focus: [Area Name]

## What this Area is
[One sentence from the CLAUDE.md: what it is, why it exists.]

## Current state
[2-4 bullets from the CLAUDE.md "Current state" section, refreshed with anything from recent files that changes the picture.]

## Active projects
[List each project in projects/ with: name, last-modified date, one-line status.]

## Recent activity (last 7 days)
[Bullet list of meaningful changes: new files, significant edits, decisions made. Not every commit, just the substantive ones.]

## Open decisions
[Anything flagged as unresolved in the CLAUDE.md or recent files.]

## Suggested next moves
[2-3 bullets: what the natural next pieces of work look like, based on current state. Not prescriptive (these are options, not assignments).]

---

Ready to work. What are we doing?
```

5. **Wait for direction.** After the briefing, stop. Don't start work. Don't ask follow-up questions. Just be ready.

## Tone

- Concise. This is a briefing, not a report.
- Factual. State what's there, not what you think about it.
- No filler. No "Here's a comprehensive overview of...", just the briefing.
- Match the importance of items. A vendor decision matters more than a typo fix.

## Don't

- Don't load context for Areas that weren't asked about.
- Don't summarize everything in the Area, only the recent and the active.
- Don't make recommendations beyond "Suggested next moves" (and keep those light, you decide what to do).
- Don't auto-update any files during a focus session. This is read-only context loading.
- Don't apologize for what's not in the Area or what you can't find. Just report what's there.