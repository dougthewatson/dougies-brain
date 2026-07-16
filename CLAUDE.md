# CLAUDE.md (Root Instructions for this Vault)

This file is loaded automatically at the start of every Claude Code session in this vault. It tells you how to work here. It is a template: fill in the blanks marked `{{...}}` and the prompts below, then delete this sentence.

---

## Who you're working with

> Fill this in. Replace the placeholders, keep it short (a paragraph at most), and delete any line that doesn't apply. This is the single most useful section in the file: it lets Claude calibrate tone, default to the right Area, and make sensible assumptions instead of asking.

- **Name:** {{USER_NAME}}
- **Where you're based / timezone:** _e.g. "Toronto (Eastern)". Used for dates, scheduling, "today"._
- **What you do:** _one or two sentences. The hats you wear, the businesses or projects you run, the domains your work spans. This is what Areas will mostly map to._
- **How you think / decide:** _optional. e.g. "prefer the direct answer first, reasoning second" or "show me the aggressive option and let me add buffer." Calibration cues like this make every answer better._
- **What you want from this vault:** _optional. e.g. "a durable second brain that compounds," "less time filing, more time thinking."_

Until this section is filled in, treat the user generically and ask for a name and context the first time it matters.

---

## Vault structure

This vault follows **inverted PARA**:

```
0-Inbox/          ← unfiled captures, sorted in weekly reviews
1-Areas/          ← top-level life/work domains
  <Area>/
    CLAUDE.md     ← Area-specific context (read this when working in the Area)
    _index.md     ← auto-maintained index (Map of Content)
    projects/     ← time-bounded work (editable)
    ongoing/      ← evergreen authored content for the Area (editable)
    sources/      ← third-party-authored material you've collected (immutable)
    archive/      ← completed projects + immutable conversation history
2-Resources/      ← cross-cutting reference (AI tools, templates, frameworks)
3-Archives/       ← whole Areas that have been shut down
```

**Finished deliverables (PDFs, Word docs, presentations) go OUTSIDE the vault, directly to their final home**: the folder where the file will actually be used (a client's shared folder, an Area's external working folder). The `outputs_dir` path configured in `config/stack.md` is the fallback for deliverables with no proper home. Routing everything through a generic outputs folder forces manual re-filing; save to the destination once instead.

Keep these destinations somewhere your other devices can reach (synced cloud folders work well) so finished files are available off your desktop. Working files, drafts, and sources stay in the vault. Sources are the truth; exports are disposable.

### Provenance: authored vs. collected

The folder split inside an Area is by **provenance, not topic**:

- **Did someone else author it?** → `sources/`. Immutable. Never edit. Examples: clipped articles, downloaded reports, vendor specs, podcast transcripts, lab results, contracts you didn't write, screenshots of dashboards, others' published research.
- **Did you author it (or collaborate with the agent to author it)?** → `projects/` if time-bounded, `ongoing/` if evergreen. Both editable. Examples: meeting notes, brain-dumps, frameworks you're developing, rosters, trackers, decision logs, project workstreams.
- **Did the LLM author it as synthesis from the above?** → a `_highlights.md` per Area, entity notes in `2-Resources/people|companies|concepts/`, or the Area `CLAUDE.md`. Editable, regeneratable.

Why this matters: when synthesis cites a source ("according to your March report, X"), the citation is durable because `sources/` doesn't get edited. If sources mixed into `ongoing/` get revised, citations rot.

Mining commands (e.g. `/distill`) read from `sources/`, `ongoing/`, `projects/`, and any chat-import archive. They treat `sources/` as quotable and immutable; they treat `ongoing/` and `projects/` as your content that can be revised, summarized, or wikilinked into.

Adoption is lazy. Add a `sources/` folder to an Area when you next file material that fits there. Don't backfill existing folders.

### `2-Resources/` vs. per-Area `sources/`

- `2-Resources/` is **cross-cutting reference** authored by you or the LLM (templates, frameworks, AI-tooling notes, a wikilinks schema). It applies across multiple Areas.
- `sources/` is **per-Area third-party material**. It belongs to one Area's domain.

Rule of thumb: if the material is you-authored or LLM-authored AND useful across multiple Areas, it goes in `2-Resources/`. If it's third-party and Area-specific, it goes in that Area's `sources/`.

---

## Core conventions

**File naming**
- Use lowercase with hyphens: `q3-pipeline-review.md`, not `Q3 Pipeline Review.md`
- Dates in filenames use `YYYY-MM-DD` format
- Index files are always named `_index.md` (the underscore sorts them to the top of the folder). These act as Maps of Content (MOCs) for their folder.

**File structure**
- Every markdown note starts with an H1 title
- Include a short context line at the top when useful ("Context: meeting with X on Y")
- Use H2 for major sections, H3 sparingly
- Prefer prose with well-placed headers over deep bullet nesting

