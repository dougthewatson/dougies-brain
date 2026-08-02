---
description: File substantive synthesis from Claude Code conversations into the vault as forward-relevant notes. Closes the gap between in-flow chat synthesis and persistent vault filing.
argument-hint: [--batch] [--since=Nd] [--proposal-only | --review]
---

# /file-this

Read `config/stack.md`. This command does not require an external tool role, but if filings contain tasks, publishing them to the `task_manager` role is an external write and waits for a yes. If that role is unset, note it but continue with vault filing. Do not assume any specific product.

You are filing **substantive synthesis from Claude Code conversations** into the vault. The problem this solves: the user works through real analysis with the agent in chat (decisions, frameworks, comparisons, plans, worked-through approaches). When the session ends, that synthesis disappears unless someone files it as a vault note. `/capture` files content the user brings *in*. `/distill` mines content already *in* the vault. This command catches the third surface: synthesis that emerged *during* a chat and was never written down.

The bar is the same as `/distill`: **forward-relevant**. Would the user or a future session benefit from finding this without grepping chat history? If yes, file it. If no, skip it.

This command acts first and reports after, per the review-and-revert principle. A new vault file is additive and revertible via the end-of-turn commit, so file it and report it. Three things still ask first: revising an existing note in place (that risks overwriting something the user wrote), anything the privacy filter catches, and publishing tasks outside the vault.

## Modes

`/file-this` runs in one of three modes:

- **Default: current session.** Review the conversation currently in context. Identify any synthesis worth filing. File the clean candidates, hold the flagged ones for their questions. Use this at the end of any chat that produced real analysis.
- **`--batch [--since=Nd]`:** sweep recent Claude Code transcripts in the window (default 7 days). Read `.jsonl` files in the project's transcript folder, extract substantive synthesis across sessions, dedupe against the vault, propose filings as a consolidated report. Used by `/weekly-planning` at the start of your week. Default `--since=7d`.
- **`--proposal-only`** (only valid with `--batch`): write the consolidated proposal to `0-Inbox/_filings-pending-{YYYY-MM-DD}.md` instead of presenting interactively. Reserved for future scheduled use.
- **`--review`:** load the most recent `0-Inbox/_filings-pending-*.md` and walk through it. After processing, archive the pending file to `0-Inbox/archive/filings-history/{YYYY-MM-DD}_filings.md`. Errors out if no pending file exists.

## What to do

### Phase 0: Mode dispatch

Read flags first.

- `--review`: skip to Phase 5.5 (load pending proposal). Don't read transcripts.
- `--batch --proposal-only`: run Phases 1–4, then jump to Phase 4.5 (write proposal file). Skip Phases 5–6.
- `--batch` alone: run Phases 1–6 interactively across the window.
- No flags (default): run Phases 1–6 against the current session only.

If `--proposal-only` is used without `--batch`, error out: proposal-only is meaningful only for the batch sweep.

### Phase 1: Locate the input(s)

**Default mode (current session):**

You already have the current conversation in your context. Skip file reading entirely. The transcript IS your context window. Treat it as the input for Phase 2.

Caveat: if the current session has been auto-compacted (long-running session that hit the context limit), early synthesis may have been summarized down rather than preserved verbatim. For sessions you suspect ran long, prefer `/file-this --batch --since=2d` over default mode, as the `.jsonl` file holds the full pre-compaction transcript.

**Batch mode:**

1. Determine the project's transcript folder. The standard path on this machine is the Claude Code projects folder for the vault project (check `config/stack.md` or the Claude Code project settings for the exact path). The folder contains one `.jsonl` file per session.
2. List `.jsonl` files modified within the `--since` window (default 7 days). Use the file's mtime, not contents.
3. Skip files smaller than 4KB: these are typically aborted sessions or trivial Q&A with no synthesis to mine.
4. Read each remaining file. Each line is one event in JSON. The events you care about are user messages and assistant text responses. Ignore tool calls, tool results, and metadata events.

Be conservative on token budget. If the cumulative size exceeds ~200KB of message text, summarize-as-you-go rather than holding the entire window in working memory.

### Phase 2: Identify substantive synthesis

For each session (or for the current conversation in default mode), look for synthesis that meets the bar:

**Promote when the conversation produced:**

- A **decision** with rationale (options were weighed and one was committed to)
- A **framework or methodology** that will be reused (TAM model, validation framework, naming criteria, scoring rubric)
- A **comparison or analysis** with a clear conclusion (competitive read, vendor comparison, strategic positioning)
- A **plan or approach** with steps and reasoning (not just a TODO list)
- A **worked-through argument** that closes an open question
- A **fact or finding** that anchors strategy and isn't already in the vault (regulatory requirement, market figure, key competitor move)

