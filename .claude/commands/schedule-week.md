---
description: Turn agreed priorities into calendar blocks. Ask where recurring commitments go this week. Respect scheduling preferences. Don't duplicate existing events.
---

# /schedule-week

> Read `config/stack.md`. This command uses the `calendar` role. If that role is unset or its
> tool is not connected, stop and tell the user what to connect (native MCP recommended;
> Composio as fallback; manual export as last resort), then exit. Do not assume any specific
> product.

Take the week's priorities and place them on the calendar as protected work blocks. Respect the user's scheduling constraints (loaded from `_ops-context.md`). Ask before creating; don't overwrite what is already there.

First read `.claude/commands/_ops-context.md` - especially scheduling preferences and effort tags.

## What to do

### Phase 1 - Get the priorities

If invoked after `/weekly-planning`, use the top 3 from that session.

If invoked standalone, ask: **"What are this week's priorities?"** Accept up to 3.

For each priority, ask (one question): **"How much time does [priority] need this week? Rough hours."**

### Phase 2 - Read current calendar

Using the `calendar` tool configured in `config/stack.md`, list events for the coming 7 days (Monday through Sunday). Include all event types.

If `config/stack.md` does not define `calendar`, or the tool is not connected, stop here and tell the user:

> `calendar` is not configured. Open `config/stack.md` and set `calendar` to your calendar tool (native MCP recommended; Composio as fallback). Then reconnect and rerun this command.

Identify:
- Existing meetings and commitments (don't touch)
- Any recurring personal blocks the user has flagged as hard limits in `_ops-context.md` (for example: kid duty, standing calls) - if not already on the calendar as busy events, flag them so the user can add them manually
- Any existing recurring-commitment blocks (gym, health, etc.)

### Phase 3 - Recurring personal commitments

**Always ask** before placing recurring personal blocks (gym, health, errands, or similar). Do not assume preference from a previous week. Format the prompt to match whatever the user has described in `_ops-context.md`.

Example prompt shape (adapt to whatever the user's recurring commitment is):

```
[Commitment] this week - your stated preference is [from _ops-context.md].

Where do you want it this week?
```

Wait for the user's answer before proceeding.

### Phase 4 - Propose work blocks

For each priority, propose calendar blocks based on:
- Effort of the underlying tasks (Deep/Sprint need 2-3 hr blocks; Quick/Short batch into admin)
- Available windows after carving out existing events, hard blocks, and recurring commitments
- Prefer mornings for Deep work when free
- Leave at least one unscheduled window per day for reactivity

Format the proposal:

```
## Proposed calendar for [week of Mon DD]

**Monday**
- HH:MM-HH:MM  [Recurring commitment, if placed here]
- HH:MM-HH:MM  Deep block - [Priority 1]
- HH:MM-HH:MM  [Priority 2] work
- ...

**Tuesday** [note any hard blocks from _ops-context.md]
- HH:MM-HH:MM  [Priority 1] continued
- ...

...

New events to create: N
Existing events preserved: N (unchanged)

Proceed / edit?
```

### Phase 5 - Create events

Once the user approves:

1. For each proposed block, call the calendar tool's create-event action.
2. Work blocks: transparency set to free/transparent (colleagues see availability).
3. Personal commitments: set to busy/private (opaque to others).
4. Use short, informative titles: "Deep: [project name]" not "Work".

### Phase 6 - Wrap

End with:

```
Calendar set for week of [date].
- N events created
- [Recurring commitment]: [placement]
- Unscheduled reactive windows: [list the daily windows left open]

Run /daily-checkin tomorrow morning.
```

## Don't

- Don't schedule over hard blocks defined in `_ops-context.md`. Those are firm.
- Don't place recurring personal commitments without asking where they go this week.
- Don't touch or move existing events. Propose only additions.
- Don't book every hour. Leave at least one unscheduled 1-2 hr window per day.
- Don't block evenings or weekends unless the user explicitly asked.
- Don't assume `/weekly-planning` ran. If priorities are missing, ask.
- Don't assume which calendar tool is in use. Always resolve from `config/stack.md`.