**When creating files**
- New captures go in `0-Inbox/` unless the user has said otherwise or the correct location is obvious
- Never create files in `3-Archives/` without explicit instruction
- Never overwrite existing files without confirming

**When editing files**
- Explain what you changed in plain language before or after the edit
- For substantive edits (not typo fixes), prefer showing a diff

---

## Scoped context loading

When the user starts working on a specific Area, read that Area's `CLAUDE.md` before doing substantive work. For example:
- "Let's work on `<Area>`" → read `1-Areas/<Area>/CLAUDE.md`
- "I need to update the `<thing>` in `<Area>`" → read `1-Areas/<Area>/CLAUDE.md`
- Cross-cutting reference work (AI tools, frameworks, templates) → read `2-Resources/CLAUDE.md`

Don't proactively load every Area's `CLAUDE.md` at session start. Only load what's relevant to the current work.

---

## Tooling: roles, not products

This vault is tool-agnostic. Commands that touch the outside world (publishing tasks, updating a dashboard, reading a calendar, ingesting meetings, sending notifications) refer to a **role**, not a specific product. The mapping from role to your actual tool lives in `config/stack.md`.

- Copy `config/stack.example.md` to `config/stack.md` and fill in your choices once. `config/stack.md` is yours and is gitignored by default.
- Every command opens by reading `config/stack.md`. If the role it needs is unset or its tool isn't connected, the command stops and tells you what to connect and how (native MCP first, then a connector platform, then manual), rather than guessing.

Roles used across this vault:

| Role | Purpose |
|---|---|
| `task_manager` | where captured tasks publish |
| `notes_dashboard` | live priorities / status board |
| `calendar` | schedule-aware commands |
| `meeting_source` | meeting transcript ingestion |
| `transcription` | audio to text |
| `notification_channel` | briefings and digests push |
| `outputs_dir` | finished-deliverables folder |
| `sync` | cross-machine sync strategy |

When in doubt about which tool backs a role, read `config/stack.md`. Do not assume a product.

---

## Communication style

> These are sensible defaults. Adjust them the same way you'd brief a sharp new collaborator. Commands that generate prose (meeting digests, drafts, summaries) apply this section, so it's the one place to encode how you want things written.

- **Direct answers first**, explanations second. The answer, then the reasoning if needed.
- **Tight phrasing.** No fluff, no hedging, no unnecessary preamble.
- **Warm but not sycophantic.** Treat the user as a peer, not a client to flatter.
- **Structured outputs** (bullets, tables, code blocks) for analytical or export work. Prose for conversation and explanation.
- **Professional-grade quality** for any work that will be read by others.
- **Evidence-based.** Don't invent facts. If unsure, say so.

**Your hard rules.** Replace these with your own. The two below are the original author's, left in as examples of the right granularity for a rule:

- No em-dashes. Use commas, periods, or parentheses instead.
- Never use the word "seamless."

---

## When the user asks for something ambiguous

Default to acting on the most plausible interpretation and stating the assumption, rather than asking a clarifying question upfront. The user generally prefers forward motion. Ask only when the request is genuinely unanswerable without more info.

---

## Search before declaring a roadblock

Before saying "I don't have X," "Claude Code can't do that," "we'd need to build it," or any equivalent capability-gap framing, run a quick search for an existing solution. Default to the fastest path that produces a useful answer. Often 10-30 seconds against a curated index and one focused web or GitHub query is enough. Hard cap: 2 minutes. Don't pad to fill the budget.

Search order (stop as soon as 2-3 viable candidates surface):
1. A curated index of Claude Code skills, hooks, plugins, and MCPs (e.g. an `awesome-claude-code` style list)
2. GitHub topic/keyword search
3. Package registry (for tools that ship as packages)
4. Broader web search

Report 2-3 candidates with honest reads (what each actually does, popularity and recency, fit, install effort) before falling back to "we'd have to build it."

If the quick search produces fewer than 2 viable candidates, ask whether to do a more exhaustive search before falling back to build-it.

This applies to capability gaps, not judgment calls. "Claude Code doesn't natively support X" triggers a search. "We shouldn't do X because it conflicts with Y" does not.

Shortcut: invoke `/find-solution <gap description>` to systematize the search when you want it explicit.

---

## The weekly rhythm

Run `/weekly-review` on a regular cadence (a Monday-morning habit works well). When that command fires:
1. Process everything in `0-Inbox/` (propose a destination for each item, ask for confirmation on anything ambiguous)
2. Walk each Area's `projects/` folder and flag anything untouched for 30+ days
3. Surface open decisions that haven't been resolved
4. Offer to update any `CLAUDE.md` or `_index.md` files that drifted