**Skip:**

- Operational chats: sessions about running `/capture`, `/distill`, `/refresh-context`, `/weekly-review`, `/file-this` itself, or any meta-conversation about the PKM system. These produce vault file changes already; the chat itself isn't the synthesis.
- Skill-building / debugging / system configuration: chats about hooks, settings, scheduled tasks, recovery procedures. The artifacts already exist. The conversation is implementation noise.
- Pure tool-use sessions: chats dominated by Read/Edit/Bash/Write tool calls with minimal prose reasoning. The work is the diff; there's no synthesis to file.
- Trivial Q&A: one-off questions with one-line answers ("what's the syntax for X?", "how do I do Y?"). Reference material, not synthesis.
- Already-filed material: if a candidate synthesis is already in `_highlights.md`, an Area `CLAUDE.md`, an entity note, or a recent `ongoing/` note, skip. Don't duplicate.
- Half-finished or abandoned threads: the user started exploring something and didn't land. Don't file partial thinking.
- Anything that would embarrass the user in five years (drafts of communications, exploratory ideas that were abandoned, mistakes worked through). Trust that the chat was scratchpad, not record.

For each candidate that clears the bar, capture: a working title, the kind (decision / framework / comparison / plan / argument / fact), a one-paragraph synthesis (your distillation, not the raw chat), and a guess at the relevant Area.

### Phase 3: Cluster, classify, and route

For each candidate:

1. **Determine the Area.** Match against active Areas listed in the user's root CLAUDE.md. If a candidate spans multiple Areas (a framework that applies broadly), prefer the primary Area and note the cross-link in the proposal.
2. **Determine the destination subfolder:**
   - Decision with concrete commitment → Area's `decisions/` folder (or `ongoing/` if no decisions folder yet)
   - Framework / methodology → Area's `ongoing/` folder, or `2-Resources/concepts/` if cross-cutting
   - Comparison / analysis → Area's `ongoing/` folder
   - Plan / approach for a specific project → Area's `projects/<project>/` folder
   - Fact / market data → Area's `ongoing/` folder
3. **Suggest a filename.** Use lowercase-with-hyphens, prefix with date if event-anchored (`YYYY-MM-DD-`). Keep names descriptive and short (under 60 chars).
4. **Dedupe against the vault.** Run `Grep` for the candidate's key terms across the proposed Area (and `2-Resources/` if cross-cutting). If the synthesis appears to overlap with an existing note, flag it for judgment rather than auto-filing as new.

### Phase 4: File and report

Split the candidates:

- **Clean candidates** (net-new file, no privacy flag, no apparent overlap with an existing note): file them now per Phase 5, then report one block per filing in the format below.
- **Held candidates** (privacy filter triggered, refinement of an existing note, or possible duplicate): don't write yet. Present them as questions after the report.

Report format, one block per filing:

```
## [Working title]

**Area:** [Area name]
**Path:** `1-Areas/[Area]/[subfolder]/[filename].md`
**Kind:** [decision | framework | comparison | plan | argument | fact]
**Source session:** [filename or "current session"] · [session date]

**Synthesis:**

[One-paragraph distillation in clean prose, not the raw chat. This is what becomes the body of the file.]

**Key points:**
- [Bullet 1]
- [Bullet 2]
- [Bullet 3]

**Implied wikilinks:** [[entity-1]], [[entity-2]]
**Possible duplicate of:** [[existing-note]] (if any, review before filing)
```

After the filed blocks, list the held candidates, each with the one thing needed: a yes/no on the sensitive item, the diff on a revision, a call on the possible duplicate. If the user redirects a filed item ("wrong Area", "retitle it", "drop it"), correct or remove the file on the spot and say so. The report exists so those corrections cost one line.

### Phase 4.5: Write proposal file (batch + proposal-only mode)

Run only if `--batch --proposal-only` was passed.

1. Compose a single markdown document with frontmatter (`type: filings-proposal`, `created`, `window`, `sessions_scanned`, `status: pending`).
2. Body: short summary header, then one `## [Working title]` block per candidate in the format above.
3. Write to `0-Inbox/_filings-pending-{YYYY-MM-DD}.md`. If a same-day file exists, suffix with `-2`.
4. Skip Phase 5. Proceed to Phase 6 wrap-up with proposal-only summary.

