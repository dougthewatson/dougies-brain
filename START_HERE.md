# START HERE

Your operating manual for this vault. Re-read it monthly, or any time the system feels off.

---

## The 30-second mental model

This vault is a folder of markdown files on your drive that Claude Code reads, writes, and reasons over. It compounds. The more you put in it, the more useful it gets.

The structure is **PARA, inverted**:

- **Areas** are top-level domains (your business, your health, a property you own, a side project). The things you actually think about.
- Inside each Area, `projects/` holds time-bounded work, `ongoing/` holds evergreen reference you author, `sources/` holds third-party material you collected, and `archive/` holds what's done.
- **Resources** at the root (`2-Resources/`) is cross-cutting reference (AI tooling notes, templates, frameworks) that applies across Areas.
- **Inbox** (`0-Inbox/`) is where everything lands before it's filed.
- **Archives** at the root (`3-Archives/`) is for whole Areas you've shut down.

Claude Code is the engine. The vault is the fuel. You are the orchestrator.

The split inside an Area is by **provenance, not topic**. Someone else authored it, so it goes in `sources/` (immutable, quotable, never edited). You authored it, so it goes in `projects/` or `ongoing/` (editable). The assistant synthesized it from those, so it goes in `_highlights.md` or an entity note (regeneratable). This is what keeps citations durable: when synthesis says "according to your March report, X," the source it points at doesn't get rewritten underneath it.

---

## Before you do anything: configure your stack

This vault talks to outside tools (a task manager, a notes or status board, a calendar, a meeting source, a transcription service, a notification channel, a finished-deliverables folder) through **roles**, not specific products. A role is a job. You pick which tool fills it.

Two files make this work:

- **`config/stack.md`** is your private wiring. It maps each role to the actual tool you use and records how that tool is connected (a native connector, a generic action layer, or manual). Every command reads this file before it runs. If a role isn't set, the command tells you what to connect instead of failing or guessing.
- **`config/stack.example.md`** is the template, with the full list of roles and recommended options for each. Copy it to `config/stack.md` and fill it in.

The fastest way to do this is to run:

```
/setup
```

`/setup` starts by asking who you are and how you like to work, and personalizes `CLAUDE.md` for you (you never edit that file by hand). Then it walks you through each role, asks what you use (or recommends an option), checks what's already connected, and writes `config/stack.md`. Run it once on first use, and again any time you switch tools.

The roles a fresh vault expects:

