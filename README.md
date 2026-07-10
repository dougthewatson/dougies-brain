# Dougies Brain

A personal knowledge management system built on **Claude Code** and **Obsidian**, structured as **inverted PARA**. It started as my private working vault; this repo is the same system with the personal content removed, published as a template you can clone and make your own.

The idea: your notes are plain markdown files on your disk. Claude Code reads, writes, files, and reasons over them. Obsidian gives you an editor and a graph view on the same files. A small set of git hooks keeps everything committed, pushed, and indexed without you thinking about it. Meeting transcripts go in; tracked decisions and action items come out.

This is not an app or a SaaS. It is a folder structure, a `CLAUDE.md` contract, 17 slash commands, and five hook scripts. Everything is markdown and bash you can read in an afternoon.

---

## What you get

- **A filing system that scales** (inverted PARA) from one Area to twenty without reorganizing.
- **Slash commands for the work that compounds**: capture, weekly review, distillation into highlights, context refresh, meeting ingest and digest, scheduling.
- **A meeting pipeline** that turns transcripts into structured, routed output (see below).
- **Tool-agnostic wiring.** Commands talk to your task manager, calendar, and notes board through *roles*, not hardcoded products. You wire your stack once with `/setup`.
- **Self-maintenance.** Auto-commit and auto-pull hooks version-control the vault (one commit per turn) and keep machines in step. Indexes regenerate as files move. Each session opens with a briefing of recent activity, inbox state, and stale work.
- **An update path.** The template keeps improving; `/update-system` pulls changes into your vault without touching your content.
- **Two manuals**: `START_HERE.md` written for you, `CLAUDE.md` files written for the assistant.

---

## Where it comes from

The design borrows deliberately. The filing backbone is Tiago Forte's **PARA**, inverted. The provenance model (immutable third-party sources under an LLM-maintained synthesis layer, governed by a human-written schema) follows **Andrej Karpathy's LLM-as-compiler pattern**. The "current understanding you edit, history you never rewrite" split is **Garry Tan's gbrain** compiled-truth-and-timeline idea. Update-in-place instead of duplicate, named cognitive operations, and scheduled maintenance passes come from the agent-memory ecosystem (mem0, Letta, Fabric). A survey of that landscape, with notes on what each system does well, ships in [`2-Resources/Frameworks/pkm-system-landscape-catalog.md`](2-Resources/Frameworks/pkm-system-landscape-catalog.md).

What this template adds is the combination: provenance-aware filing plus an agent that does the upkeep, in plain files you own, configurable to whatever tools you already use.

---

## The mental model

The structure is **PARA, inverted**. Areas come first because Areas are what you actually think about.

```
0-Inbox/            unfiled captures; sorted during weekly review
1-Areas/            your top-level life and work domains
  <Area>/
    CLAUDE.md       Area-specific context the assistant loads when you work here
    _index.md       auto-maintained Map of Content for the Area
    projects/       time-bounded work you author        (editable)
    ongoing/        evergreen reference you author       (editable)
    sources/        third-party material you collected   (immutable, never edited)
    archive/        completed projects and old history
2-Resources/        cross-cutting reference (templates, frameworks, tooling notes)
3-Archives/         whole Areas you have shut down
```

Two ideas do most of the work.

**Areas are domains, not topics.** A business, your health, a property, a side project. Running several things at once is exactly the load this structure is built for: each Area carries its own context file, so when you start working in one, the assistant loads who the people are, what state the work is in, and what decisions are open. Add a venture, add an Area.

**The split inside an Area is by provenance, not subject.**

- Someone else wrote it → `sources/`. Immutable and quotable. You never edit it, so citations into it stay durable.
- You wrote it (or wrote it with the assistant) → `projects/` if time-bounded, `ongoing/` if evergreen. Editable.
- The assistant synthesized it from the above → an Area `_highlights.md` or an entity note. Regeneratable.

This is the part most note systems skip. Keeping collected material separate from authored material is what lets the assistant say "according to your March report, X" and have that reference still resolve months later, because the report it points at was never rewritten underneath it.

