---
description: You talk, the assistant listens and organizes. Decisions, questions and ideas are filed in the vault, tasks go to your task manager, and a dated record is saved.
---

# /brain-dump

> Read `config/stack.md`. This command uses the `task_manager` role, and the `status_board` role only if it is set.
>
> The vault is the destination for everything this command captures. Decisions, open questions, ideas and objectives are written to vault files, always, with no external tool required. `task_manager` is the one role that changes the outcome if it is missing, because tasks are acted on outside the vault: if it is unset, say so and write the tasks into the dump record instead of publishing them. `status_board` is an optional mirror. If it is unset, publish nothing to it and do not mention it. Do not assume any specific product.

You are going to talk. The assistant's job is to listen, organize, file, then publish. Speed and accuracy matter more than polish. This is how you offload your head.

Vault filing happens directly, per the review-and-revert principle: those writes are additive and revertible via the end-of-turn commit, so they do not wait for approval. The one confirmation in this command covers only what leaves the vault (task manager, status board).

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

### Phase 3: File to vault, confirm the external publish

Write the vault pieces now, before asking anything:

1. **Vault record**: Write the full organized view to `0-Inbox/brain-dumps/YYYY-MM-DD-brain-dump.md`, unless the user has a personal Area they prefer (e.g. `1-Areas/Personal/ongoing/brain-dumps/`), in which case use that path instead. Use the date of the dump; if multiple in one day, append `-2`, `-3`. This is a 30-day rolling archive swept during weekly review.
2. **Vault notes**: one file per item, using the same paths and naming `/meeting-digest` uses, so `/distill` picks them up on its next pass. Default to `0-Inbox/` when the Area is unclear.

   | Bucket | Destination |
   |---|---|
   | Decision | `1-Areas/<Area>/ongoing/decisions/<YYYY-MM-DD>_<slug>.md` |
   | Open question | `1-Areas/<Area>/ongoing/questions/<YYYY-MM-DD>_<slug>.md` |
   | Idea / reference | `1-Areas/<Area>/ongoing/ideas/<YYYY-MM-DD>_<slug>.md` |
   | Strategic objective | `1-Areas/<Area>/ongoing/objectives/<YYYY-MM-DD>_<slug>.md` |

   This step never depends on a connected tool. It is the point of the command.

Then present the organized view in this format:

```
## Brain dump: YYYY-MM-DD

### Tasks (N)
- [ ] [Task]: [Area] · [Effort] · [Due if any]
- [ ] ...

### Strategic objectives (N)
- [Objective]: [Area]

### Ideas / references (N)
- [One-line summary] → [vault path, now filed]

### Decisions (N)
- [Decision]

### Open questions (N)
- [Question]

---

Filed to vault:
- Dump record: [path]
- N decisions, N questions, N ideas, N objectives (paths above)

About to publish outside the vault:
- N tasks to [task_manager tool from config/stack.md] [omit if unset; those tasks go into the dump record instead]
- N objectives mirrored to <status_board> [line only if the role is set]

Proceed / adjust / skip items?
```

Wait for the user's response before any external write. They may say "all good", "skip that objective", "change task 3 to Deep", "move that idea to [Area]", etc. Apply their edits, including to the already-filed vault files: correcting a filed note (moving it, retitling it, removing it at their say-so) is the review half of review-and-revert.

If there is nothing to publish externally (`task_manager` unset and `status_board` unset), skip the question entirely. Write the task list into the dump record so nothing is lost, tell the user "task_manager is not configured in config/stack.md. To enable task publishing, add your task manager tool (e.g. Asana, Todoist, Linear) to config/stack.md and connect its MCP server.", and go straight to Phase 5.

### Phase 4: Publish outside the vault

Runs only after the Phase 3 confirmation. Step 1 needs `task_manager`. Step 2 runs only if `status_board` is set.

In this order, reporting one line per destination:

1. **task_manager** (role from `config/stack.md`): Create tasks routed by area. Use effort tags where identified. Assign to self.
   - If `task_manager` is unset: tell the user "task_manager is not configured in config/stack.md. To enable this step, add your task manager tool (e.g. Asana, Todoist, Linear) to config/stack.md and connect its MCP server." Then write the task list into the dump record so nothing is lost.
2. **status_board** (optional): if the role is set, mirror the strategic objectives to it. Fetch the schema first to get property names. The files written in Phase 3 stay the source of truth; this is a copy for visibility outside the vault.
   - If `status_board` is unset: skip silently. Do not warn and do not offer to configure it. Nothing was lost, because Phase 3 already wrote the objectives to the vault.

### Phase 5: Wrap

End with:

```
Brain dump filed.
- Vault record: [path]
- Notes: N decisions, N questions, N ideas, N objectives across [area list]
- [task_manager]: N tasks across [area list]
- Inbox: N items filed to 0-Inbox/ because the Area was unclear
- [status_board]: N objectives mirrored

Done. Anything else?
```

Line rules for the wrap block above:
- The Inbox line counts items from Phase 3 that could not be routed to an Area confidently. Omit the line when that count is zero.
- If `task_manager` was unset, replace its line with "task_manager not configured, N tasks written to the dump record instead".
- Omit the status_board line entirely when the role is unset. Do not replace it with a note about connecting one.

## Don't

- Don't ask clarifying questions during listening. Capture first, clarify in Phase 2.
- Don't ask more than one confirmation question, and only about what leaves the vault.
- Don't publish outside the vault before the Phase 3 confirmation. Vault filing itself doesn't wait; it's revertible.
- Don't split one task into subtasks unless the user said so.
- Don't assign effort tags you can't infer, leave them blank.
- Don't write pretty summaries of what the user said. They just said it.
- Don't edit or polish the user's language when saving to the vault record. Verbatim is fine.