| Role | What it does | Used by |
|---|---|---|
| `task_manager` | Where captured tasks get published | `/brain-dump`, `/daily-checkin`, `/weekly-planning`, `/meeting-digest` |
| `notes_dashboard` | Your live priorities / status board | `/brain-dump`, `/weekly-planning`, `/distill`, `/meeting-digest` |
| `calendar` | Schedule-aware commands | `/daily-checkin`, `/schedule-week`, `/weekly-planning` |
| `meeting_source` | Where meeting transcripts and summaries come from | `/meeting-ingest` |
| `transcription` | Audio to text | `/meeting-ingest` (when you feed it raw audio) |
| `notification_channel` | Where briefings and digests get pushed | scheduled briefings, digests |
| `outputs_dir` | Fallback folder for finished deliverables that have no proper home (most exports go directly to the folder where they'll be used) | anything that exports a file |
| `sync` | How the vault moves between your machines | the sync setup itself |

You don't need all of them. A command only requires the roles it actually uses, and if one is missing it stops and tells you what to connect rather than assuming a product.

---

## The capture decision tree

When something new comes in (a thought, a meeting note, a document, a screenshot) run this:

1. **Is it urgent and actionable right now?** Handle it. Don't file it.
2. **Do you know exactly which Area and folder it belongs in?** File it there directly.
3. **Did someone else author it?** It belongs in that Area's `sources/`. If you're not sure which Area, drop it in `0-Inbox/`.
4. **Anything else** goes in `0-Inbox/`. Sort later.

Don't agonize over filing in the moment. Inbox is always safe. Sorting is a separate job. If you'd rather hand the decision off, run `/capture` and let the assistant propose a destination.

---

## The weekly rhythm

Once a week (aim for Monday morning), run:

```
/weekly-planning
```

This is the main entry point. It runs vault maintenance first (reviews any pending distill proposal, sweeps the past week of chats for unfiled synthesis, runs the vault-only `/weekly-review` pass), then a cross-Area review: last week's wins, what carries forward, your top three priorities, and an update to your notes dashboard. It ends by offering to block the week on your calendar via `/schedule-week`.

If you only want the vault pass without the cross-Area review, run `/weekly-review` directly. It:

- Processes everything in `0-Inbox/` with you
- Reviews each Area's `projects/` for staleness
- Asks about anything untouched in 30+ days
- Surfaces decisions left open
- Prompts for any context updates

If you skip a week, it's fine. If you skip a month, things start to drift.

---

## Keeping context fresh

Each Area has a `CLAUDE.md` file that Claude reads automatically when you work in that Area. It describes who the people are, what state the work is in, and what decisions are open. Over time it drifts away from reality.

Separately from the weekly review, run:

```
/refresh-context
```

This command:

- Looks at what changed in each Area over the last 7 days
- Shows you proposed edits to each Area's `CLAUDE.md`
- Applies the ones you approve

Good triggers:

- You just finished a session where status changed, a new person came in, or a decision was made or resolved
- The assistant keeps asking you the same clarifying question across sessions
- An Area's `CLAUDE.md` is more than a month old and that Area has been active

It's independent of `/weekly-review`. Run it ad-hoc, not on a schedule.

---

## Compounding the vault

`/refresh-context` keeps each Area's `CLAUDE.md` accurate. `/distill` is the second half. It mines recent activity for forward-relevant items, keeps each Area's `_highlights.md` current, grows the wikilink graph deliberately, and lints the Area for integrity issues.

```
/distill [area-name | all] [--since=Nd]
```

What it does:

- **Highlights pass.** Walks recent activity (sources, ongoing notes, projects, decisions) and proposes promotions to `_highlights.md`: decisions, frameworks, anchor facts, contacts, templates, open threads. The bar is "would I be annoyed not to find this here later."
- **Wikilink audit.** Finds entity mentions (people, companies, projects, concepts) that should have notes but don't, and proposes creating them. An optional `--backfill` converts plain-text mentions to `[[wikilinks]]` after the entity notes exist.
- **Lint pass.** Three integrity checks per Area: contradictions (facts that conflict with newer notes), orphans (old notes with no inbound links and no presence in highlights or `CLAUDE.md`), and concept gaps (topics mentioned repeatedly with no concept page).
- **Stale flag.** Surfaces files untouched 90+ days that have already been mined into `_highlights.md` (archive candidates).

Everything is interactive. It proposes, you approve, it applies. Nothing silently mutates `_highlights.md` or creates entity notes.

Good triggers:

- After a heavy ingest week (lots of new captures or imports)
- When you've kicked off or closed a project. Distill picks up the resulting decisions and entities
- Monthly minimum, even when nothing big happened. Keeps the graph healthy
- When an Area's `_highlights.md` feels stale or you can't find a recent decision

`/distill` is heavier than `/refresh-context`. Expect 5 to 30 items per active Area depending on the window. Set the cadence per Area: weekly for active ones, monthly for slower ones.

---

## Catching synthesis from chats

`/distill` mines what's already in the vault. But valuable thinking often emerges in a Claude Code chat (a worked-through decision, a comparison, a framework you developed in dialogue) and never gets filed. When the session ends, that synthesis only lives in the local session transcript on your machine.

```
/file-this              (current session)
/file-this --batch --since=7d   (sweep recent sessions)
```

What it does:

- **Default mode** scans the *current* conversation for substantive synthesis (decisions, frameworks, comparisons, plans, worked-through arguments, anchor facts) and proposes filings to the relevant Areas. Use it at the end of any chat that produced real analysis.
- **Batch mode** sweeps recent Claude Code transcripts across all sessions in the window, dedupes against the vault, and presents a consolidated walkthrough. This is what `/weekly-planning` runs so nothing falls through the cracks.

The bar is high. Most operational chats (running `/capture`, `/distill`, debugging configuration) are skipped automatically. Only synthesis you'd want to find later gets proposed.

---

## The slash command index

**Daily and weekly operations**

| Command | What it does | When to use |
|---|---|---|
| `/daily-checkin` | Morning view: today's calendar, tasks due and overdue, effort-grouped focus list, asks what changed | Start of the workday |
| `/brain-dump` | You talk, the assistant listens and organizes. Publishes tasks and priorities to your connected tools, saves a dated record in the vault | When you need to offload your head fast |
| `/weekly-planning` | Monday operating pass: vault maintenance, then cross-Area review, top-3 priorities, dashboard update, ends with `/schedule-week` | Monday mornings (the main entry point) |
| `/weekly-review` | Vault-only weekly maintenance: processes Inbox, flags stale projects, surfaces open decisions | Inside `/weekly-planning`, or standalone for just the vault pass |
| `/schedule-week` | Turns agreed priorities into protected calendar blocks. Doesn't duplicate existing events | After `/weekly-planning`, or any time you re-block the week |

**Vault maintenance and capture**

| Command | What it does | When to use |
|---|---|---|
| `/capture` | Files something into the right Area with the assistant's help | When you have something to save but don't want to think about where |
| `/file-this` | Files substantive synthesis from a chat (current session by default, or `--batch --since=Nd` to sweep recent sessions) | End of any chat that produced real analysis |
| `/refresh-context` | Proposes `CLAUDE.md` updates for Areas touched in the last 7 days | After a session that changed status, people, or decisions |
| `/distill` | Promotes forward-relevant items to `_highlights.md`, audits wikilinks, lints for contradictions, orphans, and concept gaps | Monthly minimum per Area; weekly for active Areas |
| `/focus [area]` | Loads a specific Area's context deeply | Starting focused work on one domain |
| `/archive [project]` | Moves a completed project from `projects/` to its Area's `archive/` (history preserved), sweeps wikilinks, regenerates the Area index | When a project is done and you want it out of the active set |
| `/cowork-brief [task]` | Writes a self-contained briefing file into the destination folder so a Claude Cowork session gets full context and saves its output exactly where it belongs | When handing a task to Cowork (desktop or phone) |
| `/find-solution [gap]` | Searches existing tools, skills, connectors, and packages that solve a Claude Code capability gap before falling back to building | Before concluding something doesn't exist or needs to be built |
| `/system-review [days]` | Surveys recent changes to the system itself (hooks, commands, settings, scheduled tasks). Defaults to a 7-day window | When you want to remember what you configured this week |
| `/update-system` | Pulls improvements from the upstream template into your vault's system files (commands, hooks, docs), with per-file approval. Never touches your content | When the template publishes updates you want (check its `CHANGELOG.md`) |

**Meetings**

| Command | What it does | When to use |
|---|---|---|
| `/meeting-ingest` | Pulls new meeting transcripts and summaries from your configured `meeting_source`, dedupes, files them to the right Area, then chains into digest | After a meeting just finished, or on whatever cadence you set |
| `/meeting-digest` | Extracts decisions, open questions, ideas, and action items from newly ingested meetings. Approval-gated, then routes to the vault and your connected tools | After meetings have been ingested |

More commands get added as they prove useful. If you find yourself doing the same thing twice, it's time for a new command.

---

## Meetings, briefly

Meeting content flows through three independent layers:

| Layer | Command | What it does |
|---|---|---|
| Ingest | `/meeting-ingest` | Pulls raw content from your `meeting_source`, dedupes, files it to the right Area's `ongoing/meetings/raw/<date>/` |
| Digest | `/meeting-digest` | Extracts decisions, questions, ideas, and action items per meeting. Approval-gated, routes to the vault and your connected tools |
| Distill | `/distill` | Cross-Area synthesis into `_highlights.md`. Picks up meeting folders during its sweeps |

Which tool actually serves as your `meeting_source` (and `transcription`, if you feed in audio) is set in `config/stack.md`. The commands don't assume any specific product. If a source isn't configured, ingest tells you what to connect and how.

**Routing.** Ingest reads each Area's `CLAUDE.md` people section and matches meeting attendees against it. The Area with the most matches wins. If there's no confident match, the meeting lands in `0-Inbox/meetings/<date>/` for you to sort.

---

## Automations (hooks)

Hooks fire automatically during Claude Code sessions. They live in `.claude/hooks/` and are wired in `.claude/settings.json`.

| Hook | When it fires | What it does |
|---|---|---|
| `auto-pull.sh` | Start of every session | Pulls the latest from your remote so this machine catches up to changes made elsewhere |
| `session-briefing.sh` | Start of every session | Prints a compact briefing (recent activity, inbox count, stale projects) so the assistant has situational awareness without you typing it |
| `auto-index.sh` | After every `Write`, `Edit`, or `MultiEdit` | Regenerates an Area's `_index.md` when a file in it changes (only auto-generated indexes; hand-written ones are left alone) |
| `mark-dirty.sh` | After every `Write`, `Edit`, or `MultiEdit` | Flags that the turn made changes, so the commit can be deferred to end-of-turn |
| `commit-on-stop.sh` | End of every Claude turn | If anything changed: stages, commits with an auto-generated message, and pushes |

The net effect: one commit per turn, not one per file edit. Ask for five files to change and you get one tidy commit. Chat-only turns produce no commit.

Make your vault edits through the assistant's Edit and Write tools. Raw shell redirects bypass `mark-dirty.sh` and won't get committed.

To disable any hook, rename its file (for example `commit-on-stop.sh` to `commit-on-stop.sh.off`) or remove its entry from `.claude/settings.json`. Nothing is permanent.

For bulk imports, create the file `.claude/IMPORT_IN_PROGRESS` (for example `touch .claude/IMPORT_IN_PROGRESS`) to pause auto-indexing and auto-commit while you work, and delete it when done. The hooks check for it and stand down while it exists.

---

## Handing tasks to Claude Cowork

Claude Cowork (the desktop app's Cowork tab, also available on phone) is good at producing polished deliverables, but it can't see this vault: no CLAUDE.md, no hooks, no memory. Left alone it works without context and files output wherever. The fix is a briefing file:

```
/cowork-brief [task description]
```

Run it in a Claude Code session. It picks the destination folder (where the output should actually land), distills the context Cowork needs from the vault, and writes a self-contained brief into a `_cowork/` subfolder there. It hands back two paste-ready kickoff prompts: one for desktop Cowork (connect the folder), one for phone Cowork (via a cloud-drive connector, when the destination is on a connected cloud drive).

Context flows in via the brief; the output lands in its final home. The destination folder is the only thing Cowork ever sees. Two rules:

- Don't connect the whole vault to Cowork. Scope it to the destination folder.
- If Cowork must write into the vault, know that its edits sit uncommitted until your next Claude Code session commits them, and don't run a concurrent Code session on the same files.

Briefs pile up in `_cowork/` subfolders; sweep them during weekly review.

---

## When to jump in

Signals that the system needs your hands on it:

- **Inbox has more than 20 items.** You're capturing but not processing. Run `/weekly-review`.
- **A project folder hasn't been touched in 30+ days.** Either archive it or re-engage.
- **The assistant keeps asking the same clarifying question across sessions.** The relevant `CLAUDE.md` is missing context. Run `/refresh-context`.
- **You can't find something you know is in there.** The index for that Area is stale. Regenerate it.
- **You created something in the wrong folder.** Move it. The assistant can help: "where should this actually live?"
- **The vault feels cluttered.** It probably is. Archive aggressively.
- **An Area's `_highlights.md` feels out of date.** Run `/distill [area]`.

---

## Escape hatches

**Roll back a change.** The vault is git-tracked, with one save point per working turn. Skip browsing the history yourself: describe what went wrong and when ("undo whatever happened to the pricing doc yesterday afternoon") and the assistant finds the exact save point and reverts just that, keeping everything since.

**Find something you lost.** Ask: "search the vault for anything about [topic]." It'll grep everything.

**Reset your understanding.** Ask: "explain what the vault looks like right now and what's in each Area." It'll walk the tree and summarize.

**Undo an automation.** Hooks live in `.claude/hooks/`. Rename a hook's file extension to disable it.

**A tool stopped working.** Re-run `/setup` (or edit `config/stack.md`) to re-point a role or reconnect a tool. Commands degrade gracefully: a missing role stops the command with instructions, it doesn't corrupt anything.

**Nuclear option.** The vault is on your local drive and, if you've set up the `sync` role, backed up to a remote. You can clone fresh and start over. You can't permanently break it.

---

## Where things live

| Type of thing | Lives in |
|---|---|
| Active work on a domain | `1-Areas/<Domain>/projects/<project>/` |
| Evergreen reference you author | `1-Areas/<Domain>/ongoing/` |
| Third-party material you collected | `1-Areas/<Domain>/sources/` |
| Cross-cutting reference | `2-Resources/` |
| Unfiled captures | `0-Inbox/` |
| Completed projects | `1-Areas/<Domain>/archive/` |
| Shut-down domains | `3-Archives/` |
| Finished deliverables to share | The folder where they'll actually be used (a client's shared folder, an Area's external working folder), outside the vault. Your `outputs_dir` (set in `config/stack.md`) is the fallback when nothing better exists |

Working files, drafts, and sources stay in the vault. Finished exports go straight to their final home so you never have to re-file them; `outputs_dir` catches the rest. Sources are the truth; exports are disposable.

---

## The two audiences rule

This file (`START_HERE.md`) is for **you**. Plain English, focused on the mental model and the decisions.

The `CLAUDE.md` files are for **the assistant**. Written as instructions, focused on conventions and context. They load automatically at the start of every session (the root file globally, each Area's file when you work in that Area).

Don't let them bleed together. When you notice one becoming the other, split it back apart.

---

## What this system is not

- Not a replacement for your structured database (your task tracker and status board stay where they are; the vault feeds them through roles)
- Not a replacement for your file storage (shared docs and transcripts can still live there; the vault references them)
- Not a replacement for your brain (you still decide what matters)

It's a **thinking and compounding layer** that sits alongside your other tools. Claude Code reads from the vault; your other tools feed it through whatever you wired into `config/stack.md`.

---

*Update this file when the system changes shape, not every time you add a note.*