**Inbox is always safe.** When something new arrives and you do not know where it goes, it lands in `0-Inbox/`. Filing is a separate job you do later, with help.

`START_HERE.md` is the full operating manual. Read it first.

---

## Meetings in, actions out

The pipeline I use most. `/meeting-ingest` pulls transcripts and summaries from whatever meeting source you configured, dedupes them, and files each meeting to the right Area by matching attendees against that Area's context file. `/meeting-digest` then reads each meeting and extracts:

- **Decisions** that were made, with owners
- **Open questions** raised but not resolved
- **Ideas** worth keeping
- **Action items** with owner and due date
- **Journal** notes worth holding onto

You approve the extraction (item by item or all at once), and each piece routes to where it belongs: action items to your task manager, decisions and questions to your notes dashboard, everything mirrored in the vault with a link back to the source meeting. The vault copy is written first, so if a downstream tool fails, nothing is lost.

---

## Prerequisites

- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)**. The engine that reads and writes the vault.
- **git**. The vault is a git repository; the hooks call git directly.
- **Bash.** The hooks are bash scripts. macOS and Linux have bash already. On **Windows, install [Git for Windows](https://git-scm.com/download/win)**, which ships Git Bash; the hooks run fine through it.
- **[Obsidian](https://obsidian.md/)** *(optional but recommended)*. Open the vault folder as an Obsidian vault for editing, search, and graph view. Claude Code and Obsidian read and write the same files.

No Node, no Python, no build step.

---

## Quickstart

**1. Clone the template, keep it as `upstream`, and point `origin` at your own private repo.**

Your vault will hold personal notes, so it must live in a repository **you own and keep private**. Keeping this template as `upstream` is what lets `/update-system` pull improvements later.

```bash
git clone https://github.com/dougthewatson/dougies-brain.git my-brain
cd my-brain
git remote rename origin upstream
git remote add origin https://github.com/<your-username>/<your-private-repo>.git
git push -u origin main
```

(Create the private repo on GitHub first: empty, no README. If you skip the remote setup, the vault still works locally and still commits every turn; it just has nowhere to push.)

**2. Open the vault in Claude Code** from the project root, then wire your tools:

```
/setup
```

`/setup` walks you through each role one at a time (task manager, calendar, notes dashboard, meeting source, and so on), helps you connect the ones you want, skips the ones you do not, and writes your private `config/stack.md`. Re-run with `--reconfigure` any time you switch tools.

**3. Fill in `CLAUDE.md`.** Open the root `CLAUDE.md` and complete the "Who you're working with" section, and replace the example hard rules in "Communication style" with your own. Those two sections are how the assistant calibrates to you instead of to me.

**4. Start using it.** Drop a note in `0-Inbox/`, create your first Area under `1-Areas/`, and run `/weekly-review` when you have a few things to sort. Delete `1-Areas/Example-Area/` once you have seen how it is put together.

---

## The config layer: roles, not products

Every command that reaches outside the vault (publishing a task, reading your calendar, updating a status board, ingesting a meeting) refers to a **role**, never a specific product. The mapping from role to your actual tool lives in one file:

```
config/stack.example.md   the template, with every role and recommended options   (committed)
config/stack.md           your private wiring; what /setup writes                  (gitignored)
```

The contract is strict, and it is what makes the template portable:

- **Every command opens by reading `config/stack.md`.** If a role it needs is unset or not connected, the command stops and tells you what to connect and how. It does not guess a product and it does not fail silently.
- **No command hardcodes a vendor.** Swap your task manager and you change one line.
- Only `/setup`, this README, and `config/stack.example.md` name specific tools, and only as options.

| Role | What it does |
|---|---|
| `task_manager` | where captured tasks get published |
| `notes_dashboard` | your live priorities / status board |
| `calendar` | schedule-aware commands |
| `meeting_source` | where meeting transcripts and summaries come from |
| `transcription` | audio to text |
| `notification_channel` | where briefings and digests get pushed |
| `outputs_dir` | folder for finished deliverables, outside the vault |
| `sync` | how the vault moves between your machines |

You do not need all of them. A command requires only the roles it actually uses.

**Secrets never go in `config/stack.md`** or any other vault file. Store API keys in environment variables and reference them by name.

---

## How it runs: the hooks

Five small bash scripts in `.claude/hooks/`, wired in `.claude/settings.json`, do all the plumbing:

| Hook | Fires | Does |
|---|---|---|
| `auto-pull.sh` | session start | pulls from your remote so this machine catches up to changes made elsewhere |
| `session-briefing.sh` | session start | prints a compact orientation (recent activity, inbox count, stale projects) |
| `auto-index.sh` | after Write / Edit | regenerates an Area's `_index.md` when its files change |
| `mark-dirty.sh` | after Write / Edit | flags that the turn changed something, so the commit waits until the turn ends |
| `commit-on-stop.sh` | end of every turn | if anything changed: stages, commits with an auto-generated message, pushes |

Net effect: **one commit per turn**, not one per file edit. Chat-only turns produce nothing. `settings.json` also ships safety rails: destructive commands (`rm -rf`, force-push, hard reset) prompt for confirmation, and web fetches to local and metadata addresses are denied. To disable any hook, rename its file or remove its entry from `.claude/settings.json`.

---

## Architecture

```
        you
         |  notes, slash commands
         v
   +-----------------+        reads / writes        +-------------------------+
   |   Claude Code   | <--------------------------> |   the vault (markdown)  |
   |  (the engine)   |        same files            |  0-Inbox  1-Areas       |
   +-----------------+ <----+                  +--> |  2-Resources 3-Archives |
         |                  |   same files     |    +-------------------------+
         | reads roles      |                  |                ^
         v                  |                  |                | edit / search / graph
   +-----------------+      |                  |          +-----------+
   | config/stack.md |      |                  |          | Obsidian  |  (optional)
   | (your tools)    |      |                  |          +-----------+
   +-----------------+      |  .claude/hooks/  |
         |                  |  auto-pull       |
         | resolves to      |  auto-index      |
         v                  |  mark-dirty      |
   task mgr / calendar      |  commit-on-stop -+--- git push / pull --> your PRIVATE
   notes board / etc.       |  session-brief   |                        GitHub repo
                            +------------------+                       (sync + backup)
```

---

## Staying up to date

The template keeps evolving. Changes are recorded in [`CHANGELOG.md`](CHANGELOG.md). Because your clone keeps this repo as `upstream` (Quickstart step 1), pulling improvements is one command inside your vault:

```
/update-system
```

It fetches upstream, shows you what changed and why (from the changelog), and applies only the system files you approve: commands, hooks, settings wiring, docs. Your Areas, your inbox, your private config, and your personalized `CLAUDE.md` are never touched; anything you have modified locally gets a diff and a choice, never a silent overwrite.

---

## Optional add-on: Obsidian editing skills

For richer in-vault editing (frontmatter, callouts, canvases), the **[kepano/obsidian-skills](https://github.com/kepano/obsidian-skills)** collection (MIT) pairs well with this template. Install it from its own repo per its instructions. It is not bundled here and nothing depends on it.

---

## Make it yours

This is a template, not a finished product. The expected first session:

1. Set up the remotes (Quickstart step 1).
2. Run `/setup` to wire your stack.
3. Fill in the root `CLAUDE.md`.
4. Create your real Areas and delete the sample content.
5. Read `START_HERE.md` end to end once.

Then live in it. When you find yourself doing the same thing twice, add a command. The vault should get more useful over time, not just bigger.

---

## Status and contributions

I built this for my own work and run it daily; this public version tracks what proves out in practice, so expect it to keep changing (that is what `/update-system` is for). Issues and pull requests are welcome: fixes, new commands, better fallbacks for tools I do not use. If you fork it into something different, that is the point.

Built by [Doug Watson](https://github.com/dougthewatson). MIT licensed; see [`LICENSE`](LICENSE).
