---
description: Morning view. Today's calendar, tasks due and overdue, effort-grouped focus list. Ask if anything changed.
---

# /daily-checkin

> Read `config/stack.md`. This command uses the `calendar` and `task_manager` roles. If either
> role is unset or its tool is not connected, stop and tell the user what to connect and how
> (native MCP first, then Composio, then manual), then exit. Do not assume any specific product.

Your morning orientation pass. Fast. Shows you what today looks like across calendar and tasks, then asks what changed.

First read `.claude/commands/_ops-context.md` for area routing and effort tags (if that file exists in your vault).

## What to do

### Phase 1: Pull data

Run these in parallel:

1. **Calendar**: use the `calendar` tool to list events for today (midnight to midnight local). Include all event types.
2. **Tasks due today or earlier**: use the `task_manager` tool to search for tasks assigned to you, not completed, due on or before tomorrow. This catches today + overdue.
3. **Recent brain dumps**: check `0-Inbox/` for files matching `*-brain-dump.md` from the last 3 days. If any are unprocessed, flag it.

### Phase 2: Organize

Group tasks by effort tag. Group calendar events by time.

### Phase 3: Present

Format exactly:

```
# Today: Day, Month D

## Calendar
- HH:MM–HH:MM  [Event title]  [attendees or location if useful]
- ...

## Tasks

**Overdue (N)**
- [Task]: [Area/Project] · [Effort] · due [date]

**Due today (N)**
- [Task]: [Area/Project] · [Effort]

**No due date but worth looking at (up to 5)**
- [Task]: [Area/Project] · [Effort]

## Grouped by effort

- **Quick** (N): [count by area/project]
- **Short** (N): [count by area/project]
- **Deep** (N): [list the actual Deep tasks (these need protected time)]
- **Sprint** (N): [list]
- **Manage** (N): [count]

## Suggested focus
[2–3 bullets: if there's a clear Deep task + open calendar block, point to it. If overdue, point to the most blocking one. Don't prescribe, suggest.]

[If unprocessed brain dump found: "Heads up: unprocessed brain dump from [date] in 0-Inbox."]

---

Anything change? New priorities, blockers, or moves?
```

### Phase 4: Respond to changes

If the user says something changed:
- **New priority** → offer to add it via the `task_manager` tool (ask which area/project if unclear).
- **Blocker** → ask if they want it captured as a task or a note.
- **Move** → if it is a calendar change, offer to update it via the `calendar` tool.

If the user says "nothing", say **"Good. Go."** and stop.

## Don't

- Don't produce an essay. Bullets only.
- Don't include completed tasks.
- Don't include events more than 1 day out, that's `/weekly-planning`.
- Don't touch email. It's out of scope for this command.
- Don't re-surface briefing content from any scheduled daily briefing. Assume the user already read it.
- Don't auto-reschedule anything without asking.
