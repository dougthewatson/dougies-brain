---
description: A weekly operating pass. Monday morning works well, but run it on whatever day starts your week. Reviews any pending distill proposal, sweeps the past week of Claude Code chats for unfiled synthesis via /file-this --batch, runs /weekly-review, then the cross-system pass: last week's wins, carry-forward, cross-area view, top 3 priorities, notes dashboard update.
---

# /weekly-planning

> Read `config/stack.md`. This command uses the `task_manager`, `notes_dashboard`, and `calendar` roles. If any of those roles are unset or their tools are not connected, stop and tell the user what to connect and how (native MCP, Composio, or manual), then exit. Do not assume any specific product.

A weekly operating pass. Monday morning works well, but run it on whatever day starts your week. First handle vault maintenance (Phase 0: review any pending distill proposal, sweep the past week of Claude Code chats via `/file-this --batch`, then run `/weekly-review`), then pull across your task manager, notes dashboard, and calendar to set the week. End with calendar blocking via `/schedule-week`.

Keep it fast. Long planning ceremonies kill momentum.

First read `.claude/commands/_ops-context.md` for area routing and scheduling preferences.

## Config contract

Load `config/stack.md` before doing anything. Extract:

- `task_manager`: where tasks live (Asana, Linear, Todoist, etc.)
- `notes_dashboard`: where the live priorities board lives (Notion, Obsidian, etc.)
- `calendar`: which calendar system to read and write (Google Calendar, Outlook, etc.)

If any role key is missing or set to `none`:

```
[role] is not configured. To use /weekly-planning you need to connect a [role].

Options:
  - Native MCP: search for an MCP server for your tool and add it via `claude mcp add`
  - Composio: run /setup and choose your tool under the [role] category
  - Manual: skip this phase and fill in the relevant section by hand

Set [role] in config/stack.md and re-run, or type "skip [role]" to proceed without it.
```

Do not proceed past the missing role without user acknowledgement.

## What to do

### Phase 0: Vault maintenance

**Step 0a: Pending distill proposal.** Check `0-Inbox/` for any `_distill-pending-*.md` file (a scheduled distill may write one). If one exists, surface it before anything else and run `/distill --review` to walk the user through it. The review command applies approvals, then archives the pending file to `0-Inbox/archive/distill-history/`. If no pending proposal exists, skip this step silently.

**Step 0b: Weekly file-this sweep.** Run `/file-this --batch --since=7d`. This scans the past week of Claude Code session transcripts for substantive synthesis (decisions, frameworks, comparisons, plans) that emerged in chat but was never filed as vault notes. Walk the user through proposals interactively and apply approvals. The skill is conservative; most candidates surface as "skip" for operational chats or trivial Q&A.

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

Accept / swap / rewrite?
```

Wait for the user's response. Apply edits before moving to Phase 6.

### Phase 6: Publish to notes dashboard

Once the user accepts the top 3:

1. Read the `notes_dashboard` role from `config/stack.md` to find the target page or section.
2. Update the "Weekly focus" section (or create it if missing) with the top 3 priorities and today's date.
3. Use whatever write/update operation the configured `notes_dashboard` tool supports.

If `notes_dashboard` is unset, skip this step and tell the user: "No notes dashboard configured. Update your priorities board manually, or set `notes_dashboard` in `config/stack.md`."

### Phase 7: Save record to vault

Write the full plan to `0-Inbox/YYYY-MM-DD-weekly-plan.md` covering last week's wins, carry-forward, cross-area table, flags, and top 3.

### Phase 8: Hand off to scheduling

End with:

```
Plan set.
- Top 3 on the notes dashboard
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