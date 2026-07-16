---
description: Shared context for ops commands (brain-dump, daily-checkin, weekly-planning, schedule-week). Not directly invokable, referenced by other commands.
---

# Ops context

Read `config/stack.md` before using this file. This context references the `task_manager`,
`notes_dashboard`, and `calendar` roles. If any of those roles are unset or their tools are
not connected, stop and tell the user what to connect and how (native MCP, then Composio,
then manual), then exit. Do not assume any specific product. If `config/stack.md` does not exist
yet, treat every role as unset and point the user to `/setup`.

Shared reference used by the ops commands. Read this when running `/brain-dump`,
`/daily-checkin`, `/weekly-planning`, or `/schedule-week`.

## Areas and routing

Each Area in the vault maps to a work or life domain. The routing table below is a template.
Fill it in when you first run the ops commands, or ask the user to define their Areas.

| Area | Vault path | Task-manager project | Notes-dashboard page |
|---|---|---|---|
| _(example: Work Project A)_ | `1-Areas/<area-slug>/` | _(project name in your task_manager)_ | _(page/board in your notes_dashboard)_ |
| _(example: Personal)_ | `1-Areas/Personal/` | _(project name in your task_manager)_ | N/A |

Read the Area routing from `config/stack.md` if the user has defined it there. If the table
is empty, prompt the user to describe their active Areas before proceeding. Do not invent
projects or page IDs.

**How to look up IDs at runtime:**

- For `task_manager`: use the tool's API or MCP to search projects by name and resolve the
  project ID. Never hardcode IDs in this file.
- For `notes_dashboard`: use the tool's search or list API to find the relevant board or page
  by name. Never hardcode page or database IDs.

## Effort tags

Tag tasks by effort so they can be batched or time-blocked appropriately:

| Tag | Meaning | Scheduling |
|---|---|---|
| Quick | Less than 15 min, low context | Batch into admin blocks |
| Short | 15 to 45 min | Fit between meetings |
| Deep | 1 to 3 hrs focused | Protected calendar block |
| Sprint | Multi-hour push | Dedicated morning or afternoon |
| Manage | Delegation, review, decisions | Admin block or async |

When creating tasks in the `task_manager`, apply the effort tag if known. If the effort is
unclear, leave untagged and let the user sort it during planning.

## Scheduling preferences

The scheduling preferences below are defaults. The user configures their own constraints in
`config/stack.md` or states them at the start of a planning session.

**Hard blocks (configurable):**

The user defines protected time windows (recurring personal commitments, family time, etc.)
in `config/stack.md` under `schedule.hard_blocks`. If that key is unset, ask the user at
the start of `/schedule-week` before placing any blocks. Never schedule work over a hard
block without explicit approval.

**Recurring health or fitness blocks (configurable):**

If the user has a recurring fitness routine, its frequency, duration, and preferred time of
day should be set in `config/stack.md` under `schedule.fitness`. If unset, ask the user
whether to block fitness time during `/schedule-week`. Do not assume a default.

**Work style (ask the user to fill in or confirm):**

- Time-block days. Work blocks are free/transparent on the calendar. Personal commitments
  are busy/opaque.
- Deep and Sprint tasks get protected calendar time. Quick and Short tasks get batched.
- Planning sessions should be fast. No long ceremonies.
- If the user has stated a capture preference (for example: brain dumps before organizing),
  respect that and do not restructure input during capture.

To customize these defaults, the user edits `config/stack.md` under `schedule.*` keys.
If a key is missing, prompt rather than assume.

## Communication and style

Follow the Communication style section of the root `CLAUDE.md`, including any hard rules the user
added there.

- Do not fabricate data. If a tool call fails, say so and ask the user how to proceed.

## Publishing rules

- **Vault** gets the record of the session (brain dumps, weekly plans, schedules). Markdown,
  dated filename.
- **task_manager** (`config/stack.md: task_manager`) gets the tasks. If unset, list tasks in
  the vault file and tell the user to connect a task manager.
- **notes_dashboard** (`config/stack.md: notes_dashboard`) gets the strategic priorities and
  dashboard updates. If unset, write priorities to the vault and tell the user to connect a
  notes dashboard.
- **calendar** (`config/stack.md: calendar`) gets the time blocks. If unset, output a
  plain-text schedule for the user to enter manually and tell the user to connect a calendar
  tool.
- Finished deliverables go directly to their final home (a client's shared folder, an Area's
  external working folder), not the vault. The `outputs_dir` path configured in
  `config/stack.md` is the fallback when no proper home exists. This is not typically
  relevant to ops commands.
