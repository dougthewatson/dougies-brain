# How Dougie's Brain works

The mechanics under the README. Read this if you want to know what actually happens when you use the system, or you're deciding whether to trust it with your notes. None of it is required reading to use the vault.

---

## The moving parts

Six pieces, all plain files:

| Piece | What it is |
|---|---|
| The vault | Markdown files in folders, structured as inverted PARA (`0-Inbox/`, `1-Areas/`, `2-Resources/`, `3-Archives/`) |
| `CLAUDE.md` files | Claude's operating instructions. One at the root (the contract), one per Area (local context: the people, the open threads). Claude Code loads them automatically |
| Commands | 17 slash commands in `.claude/commands/`, one markdown file each, plus one shared context file (`_ops-context.md`) they reference. A command is written instructions, readable and editable like any note |
| Hooks | Six bash scripts in `.claude/hooks/` that Claude Code runs at fixed moments: session start, after file changes, end of turn |
| `config/stack.md` | Your private wiring: which real tool plays each role (task manager, calendar, meeting source) |
| Git plus a private GitHub repo | The full history and the offsite backup. Every change lands there automatically |

There is no database, no server, and no background process. When Claude Code isn't running, the system is inert files that any editor can open.

---

## A session, start to finish

**Session start.** Three hooks fire before you type anything.

1. `ensure-main.sh` checks the vault is on `main`. A session that migrated between machines, or a cloud session that left you on its own branch, would otherwise have every later commit land somewhere you never look. This puts you back before anything writes.
2. `auto-pull.sh` first commits any stray edits sitting in the folder (changes that arrived from your phone via sync, for example), then pulls whatever other machines pushed. This machine is now current.
3. `session-briefing.sh` prints a compact briefing into Claude's context: the last week of activity, the inbox count, and any project untouched for 30+ days. Claude starts every session already oriented, without you recapping.

**While you work.** Each time Claude writes or edits a file, two more hooks fire.

4. `auto-index.sh` regenerates the touched Area's `_index.md`, so each Area's table of contents never goes stale. It only rewrites indexes it generated itself; an index you've hand-written is left alone.
5. `mark-dirty.sh` drops a marker file noting that this turn changed something. That is all it does. The expensive work is deferred to the end of the turn.

**End of turn.**

6. `commit-on-stop.sh` checks for the marker. If it's there: stage everything, build a commit message from the changed filenames, commit once, push to your private repo. If the push is rejected because another machine got there first, it pulls, replays your commit on top, and pushes again. If that still fails, it logs the error and retries on the next turn. Turns that changed nothing produce nothing.

---

## One save point per turn, end to end

Concretely: you spend a turn having Claude file three meeting notes and update a project plan. Four files change, four marker touches, one commit at the end:

```
auto: update 1-Areas/Acme/ongoing/meetings/raw/2026-07-14/kickoff.md 1-Areas/Acme/projects/rollout/plan.md ...
```

That commit is pushed to your private GitHub repo before you've finished reading Claude's reply. A month of normal use produces a few hundred of these, and you will never look at any of them. When something goes wrong, you describe it ("undo whatever happened to the rollout plan yesterday afternoon") and Claude searches the history, finds the exact commit, and reverts just that.

The fine granularity is the point. Coarse backups force a choice between keeping the mistake and losing everything since the last checkpoint. Per-turn history makes the revert surgical: one turn's damage undone, every turn after it kept. The ledger only stays this detailed because nobody human has to read it; the librarian that writes it is the one that searches it.

Reliability details, for the curious: commits serialize under a lock so two open sessions can't race each other; a sentinel file (`.claude/IMPORT_IN_PROGRESS`) pauses the whole pipeline during bulk imports; a repo mid-merge is never touched; push failures are logged to a gitignored file and retried, never silently dropped.

---

## How commands find your tools

Commands never hardcode products. `/brain-dump` publishes tasks to "your task manager." At runtime it opens `config/stack.md`, finds which real tool holds the `task_manager` role and how that tool is connected (a native connector, a generic action layer, or manual), and uses it. If a required role isn't set, the command stops and tells you what to connect instead of guessing. Switching task managers later is a one-line edit to `stack.md`; no command changes.

Roles are required or optional. `task_manager` and `calendar` are required by the commands that use them, because the work they represent happens outside the vault. `status_board` is optional and is skipped silently when blank: decisions, open questions, ideas and objectives are always written to `1-Areas/<Area>/ongoing/` as markdown first, and a status board is only ever a mirror of that. A vault with no external tools connected at all still captures everything.

---

## The meeting pipeline, mechanically

`/meeting-ingest` asks your `meeting_source` for new transcripts, dedupes against what's already filed, and routes each meeting by matching attendees against the people named in each Area's `CLAUDE.md`. Most matches wins; no confident match lands the meeting in `0-Inbox/meetings/` for you to sort. The raw transcript is written to the vault first, before anything else happens, so a downstream failure never loses the source.

`/meeting-digest` then reads each new meeting and extracts four lists: decisions (with owners), open questions, ideas worth keeping, and action items (with due dates). You approve the list once. Action items go to your task manager, decisions and ideas into the Area's notes, and every extracted item links back to the filed transcript. Six months later, "why did we decide this" has a source you can open.

---

## What `/update-system` actually does

Your vault keeps the template repo connected as a second git remote, `upstream`. `/update-system` fetches it, diffs only the system files (commands, hooks, docs, settings) against your copies, and walks you through the changes file by file. Your content is never in scope: `0-Inbox/`, `1-Areas/`, `2-Resources/`, `3-Archives/`, `config/stack.md`, and your personalized `CLAUDE.md` are untouched by design. A system file you've customized gets a side-by-side comparison rather than an overwrite.

---

## Design principles

- **Plain files over engines.** Anything that would require hosting, a database, or a daemon is out of scope. The trade is capability ceiling for zero maintenance, and it's deliberate.
- **Provenance over topic.** Files are split by who authored them, because that's what keeps citations durable. `sources/` never gets edited, so "according to your March report" still points at the real March report.
- **Gate on reversibility.** Additive, revertable changes happen automatically and are reported after the fact. Destructive or uncertain changes wait for you. Importance is a bad gate (everything feels important); reversibility is a clean one.
- **Roles over products.** The system knows about "your task manager," never about a brand. Tools change; the wiring survives.
- **One save point per turn.** Granular enough to revert surgically, batched enough to stay readable, automatic enough that you never think about it.
