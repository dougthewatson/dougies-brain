# Dougie's Brain

**Every second brain dies the same way: you stop maintaining it. This one maintains itself, and gets smarter as you work.**

If your second brain has gone quiet, full of notes you no longer trust, or you want one but the upkeep looks like a part-time job, this is for you. The missing piece was never a better structure. It was a librarian.

Dougie's Brain makes [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that librarian. Your notes are plain text files, in folders, on your computer. Claude files them, links them, indexes them, summarizes them, and keeps its memory of you current, automatically, while you get your actual work done. Meeting transcripts go in; decisions and to-dos come out.

It's not an app (though it connects to the apps you already use), the template is free, and there's nothing to host. It's a folder you copy, with the rules and automation already written. If you can install Claude Code, you can run it.

And it's not the one true way. It's one opinionated take on the second brain: a remix of the best ideas in the field, shaped for people who'd rather use a system than build one.

---

## Who this is for

Knowledge workers. Founders, consultants, operators, researchers, writers: people who run things and think for a living.

Not coders. GitHub is full of second brains built by engineers for engineers, with databases to run and daemons to babysit. This one is for the rest of us. The most technical thing you'll do is install Claude Code; from there, Claude sets the whole thing up for you. You never have to open a terminal.

---

## Standing on giants

Dougie's Brain is built from the two best ideas anyone has had about AI and personal knowledge, packaged with one design goal: you shouldn't need to be an engineer to have this.

The first idea is Andrej Karpathy's: don't make the AI re-read your files on every question, have it maintain a living wiki that gets richer with everything you add. He published it as a [gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) and deliberately left the build as an exercise: "your agent will build out the specifics."

