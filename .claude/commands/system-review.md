---
description: Survey recent changes to the PKM system itself (hooks, commands, memory, settings, scheduled tasks). Use to remember what you configured this week.
argument-hint: [days, default 7]
---

# /system-review

Read `config/stack.md` for `vault_root`. User-level harness files live in the standard Claude Code user directory for your platform (`~/.claude/` on macOS and Linux, `%USERPROFILE%\.claude\` on Windows). Do not assume any other path.

You're producing a survey of recent changes to the PKM/Claude harness, not vault content. The point is to remind you what you configured this past week so you don't forget what's now active. This complements `/weekly-review` (which covers vault content).

## Argument

If a number was passed, use it as the lookback window in days. Otherwise default to **7**. The number drives the `--since` flag below and the "modified within window" filter for non-git surfaces.

## What to look at

Each phase below covers one surface. Run them in order. Keep each section short: a list, not a write-up. If a section is empty, say so and move on.

### Phase 1: Vault-tracked changes (git)

The vault (the `vault_root` path in `config/stack.md`) is git-tracked. Use it for anything inside the vault.

1. **Slash commands:** `git log --since="N days ago" --name-status -- .claude/commands/` (substitute the chosen N). List added/modified/deleted commands with the date and message.
2. **Hooks declared in vault settings:** `git log --since="N days ago" -- .claude/settings.json .claude/settings.local.json`. If the diff touched the `hooks` block, summarize what changed.
3. **CLAUDE.md edits:** `git log --since="N days ago" --name-status -- "**/CLAUDE.md"`. List which CLAUDE.md files were touched.

### Phase 2: User-level harness changes (not git-tracked)

These live in the Claude Code user directory (platform default above). Use `Get-ChildItem` (PowerShell) or `find` (Bash) with modification time filtering.

1. **`~/.claude/settings.json`**: check mtime. If modified in the window, read the file and summarize the `hooks`, `enabledPlugins`, and any new `permissions.allow` entries (count delta is fine, not a full diff). Don't dump the whole file.
2. **`~/.claude/hooks/`**: list any files modified in the window with their mtimes and a one-line description (read the first 5-10 lines of each: the leading comment if bash/Python, or the docstring if PowerShell).
3. **`~/.claude/commands/`**: if it exists, list recently-modified files.
4. **`~/.claude/skills/`**: list recently-modified skills (folder mtimes).

### Phase 3: Auto-memory changes

Memory lives in the Claude Code project memory directory for this vault. Not git-tracked.

1. List files modified in the window with mtimes.
2. For each, pull the `name` and `description` from frontmatter (one-line summary).
3. Note whether `MEMORY.md` itself was updated.

### Phase 4: Scheduled tasks (cron routines)

List scheduled routines using whatever scheduling surface this install provides (for example a
`/schedule` command, or a scheduled-agents feature in your Claude Code client). For each routine
found, report: name, schedule, last run, next run. If no such surface exists, say so and skip
this phase.

If any routine is older than the lookback window but hasn't fired recently, flag it as possibly stuck.

### Phase 5: Plugins

Read `~/.claude/settings.json` `enabledPlugins`. List what's enabled. Don't try to detect newly-enabled vs. existing: the JSON doesn't carry that history. Just give the current state for a sanity check.

### Phase 6: Summary

End with a tight digest in this format:

```
System review (last <N> days)
─────────────────────────────
Hooks:        [count] new/changed
Commands:     [count] new/changed (list names)
Memory:       [count] new/changed (list names)
Settings:     [yes/no] modified
Scheduled:    [N active routines]
Plugins:      [count enabled]

Highlights worth remembering:
- [bullet: the meaningful new thing]
- [bullet: the meaningful new thing]

Stale or worth reviewing:
- [bullet: anything that looks dormant or contradicts a newer setup]
```

Keep "Highlights" to 3-5 bullets. Pick the things you're most likely to have forgotten about, not every change.

## Don't

- Don't make changes during the review. This is read-only.
- Don't dump full file contents. Summarize.
- Don't lecture about best practices. Just report what's there.
- Don't include vault content changes (that's `/weekly-review`'s job).
- Don't ask "want me to update X?" at the end. If you want to act on something, say so.