---
description: A weekly operating pass. Monday morning works well, but run it on whatever day starts your week. Reviews any pending distill proposal, sweeps the past week of Claude Code chats for unfiled synthesis via /file-this --batch, runs /weekly-review, then the cross-system pass: last week's wins, carry-forward, cross-area view, top 3 priorities, status board update.
---

# /weekly-planning

> Read `config/stack.md`. This command uses the `task_manager` and `calendar` roles, but Phase 0 (vault maintenance) and Phase 7 (save the plan) are vault-only and run regardless. If a role is unset or not connected, run the vault-only phases, then stop at the first phase that needs the missing role and tell the user what to connect and how (native MCP, Composio, or manual). The `status_board` role is optional: if it is set, mirror the priorities to it, and if it is not, skip that step silently. Do not assume any specific product.

A weekly operating pass. Monday morning works well, but run it on whatever day starts your week. First handle vault maintenance (Phase 0: review any pending distill proposal, sweep the past week of Claude Code chats via `/file-this --batch`, then run `/weekly-review`), then pull across your task manager, status board, and calendar to set the week. End with calendar blocking via `/schedule-week`.

Keep it fast. Long planning ceremonies kill momentum.

First read `.claude/commands/_ops-context.md` for area routing and scheduling preferences.

## Config contract

Load `config/stack.md` before doing anything. Extract:

- `task_manager`: where tasks live (Asana, Linear, Todoist, etc.)
- `status_board`: where the live priorities board lives (Notion, Obsidian, etc.)
- `calendar`: which calendar system to read and write (Google Calendar, Outlook, etc.)

If `task_manager` or `calendar` is missing or set to `none` (`status_board` is exempt: when it is missing, skip its step silently per the header above):

```
[role] is not configured. To use /weekly-planning you need to connect a [role].

Options:
  - Native MCP: search for an MCP server for your tool and add it via `claude mcp add`
  - Composio: run /setup and choose your tool under the [role] category
  - Manual: skip this phase and fill in the relevant section by hand

Set [role] in config/stack.md and re-run, or type "skip [role]" to proceed without it.
```

Do not run a phase that needs the missing role without user acknowledgement. Phases that don't need it (Phase 0 vault maintenance, Phase 7 saving the plan) run either way; never skip vault work because an external tool is missing.

## What to do

### Phase 0: Vault maintenance

**Step 0a: Pending distill proposal.** Check `0-Inbox/` for any `_distill-pending-*.md` file (a scheduled distill may write one). If one exists, surface it before anything else and run `/distill --review` to walk the user through it. The review command applies approvals, then archives the pending file to `0-Inbox/archive/distill-history/`. If no pending proposal exists, skip this step silently.

**Step 0b: Weekly file-this sweep.** Run `/file-this --batch --since=7d`. This scans the past week of Claude Code session transcripts for substantive synthesis (decisions, frameworks, comparisons, plans) that emerged in chat but was never filed as vault notes. It files the clean candidates directly and reports them, holding only the sensitive or ambiguous ones for questions. The skill is conservative; most candidates get skipped as operational chats or trivial Q&A.

**Step 0c: Weekly review.** Run `/weekly-review` in full. Let it complete all phases (inbox, staleness, decisions, drift, index, wrap). When it wraps, continue here. Do not restart a clean session.

### Phase 1: Last week's wins

1. Query the `task_manager`: tasks completed in the last 7 days across all areas. Use whatever "completed tasks" query the tool supports (filter: completed in the last 7 days, assigned to you).
2. Group by area.
3. Present as:

```
## Last week: completed (N)

**[Area]** (N)
- [Task]
- ...

**[Area]** (N)
- ...
```

Keep it tight. Task names only, no commentary.

### Phase 2: Carry-forward and overdue

1. Query the `task_manager`: incomplete tasks with a due date before today. These are overdue.
2. Also pull incomplete tasks due in the coming 7 days.
3. Group by area. Format:

```
## Carrying in

**Overdue (N)**
- [Task] · [Area] · [Effort] · due [date]

**Due this week (N)**
- [Task] · [Area] · [Effort] · due [date]
```

### Phase 3: Cross-area view

For each active area (pull from the areas registered in `_ops-context.md` or `config/stack.md`), show:

- Open task count
- Overdue count
- Anything flagged as blocking

```
## Cross-area

| Area | Open | Overdue | Blocking |
|---|---|---|---|
| [Area] | N | N | [blocker if any] |
| [Area] | N | N | (none) |
```

### Phase 4: Overwhelm check

If any of these are true, flag it:

- Total overdue > 10
- Any single area has > 20 open tasks
- Every area has new Deep or Sprint tasks (can't do everything in one week)

Flag format:

```
## Flags
- [Observation in one line]
- ...
```

If nothing to flag, write "No overwhelm signals."

### Phase 5: Propose top 3

Based on Phases 1-4, propose three priorities for the week. Not tasks, priorities. A priority might be "Close the pilot loop on [Area]" or "Finalize Q2 positioning for [Area]."

Format:

```
## Proposed top 3 for this week

1. **[Priority]** ([Area])
   Why: [one line]
   What moves it: [1-2 tasks already in task manager, or "needs tasks created"]

2. ...

3. ...

On accept: saved to the vault, and mirrored to [status_board] (only if that role is set).

Accept / swap / rewrite?
```

Wait for the user's response. Apply edits and re-present until they accept. Only an acceptance moves to Phase 6; an edit-reply is not an acceptance.

### Phase 6: Publish to status board

Once the user accepts the top 3:

1. **Vault first.** Write the top 3 to `1-Areas/<Area>/ongoing/objectives/<YYYY-MM-DD>_week-priorities.md`, or to `0-Inbox/` if they span Areas. That file is the record and is complete on its own.
2. **Mirror second, only if `status_board` is set.** Read the role from `config/stack.md` to find the target page or section, then update the "Weekly focus" section (or create it if missing) with the top 3 priorities and today's date, using whatever write/update operation the configured tool supports. If the role is unset, skip the mirror silently.

### Phase 7: Save record to vault

Write the full plan to `0-Inbox/YYYY-MM-DD-weekly-plan.md` covering last week's wins, carry-forward, cross-area table, flags, and top 3.

### Phase 8: Hand off to scheduling

End with:

```
Plan set.
- Top 3 saved to [vault objectives path]
- Top 3 mirrored to [status_board]   [omit this line when the role is unset]
- Plan archived at 0-Inbox/[filename]

Run /schedule-week to turn this into calendar blocks?
```

If the user says yes, invoke `/schedule-week` immediately with the top 3 carried over.

## Don't

- Don't skip Phase 0. Vault maintenance comes first.
- Don't propose more than 3 priorities. If you think there are 5, pick 3 and say what you dropped.
- Don't generate metrics beyond what's asked (velocity charts, burndown, etc.).
- Don't edit tasks in the task manager during planning. This is read and decide, not execute.
- Don't touch the calendar yet. That's `/schedule-week`.
- Don't assume any specific tool name, project ID, or page ID. All routing comes from `config/stack.md` and `_ops-context.md`.