The second is Garry Tan's: the AI shouldn't just answer from your notes, it should *maintain* them. His [gbrain](https://github.com/garrytan/gbrain) proves it at production scale: over 146,000 pages kept current by a round-the-clock engine with its own database, knowledge graph, and job queue, built to power full AI agent stacks.

The same pattern keeps being rediscovered. In mid-2026, [LLM Wiki v2](https://gist.github.com/rohitg00/2067ab416f7bbe447c1977edaaa681e2) extended Karpathy's gist with lessons from running the pattern in production: facts should supersede each other rather than be silently rewritten, new material should be checked for contradictions on the way in, and knowledge that goes unused should surface for review. Where those ideas suit a folder of plain files, they show up here too.

Dougie's Brain packages both ideas at the other end of the spectrum: no engine. No database, no daemon, nothing to host. Karpathy's compounding wiki and Garry's AI-as-maintainer, delivered as a folder of plain files with the structure, eighteen commands, five automation scripts, and instruction files already written, running on stock Claude Code. And instead of building a new stack around your life, it wires into the one you already have: your task manager, your calendar, your meetings.

That's a different trade-off, not a better one. If you already run agent infrastructure, gbrain is the stronger engine. If you'd rather build the wiki yourself, Karpathy's gist is the place to start. This is the version for people who want to live in the result.

---

## Why you'd want it

Two kinds of people end up here. Note-keepers whose system (Notion, Obsidian, a folder of documents) worked until life got busy, the inbox rotted, and they quit. And AI users who want their assistant working from their actual knowledge, not a synthesized derivative of it. Both hit the same wall: a second brain only works if someone maintains it, and that someone was always you.

Here, Claude is the librarian:

- **You dump, it files.** Brain-dumps, meeting notes, ideas, clipped articles. Claude puts each in the right place, links it to what's already there, and keeps every index current.
- **It maintains itself while you work.** Use Claude Code like you normally would: draft the email, plan the week. Filing, indexing, and backup happen on their own at the end of every turn.
- **It compounds.** Notes get distilled into summaries you can act on. Ask a question next month and you get an answer, not a pile of old pages to re-read.
- **Your AI finally knows you.** Claude opens every session already briefed on your projects, your people, your history. That briefing is written and kept current by the system itself: `/setup` interviews you once, and from then on Claude updates its own knowledge of you as you work. Chat memory is a distillation of what happens. Instead, this is memory: not only can you open, read, and correct it, but it is complete, searchable, and referenceable over time.
- **You own everything.** Plain text files on your computer, in folders you can open and read. No cloud lock-in, nothing held hostage if you leave.
- **It joins your tools instead of replacing them.** Calendar, task manager, meeting recorder: wire in what you use, skip what you don't.

Other systems store what you write. This one remembers it, maintains it, and puts it to work the next time you need it.

---

## What you get

- **A filing structure that scales** from one area of your life to twenty without reorganizing.
- **18 slash commands**: typed shortcuts like `/setup` or `/weekly-review` that run saved routines. The full list is further down.
- **A meeting pipeline** that turns transcripts into filed decisions and action items (below).
- **Tool-agnostic wiring.** Commands ask for "your task manager", not a brand. `/setup` records once which real tool plays each role.
- **Self-maintenance.** Changes save and back up automatically, indexes stay current, and Claude opens each session already briefed on what changed and what's gone stale.
- **An update path.** `/update-system` pulls template improvements into your vault without touching your content.
- **Two manuals.** `START_HERE.md` is yours: getting started, plus the reference for when you forget how something works. The `CLAUDE.md` files are Claude's; the system maintains them and you never edit them by hand.

---

## How your files are organized

The structure is **PARA, inverted**. Tiago Forte's classic PARA puts Projects first; here Areas come first, because projects come and go while the domains they belong to (your business, your health, your home) are what you actually live in.

```
0-Inbox/            new stuff you haven't sorted yet
1-Areas/            the big domains of your life and work
  <Area>/
    CLAUDE.md       what Claude should know when working in this Area
    _index.md       a table of contents Claude keeps current
    projects/       work with an end date, written by you
    ongoing/        notes that stay useful over time, written by you
    sources/        things other people wrote (never edited)
    archive/        finished work and old history
2-Resources/        reference material that cuts across Areas
3-Archives/         whole Areas you've retired
```

**Areas are domains, not topics.** A business, your health, a property. Each Area carries its own context file, so Claude walks in knowing who the people are and what's open. Add a venture, tell Claude, and it builds the new Area for you.

**Files are sorted by who wrote them.** Things other people wrote go in `sources/` and never get edited; things you wrote stay editable. That's what keeps citations honest: "according to your March report" still points at the real March report months later.

**The inbox is always safe.** Don't know where something goes? Drop it in `0-Inbox/`. Filing happens later, with help.

---

## Meetings in, actions out

The pipeline I use most. `/meeting-ingest` pulls transcripts from whatever meeting tool you use and files each one to the right Area by recognizing who was in the room. `/meeting-digest` then reads each meeting and pulls out decisions (with owners), open questions, ideas worth keeping, and action items with due dates.

You approve the list, and each piece goes where it belongs: action items to your task manager, decisions to your notes, everything mirrored in the vault with a link back to the meeting. The vault copy is written first, so nothing is lost if a downstream tool fails.

---

## Your tools, wired in once

Commands that reach outside the vault never assume which apps you use. Each asks for a **role**, like "your task manager", and `/setup` records once which real tool plays each role. Your answers live in one private file, `config/stack.md`, which stays on your computer.

| Role | What it fills |
|---|---|
| `task_manager` | where your to-dos get published |
| `notes_dashboard` | your live priorities or status board |
| `calendar` | anything schedule-aware |
| `meeting_source` | where meeting transcripts come from |
| `transcription` | turning audio into text |
| `notification_channel` | where briefings and digests get sent |
| `outputs_dir` | a folder for finished deliverables, outside the vault |
| `sync` | how the vault moves between your machines |

You don't need all of them. If a command needs a role you haven't connected, it stops and tells you how. Switching tools later is a one-line change.

**Passwords and API keys never go in vault files.** They live in your computer's environment variables (a built-in place both Windows and Mac keep secrets outside any file), and `/setup` shows you how when a tool needs one.

---

## The plumbing

Five small scripts run automatically at the right moments. You never touch them.

| Script | Runs | What it does for you |
|---|---|---|
| `auto-pull.sh` | session start | fetches the latest vault, so this machine catches up |
| `session-briefing.sh` | session start | quietly briefs Claude on recent activity, inbox, stale projects |
| `auto-index.sh` | after files change | keeps each Area's table of contents current |
| `mark-dirty.sh` | after files change | notes that this turn changed something |
| `commit-on-stop.sh` | end of each turn | saves and backs up everything that changed |

One tidy save point per working turn, described and pushed to your private backup without you thinking about it. That's hundreds of restore points a month, and you'll never manage any of them: when something goes wrong, you describe it ("undo whatever happened to the pricing doc yesterday afternoon") and Claude finds the exact moment and reverts just that, keeping everything since. Fine-grained history is what makes undo surgical, and it works because the librarian reads the ledger for you.

Safety rails are on by default: destructive commands ask first, risky web fetches are blocked.

---

## The commands

Every command is a saved routine in a readable markdown file; typing `/name` runs it. `START_HERE.md` has the full manual for each. How they fit together underneath is in [`ARCHITECTURE.md`](ARCHITECTURE.md).

| Command | What it does |
|---|---|
| `/setup` | Interviews you, personalizes `CLAUDE.md`, wires your tool stack. Run first. |
| `/daily-checkin` | Morning view: calendar, tasks due and overdue, a focus list |
| `/brain-dump` | You talk, it organizes: tasks published, priorities updated, a dated record filed |
| `/weekly-planning` | The weekly operating pass: maintenance, cross-Area review, top priorities, dashboard update |
| `/weekly-review` | Vault-only maintenance: inbox, stale projects, open decisions |
| `/schedule-week` | Turns agreed priorities into calendar blocks |
| `/capture` | Files something into the right place when you don't want to think about where |
| `/file-this` | Files substantive thinking out of a chat before the session ends and loses it |
| `/distill` | Promotes what matters into per-Area highlights; lints for contradictions and orphans |
| `/refresh-context` | Updates Area context files after work changes status, people, or decisions |
| `/focus` | Loads one Area's full context for deep work |
| `/archive` | Retires a finished project to its Area's archive, history preserved |
| `/meeting-ingest` | Pulls transcripts from your meeting tool and files each to the right Area |
| `/meeting-digest` | Extracts decisions, questions, and action items; routes them after your approval |
| `/cowork-brief` | Hands a task to Claude Cowork with a self-contained briefing file |
| `/find-solution` | Searches for an existing tool before concluding something must be built |
| `/system-review` | Surveys recent changes to the system itself: hooks, commands, settings |
| `/update-system` | Pulls template improvements into your vault without touching your content |

---

## Staying up to date

I run this system every day; my companies, my properties, and my health all live in my private copy. When an improvement proves out in practice, it ships here, and now that it's public, community fixes land here too. Every change is recorded in [`CHANGELOG.md`](CHANGELOG.md).

Your copy picks improvements up with one command, `/update-system`. It shows you what changed and why, applies only the system files you approve, and never touches your Areas, your inbox, or your personalized `CLAUDE.md`. Anything you've customized gets a side-by-side comparison, never a silent overwrite.

---

## What you need

- **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)**, the AI assistant that does the work. It runs on your computer, on your existing Claude plan. (The vault is plain text any AI tool can read, but the commands and automation are built for Claude Code.)
- **A free [GitHub](https://github.com) account**, where the private, backed-up copy of your vault lives. Only you can see it.
- **git and Bash on your machine**: the save-history tool and the scripting language the automation uses. Macs and Linux have both. On **Windows, one free install ([Git for Windows](https://git-scm.com/download/win)) provides both**.
- **[Obsidian](https://obsidian.md/)** *(optional, recommended)*: a free notes app that opens the same folder with a friendly editor, search, and a map of how your notes connect. Its paid **Sync** add-on is the easiest way to get your vault on your phone. The [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) collection (MIT, installed separately) pairs well for richer editing.

No coding. No database. No build step.

---

## Get started

### Let Claude set it up (recommended)

Install Claude Code, create a GitHub account if you don't have one, then open Claude Code and paste:

> Set up Dougie's Brain for me: clone https://github.com/dougthewatson/dougies-brain.git into a folder called my-brain, keep the template connected as "upstream", help me create a private GitHub repository of my own as "origin" and push to it, then run /setup.

Claude does the work and walks you through the one or two clicks it can't do for you (like logging in to GitHub). Then `/setup` interviews you: who you are, how you like to work, which of your tools to connect. Your answers get written into the system's files for you. You never edit a configuration file by hand.

### The DIY way

1. On [GitHub](https://github.com), click the **+** in the top-right corner and choose **New repository**. Name it whatever you like (`my-brain` works), select **Private**, leave every checkbox unticked, and click **Create repository**.
2. Open a command line: on Windows, press Start and type **PowerShell**; on a Mac, open **Terminal**.
3. Paste these five lines, swapping in your username and repo name on the fourth:

```bash
git clone https://github.com/dougthewatson/dougies-brain.git my-brain
cd my-brain
git remote rename origin upstream
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

Line 1 downloads the template, line 2 steps inside, lines 3 and 4 tell git "the template is `upstream`, my private repo is home", line 5 sends your first backup. (If a browser window pops up asking you to log in to GitHub, that's normal.) Keeping the template connected as `upstream` is what lets `/update-system` pull improvements later. Then start Claude Code inside your new folder and run `/setup`.

### Once you're in

- **Build your first Area by talking.** Tell Claude "set up an Area for my business" and it creates the folders, the index, and the context file. You never build the tree by hand.
- **When in doubt, inbox.** Drop it in `0-Inbox/`; filing happens later, with help.
- **Ask Claude to delete the sample** `Example-Area` once you've seen how one is put together.
- **Skim [`START_HERE.md`](START_HERE.md)**, your manual: it gets you going and it's where you look when you forget how something works.

---

## Make it yours

This is a template, not a finished product. Live in it for a week, then shape it: when you find yourself doing the same thing twice, ask Claude to add a command for it. The vault should get more useful over time, not just bigger.

Issues and pull requests welcome: fixes, new commands, better fallbacks for tools I don't use. If you fork it into something different, that's the point.

Built by [Doug Watson](https://github.com/dougthewatson). MIT licensed; see [`LICENSE`](LICENSE).