### Phase 5: Write a filing

For each candidate being filed (clean candidates directly; held candidates once the user answers):

1. Confirm the destination path. If the parent folder doesn't exist, create it (e.g., `decisions/` may not exist for every Area yet).
2. Compose the file content:
   - YAML frontmatter: `type` (decision / framework / comparison / plan / argument / fact), `created` (YYYY-MM-DD), `area` (Area name), `source_session` (jsonl filename or "interactive: {session-date}"), `tags` (kind-derived).
   - H1 title.
   - Context line if useful (e.g., "Worked through with Claude on YYYY-MM-DD.").
   - Synthesis body (the one-paragraph distillation expanded into clean prose if needed).
   - Key points section as bulleted list.
   - "Open threads" or "Next steps" section if the synthesis pointed at follow-up work.
   - Wikilinks at the end ("Related: [[entity-1]], [[entity-2]]").
3. Write the file. The auto-commit hook handles the commit.
4. Don't add the synthesis to `_highlights.md` (that's `/distill`'s job). The next distill pass will discover the new file via its normal mining of `ongoing/`, `projects/`, and `decisions/`. No explicit flagging mechanism needed.

### Phase 5.5: Load pending proposal (review mode only)

Run only if `--review` was passed.

1. Look in `0-Inbox/` for `_filings-pending-*.md`. Take the most recent.
2. If none found, output: "No pending filings proposal found. Run `/file-this --batch` to generate one." Then exit.
3. Read the file. Echo back a short summary (filename, candidate count, sessions scanned).
4. Process each `## [Working title]` block the Phase 4 way: file the clean ones and report, hold the flagged ones for their questions.
5. After processing, move the source pending file to `0-Inbox/archive/filings-history/{YYYY-MM-DD}_filings.md`. Create the `archive/filings-history/` directory if it doesn't exist.

### Phase 6: Wrap-up

```
File-this complete.
- Mode: [default | batch | review | batch+proposal-only]
- Sessions scanned: [N] (batch only)
- Candidates surfaced: [N]
- Filings applied: [N]
- Filings declined: [N]
- New folders created: [list, if any]
```

The auto-commit hook handles commits. Don't commit manually.

## Decision rules

- **The current session is itself a meta-conversation about the PKM system?** Skip. Don't file conversations about building skills, configuring backups, or debugging hooks. Those produce file changes; the chat itself isn't synthesis worth filing.
- **A synthesis emerged but is genuinely scratchpad** (the user explored, didn't commit)? Skip. The bar is "landed on this," not "considered this."
- **The synthesis spans multiple Areas?** File once in the primary Area. Add cross-references via wikilinks rather than duplicating.
- **The synthesis is a refinement of an existing note?** Don't create a new file. Appending a dated addendum is additive: do it and report. Revising existing content in place risks overwriting something the user wrote: show the diff and wait.
- **Filename collision?** Suffix with a counter (`-2`, `-3`) rather than overwriting. The user can rename later.
- **Voice in the synthesis matters?** When the synthesis represents a decision the user made or a framework they developed, write it from their perspective. When it's an analysis the agent produced, neutral voice is fine.
- **Privacy filter triggers?** If the candidate synthesis touches personal or sensitive material (health specifics, family matters, individual reputations of third parties), be extra conservative. Ask before filing rather than proposing without explicit confirmation.

## Don't

- Don't paste raw chat transcripts into vault files. The synthesis is your distillation, not the conversation.
- Don't file the same synthesis twice across runs. Check what was filed in previous `/file-this` runs (look at recent commits or check `0-Inbox/archive/filings-history/`).
- Don't file synthesis that's already in `_highlights.md`, an Area `CLAUDE.md`, or a recent `ongoing/` note.
- Don't update `_highlights.md` directly (that's `/distill`'s job). Flag candidate highlights for the next distill pass instead.
- Don't update Area `CLAUDE.md` files (that's `/refresh-context`'s job).
- Don't read transcript files outside the project's own folder unless explicitly asked. Other Claude Code projects are out of scope.
- Don't propose filings for sessions that ran any of: `/capture`, `/distill`, `/refresh-context`, `/weekly-review`, `/weekly-planning`, `/file-this`, `/brain-dump`, `/daily-checkin`, `/schedule-week`, `/focus`. These are operational and produce file changes themselves.
- Don't auto-create entity notes during filing (that's `/distill`'s domain). Use existing wikilinks where they resolve, leave plain text where they don't.
- Don't ask about a held filing more than once. One answer, then write or drop.
