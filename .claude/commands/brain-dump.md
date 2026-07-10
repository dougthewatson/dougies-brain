---
description: You talk, the assistant listens and organizes. Publish tasks to your task manager, priorities to your notes dashboard, save a dated record in the vault.
---

# /brain-dump

> Read `config/stack.md`. This command uses the `task_manager` and `notes_dashboard` roles. If either role is unset or its tool is not connected, stop and tell the user what to connect and how (native MCP, then Composio, then manual), then exit. Do not assume any specific product.

You are going to talk. The assistant's job is to listen, organize, confirm, then publish. Speed and accuracy matter more than polish. This is how you offload your head.

First read `.claude/commands/_ops-context.md` for area routing, effort tags, and publishing rules.

## What to do

### Phase 1: Listen

1. Say: **"Go."** That's it. No preamble.
2. Let the user talk. They may paste, type, or dictate. Don't interrupt the flow.
3. When they pause, ask **one** short question: **"Anything else?"**
4. If they say no, stop listening and move to Phase 2. If they add more, loop.

Do not interpret, classify, or respond to individual items during capture. Just collect.

### Phase 2: Organize

Sort everything into these buckets:

- **Tasks**: actionable, has an owner (usually you), can be "done"
- **Strategic objectives**: multi-week goals, shifts in direction, big bets
- **Ideas / references**: notes worth keeping but not actionable right now
- **Decisions made**: things decided out loud
- **Open questions**: things thought through but not resolved

For each **task**, identify:
- Which area (resolved from `config/stack.md` area list, or from context)
- Effort tag (Quick / Short / Deep / Sprint / Manage) if inferrable
- Due date if mentioned

For each **strategic objective**, identify the area.

### Phase 3: Confirm

Present the organized view in this format:

```
## Brain dump: YYYY-MM-DD

### Tasks (N)
- [ ] [Task]: [Area] · [Effort] · [Due if any]
- [ ] ...

### Strategic objectives (N)
- [Objective]: [Area]

### Ideas / references (N)
- [One-line summary] → [proposed vault location]

### Decisions (N)
- [Decision]

### Open questions (N)
- [Question]

---

About to publish:
- N tasks to [task_manager tool from config/stack.md]
- N objectives to [notes_dashboard tool from config/stack.md]
- N notes to vault at [paths]
- Dump record saved to 0-Inbox/brain-dumps/YYYY-MM-DD-brain-dump.md (or your personal Area if you have created one, e.g. `1-Areas/Personal/notes/brain-dumps/`)

Proceed / adjust / skip items?
```

Wait for the user's response. They may say "all good", "skip that objective", "change task 3 to Deep", etc. Apply their edits.

### Phase 4: Publish

Check `config/stack.md` for which tool fills each role. If a role is unset, skip that step and tell the user what they would need to connect in order to enable it.

In this order, reporting one line per system:

1. **Vault record**: Write the full organized view to `0-Inbox/brain-dumps/YYYY-MM-DD-brain-dump.md`, unless the user has a personal Area they prefer (e.g. `1-Areas/Personal/notes/brain-dumps/`), in which case use that path instead. Use the date of the dump; if multiple in one day, append `-2`, `-3`. This is a 30-day rolling archive swept during weekly review.
2. **task_manager** (role from `config/stack.md`): Create tasks routed by area. Use effort tags where identified. Assign to self.
   - If `task_manager` is unset: tell the user "task_manager is not configured in config/stack.md. To enable this step, add your task manager tool (e.g. Asana, Todoist, Linear) to config/stack.md and connect its MCP server."
3. **notes_dashboard** (role from `config/stack.md`): For each strategic objective, create a record in your dashboard or objectives database. Fetch the schema first to get property names.
   - If `notes_dashboard` is unset: tell the user "notes_dashboard is not configured in config/stack.md. To enable this step, add your notes/dashboard tool (e.g. Notion, Obsidian Dataview, Coda) to config/stack.md and connect its MCP server."
4. **Ideas / references**: File each to its vault destination. Default to `0-Inbox/` when the area is unclear.

### Phase 5: Wrap

End with:

```
Brain dump filed.
- Vault: [path]
- [task_manager]: N tasks across [area list]
- [notes_dashboard]: N objectives
- Inbox: N items to sort later

Done. Anything else?
```

## Don't

- Don't ask clarifying questions during listening. Capture first, clarify in Phase 2.
- Don't ask more than one confirmation question before publishing.
- Don't publish anything before Phase 3 confirmation.
- Don't split one task into subtasks unless the user said so.
- Don't assign effort tags you can't infer, leave them blank.
- Don't write pretty summaries of what the user said. They just said it.
- Don't edit or polish the user's language when saving to the vault record. Verbatim is fine.
