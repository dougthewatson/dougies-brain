---
description: Run the weekly maintenance pass on the vault
---

# /weekly-review

Read `config/stack.md`. This command is primarily structural (vault-only). Phase 3 (open decisions) may surface items that belong in your `task_manager` or `status_board` roles. If those roles are unset, skip the push step and surface the items in chat instead. Do not assume any specific product.

You're running the weekly vault maintenance. The goal is to keep the system healthy without becoming a chore. Move efficiently, surface what matters, don't over-explain.

## What to do

Work through these phases in order. After each phase, give a one-line summary and move on. Don't pause for approval between phases unless something needs a decision.

### Phase 0: System review

Run `/system-review` (default 7-day lookback) before touching the vault. The point is to surface what was configured in the harness this past week (hooks, commands, memory files, settings, scheduled tasks) so the rest of the review happens with current context.

Surface only the "Highlights" and "Stale or worth reviewing" sections from `/system-review`'s output. Don't repeat the full digest unless asked. Then move on.

### Phase 1: Process the Inbox

1. List everything in `0-Inbox/`. If it's empty, say "Inbox is clear" and move to Phase 2.
2. For each item, determine a destination (Area + subfolder) using the same logic as `/capture`.
3. Group similar items together. If five things belong in the same Area subfolder, treat them as a batch.
4. Sort into two piles: items with a clear destination and no inbound path links, versus everything else. (Filename `[[wikilinks]]` survive a move; markdown path links break, so check for those.)
5. Move the first pile now and report the moves as a numbered list. These are routine, revertible filings. The user redirects any of them ("send 3 to [Area] instead") and they move again.
6. Ask about the second pile only: no clear Area is a judgment call, and a move that would break inbound links waits for a yes.

### Phase 2: Project staleness check

For each Area, walk the `projects/` subfolder:

1. List active projects (folders directly inside `projects/`).
2. For each, check the most recent file modification date.
3. Flag any project untouched in 30+ days.
4. For flagged projects, ask: "Still active, archive, or delete?"
5. Execute the decisions:
   - **Still active**: leave it, optionally add a note in the project's index about why it's quiet
   - **Archive**: move the project folder to that Area's `archive/` subfolder
   - **Delete**: confirm explicitly, then remove

### Phase 3: Open decisions surface

1. Search across all Area `_index.md` and `CLAUDE.md` files for explicit "Open decisions" sections or unresolved items.
2. Also grep for common patterns: "TBD", "TODO", "decide", "pending", "?? "
3. Summarize what you found in a short list.
4. Ask if any are now resolved. Update the relevant files based on the answers.
5. If a `task_manager` role is configured in `config/stack.md`, offer to push newly-surfaced open tasks there and wait for a yes before creating anything (the task manager is outside the vault). Otherwise surface them in chat.

### Phase 4: Context drift check

1. For each Area's `CLAUDE.md`, scan the recent git history (last 7 days) for that Area.
2. Identify changes that suggest the CLAUDE.md may be out of date: new vendors, new advisors, status changes, decisions made.
3. Apply the evidenced updates directly, surgical edits only, same rules as `/refresh-context`: only facts cited in vault files or git history, never rewrite sections that haven't drifted. Report each edit with a one-line diff.
4. Anything plausible but not directly evidenced becomes a question instead of an edit.

### Phase 5: Index regeneration

1. For each Area where files changed in the past week, regenerate the `_index.md`.
2. Keep indexes short: navigation, not summary. One screen max per index.
3. Show a quick diff of what changed.

### Phase 6: Wrap-up

End with a brief summary in this exact format:

```
Weekly review complete.
- Inbox: [N items processed / cleared]
- Projects archived: [list, or "none"]
- Decisions resolved: [count]
- Indexes updated: [list of Areas]
- Time elapsed: [if known]

Anything else?
```

The auto-commit hook handles the commit at the end of the turn. Do not commit manually.

## Don't

- Don't try to do everything if the review is stopped partway. Save what's done and note where you stopped; the auto-commit hook covers the rest.
- Don't reorganize folder structure during a review. That's a deliberate exercise, not a maintenance task.
- Don't add new automation, new files, or new conventions. This is maintenance, not building.
- Don't ask "are you sure?" more than once per destructive action.
- Don't generate metrics or "insights" that weren't requested. The review is about the system, not about analyzing work patterns.