---

## Memory and context maintenance

Two mechanisms:
- **Auto-memory** (if enabled) captures preferences, corrections, and small recurring patterns across sessions.
- **CLAUDE.md files** capture structured context: one at vault root, one per Area, occasionally one per large project.

At the end of meaningful work sessions, offer to run `/refresh-context` (or propose updates to the relevant `CLAUDE.md` directly). Don't edit `CLAUDE.md` files silently.

This vault is private to its owner. Personal context, business detail, and sensitive material that informs the work belongs here when it's load-bearing. **Do not** write to `CLAUDE.md` files:
- Names or identifying details of third parties who haven't consented and would object to being indexed here, where the detail isn't load-bearing for the work
- Confidential information covered by active NDAs or embargoed material from clients or partners
- Anything the user would not want to read in five years

---

## Index files (Maps of Content)

Each Area has an `_index.md` that acts as a Map of Content (MOC), a navigable index into its contents. Keep them:
- Short (one screen max)
- Focused on navigation, not summary
- Updated when the shape of the Area changes, not on every note addition

When asked to regenerate an index, walk the folder, identify the meaningful groupings, and produce a clean index with links.

---

## Output destinations

| Task | Where output goes |
|---|---|
| Working drafts, notes, thinking | Inside the vault, in the relevant Area |
| Finished deliverables (PDF, DOCX, PPTX, XLSX) | The folder where the file will be used: a client's shared folder, the Area's external working folder. Fall back to your configured `outputs_dir` (under `<Area>/`) only when no proper home exists |
| Cowork task handoffs | `/cowork-brief` writes a briefing file into a `_cowork/` subfolder of the destination; Cowork works there in place |
| Meeting transcripts and summaries (auto-ingested) | `1-Areas/<Area>/ongoing/meetings/raw/<YYYY-MM-DD>/` (or `0-Inbox/meetings/` if no Area match) |
| Scratch / temporary files | A local scratch or temp folder, never the vault |

When exporting a finished file, save it directly to its final home; the vault keeps the source. `outputs_dir` is a fallback, not a default routing stop.

---

## Git

The vault is a git repository. Commits happen automatically once per Claude turn:
- A **PostToolUse** hook (`mark-dirty.sh`) marks the session "dirty" on any Write/Edit/MultiEdit.
- A **Stop** hook (`commit-on-stop.sh`) stages everything, commits with an auto-generated message, and (if a remote is configured) pushes.

One turn → one commit, even if many files were touched. Chat-only turns produce no commits. To disable, remove the hook entries from `.claude/settings.json`. When asked to revert or investigate history, use `git log` and standard git commands.

A separate **SessionStart** hook (`auto-pull.sh`) pulls the latest from the remote at the start of a session so multiple machines stay in sync, and `session-briefing.sh` prints a short orientation. An **auto-index** hook keeps Area `_index.md` files current as files change.

---

## Cross-machine sync (optional)

If you work across more than one machine, configure a `sync` strategy in `config/stack.md`. The vault's own auto-commit and auto-pull hooks (above) cover the git side. The portable subset of your `~/.claude/` configuration (settings, hooks, scripts, commands, skills) can be synced separately via its own repo if you want both machines to behave identically. Keep machine-specific state (local settings, caches, lockfiles, editor workspace state) out of version control; the `.gitignore` is set up for this.

---

## Credentials and API keys

**Store all secrets (API keys, tokens) in environment variables. Never in config files, vault notes, `CLAUDE.md` files, or command arguments that appear in transcripts.**

- Set the secret as an environment variable on your machine, then restart Claude Code (or open a new terminal) so the session inherits it.
- Reference secrets by environment-variable name, never by literal value.
- Prefer stdio MCP servers where possible: subprocesses inherit your environment automatically, so no credential needs to appear in any config file.
- For services that require auth headers, check whether a stdio variant or a connector platform (which manages tokens for you) can avoid storing the secret locally.

If you ever find yourself about to put a credential anywhere other than an environment variable, stop and use the environment-variable path instead.

---

## What to prioritize when in doubt

1. **Don't lose data.** If you're uncertain whether to modify or delete, stop and ask.
2. **Preserve the user's voice.** Match their phrasing conventions in anything that will be read by others.
3. **Keep the system legible.** Better to put a file in a slightly-wrong place clearly than to create a new structure nobody understands.
4. **Compound, don't accumulate.** The vault should get more useful over time, not just bigger.

---

## What this vault is not

- Not a code repository (though it's git-tracked)
- Not a shared team workspace (this is one person's brain)
- Not a replacement for your other tools (those stay; this sits alongside)
- Not a chat log (ephemeral conversation lives in the chat client, not here)

---

*This file is the contract for how this vault works. When the contract needs to change, update this file directly.*
