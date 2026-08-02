---
description: Distill recent vault activity into _highlights.md, audit wikilinks, and lint each Area for contradictions, orphans, and concept gaps
argument-hint: [area-name | all] [--since=Nd] [--proposal-only | --review] [--backfill]
---

# /distill

> Read `config/stack.md`. This command is vault-only and runs with no roles connected. It never
> writes to an external tool. It reads the `status_board` and `outputs_dir` roles only to name
> where mirrored items or finished deliverables live when referencing them; if either is unset,
> make those references in chat and carry on. Do not stop, and do not assume any specific product.

You are running the vault-distillation pass. The goal is to keep each Area's `_highlights.md`
current with what is actually happening, and to grow the wikilink graph deliberately as new entities
show up. Do not curate aggressively. The bar is "forward-relevant," not "interesting."

This command acts first and reports after, per the review-and-revert principle. Highlight
additions, entity-note creation, and concept-page creation are additive, in-vault, and revertible
via the end-of-turn commit: apply them and report. What still asks first: lint contradictions
(only the user knows which fact is current), orphan and stale-note dispositions (mine / archive /
leave is a judgment call), ambiguous entity mentions, and malformed pending proposals.

Reference the schema at [[wikilinks-schema]] (`2-Resources/wikilinks-schema.md`) for every wikilink
and entity-note decision. If something in this command conflicts with the schema, the schema wins.

## Modes

`/distill` runs in one of three modes based on flags:

- **Interactive (default):** runs Phases 1-8 in one pass. Phase 6 applies the additive items and
  reports them; the judgment items come back as questions. Use for ad-hoc runs.
- **`--proposal-only`:** runs Phases 1-5.5 (analysis), writes the Phase 6 proposal block to
  `0-Inbox/_distill-pending-{YYYY-MM-DD}.md`, exits. No approval, no apply, no back-fill. Used by
  a scheduled agent. The pending file is what the user reviews later.
- **`--review`:** invoked when a pending proposal exists. Skips Phases 1-5.5. Reads the most
  recent `0-Inbox/_distill-pending-*.md`, processes it as if Phase 6 just generated it (additive
  items applied and reported, judgment items asked), then runs Phase 8 (wrap-up). On successful processing, moves
  the pending file to `0-Inbox/archive/distill-history/{YYYY-MM-DD}_distill.md`. Phase 7
  (back-fill) only runs if `--backfill` was also passed.

The `--backfill` flag is independent and applies to interactive and review modes (not
proposal-only).

If `--review` runs and no pending file exists, say so plainly and exit. Do not silently fall through
to interactive mode.

## What to do

### Phase 0: Mode dispatch

Read flags first.

- If `--review`: skip to Phase 5.7 (load pending proposal). Do not run analysis phases.
- If `--proposal-only`: run Phases 1-5.5, then jump to Phase 6.5 (write proposal file). Skip
  Phase 7 entirely. Use Phase 8.5 wrap-up.
- Otherwise (interactive default): run Phases 1-8 in order.

### Phase 1: Determine scope

1. If the user passed an Area name, scope to that Area.
2. If the user passed `all` (or nothing), scope to every Area in `1-Areas/` plus `2-Resources/`.
3. If the user passed `--since=Nd`, use that window for "recent activity." Default is 30 days.
4. State the scope in one line and proceed.

### Phase 2: Collect recent activity per Area

For each in-scope Area:

1. List files modified in the window in:
   - `sources/`: third-party material (articles, reports, transcripts) the user has collected.
     Treat as quotable and immutable; mine for facts, dates, claims, and entity mentions. Never
     propose edits to these files.
   - `archive/chat-imports/`: focus on dated digest files
     (`_chat-imports-YYYY-MM-DD-highlights.md`) and any newly imported conversation files
   - `ongoing/`: substantive notes (skip `_index.md`, `CLAUDE.md`, scratch)
   - `projects/`: any files inside active project folders
   - `ongoing/decisions/`: any new decision entries (these are almost always highlight-worthy)
   - `ongoing/questions/`: open questions. Check each against newer material before promoting: a
     question something has since answered should be promoted as the answer, with the question
     noted as closed, not carried forward as still open.
   - `ongoing/ideas/`: ideas worth keeping. Promote the ones that recur across entries.
   - `ongoing/objectives/`: strategic objectives and weekly priorities. Promote an objective when
     it is still live, and flag one that has gone quiet for several windows as possibly stale
     rather than silently keeping it in the highlights.
2. Read the Area's existing `_highlights.md` if it exists. If it does not, you will create it in
   Phase 4.
3. Build a working set of "candidate items" (anything from step 1 not already cited in
   `_highlights.md`).

Filter out auto-commit noise (index regenerations, frontmatter-only edits, the auto-index hook
output).

### Phase 3: Identify what is worth promoting

Walk the candidate items. Promote when an item is **forward-relevant**: it is the kind of thing the
user or a future session would want to find without grepping. Specifically:

- **Decisions** that close an open question (always promote)
- **Frameworks or models** that will be reused (methodologies, validation frameworks, naming
  criteria)
- **Templates or canonical artifacts** (service agreement templates, pitch deck guidebooks,
  financial model versions)
- **Facts that anchor strategy** (regulatory requirements, market figures, competitor positioning)
- **Contacts or relationship updates** that change how the user should engage someone
- **Open threads** that are still alive and likely to resurface

Skip:
- One-off Q&A with no carry-forward
- Working notes already superseded by a later doc
- Anything the user clearly drafted then abandoned
- Casual mentions in chat-imports that did not lead anywhere

For each item to promote, capture: source path, one-line distillation, kind (decision / framework /
fact / contact / template / snippet / open-thread), and any wikilink targets it implies.

### Phase 4: Wikilink audit per the schema

For each in-scope Area's recent activity:

1. Build a list of entity mentions: people (full names or known aliases), companies, projects,
   decisions. Use plain text scanning. Do not look only at existing `[[wikilinks]]`.
2. Check each mention against the canonical entity index. To build the index on the fly, scan:
   - `2-Resources/people/*.md`
   - `2-Resources/companies/*.md`
   - `2-Resources/concepts/*.md`
   - Each Area's `projects/*/` for project hub notes (file matching folder name)
   - Each Area's `decisions/` folder for decision notes
   - `aliases:` frontmatter on any of the above
3. Classify each mention:
   - **Resolved:** entity note exists, wikilink would work
   - **Missing:** entity is mentioned 2+ times across recent notes (or is a defining-role contact
     in `CLAUDE.md`) but has no entity note yet. Propose creating one.
   - **Skip:** one-off mention with no graph value, generic concept, or matches the schema's
     "do not wikilink" list
4. For "Missing" entities, propose a canonical slug per the schema (kebab-case lowercase, ASCII, no
   spaces) and the destination folder.

Do **not** propose back-fills of `[[wikilinks]]` into existing notes during this phase. That is
Phase 6, and is only offered after entity notes exist.

### Phase 5: Lint pass

For each in-scope Area, run three integrity checks. Be conservative. Contradictions (5a) and
orphans (5b) are judgment calls: flag them for the user's review, never silently fix. Concept
gaps (5c) that clearly meet the threshold become new pages, which is additive: create them in
Phase 6 and report.

**5a. Contradiction check.** For each candidate item being promoted (Phase 3) and for the existing
content of `_highlights.md` and Area `CLAUDE.md`, look for direct factual conflict with a newer
note in the recent window. Examples: a status listed as "active" in `CLAUDE.md` but a recent note
records the closure; a fact in `_highlights.md` that a recent source contradicts; a person's role
described one way in `CLAUDE.md` and differently in a recent note. Skip phrasing differences and
trivial rewordings. Only flag substantive factual conflict.

**5b. Orphan check.** Walk `ongoing/` and `projects/` (excluding archive). A note is orphan if all
of: zero inbound wikilinks from any other vault file, no entry in `_highlights.md`, no reference in
the Area's `CLAUDE.md`, and modified more than 30 days ago. New notes (under 30 days) are exempt.
Do not flag deliberate root-level files (`README`, `_index`, `_highlights`, `CLAUDE`).

**5c. Concept-gap check.** Scan recent notes for repeated mentions of topics, frameworks, or
concepts that do not yet have an entry in `2-Resources/concepts/`. Threshold: 3+ meaningful mentions
across 2+ different notes. Filter out generic terms (the schema's "do not wikilink" list applies
here too). Propose creating a concept page where the bar is met.

Output for this phase plugs into the Phase 6 proposal block as a "Lint findings" section.

### Phase 5.5: Stale notes flag

For each in-scope Area:

1. Find files in `ongoing/` and `projects/` untouched in 90+ days.
2. For each, check whether it has already been mined into `_highlights.md` (basename appears as a
   wikilink there).
3. List "fully mined + stale" candidates. Do not propose archiving anything that has not been
   mined. There might still be value to extract.

### Phase 5.7: Load pending proposal (review mode only)

Run only if `--review` was passed.

1. Look in `0-Inbox/` for files matching `_distill-pending-*.md`. If multiple exist, take the most
   recent by filename date.
2. If none found, output: *"No pending distill proposal found in `0-Inbox/`. Run `/distill all
   --proposal-only` to generate one, or invoke `/distill` interactively."* Then exit.
3. Read the file. The body is the same Phase 6 proposal block format, with one `## [Area Name]`
   block per Area.
4. Echo back a short summary: which file is loaded, how many Areas, total counts (highlights,
   entity notes, lint findings, stale candidates).
5. Skip ahead to Phase 6, processing the loaded proposal the same way as an interactive run:
   additive items applied and reported, judgment items asked.

When the proposal file's Phase 6 block is malformed (missing required sections, cannot parse), do
not guess. Show the user what looks wrong and ask whether to abort or attempt partial processing.

### Phase 6: Apply and report

**If `--proposal-only` was passed**, generate the block(s) below but do NOT write any vault
changes and do NOT wait for input. Skip directly to Phase 6.5 and write the proposal to a file.
Applying and asking are for default and `--review` modes only.

Output one block per Area, in this format:

```
## [Area Name]

**Highlights to add to _highlights.md:** [N items]

1. [kind]: [one-line distillation]
   Source: [[basename]]
   Implied wikilinks: [[entity-1]], [[entity-2]]

2. ...

**Entity notes to create:** [N]

1. `[[entity-slug]]` (person) → `2-Resources/people/entity-slug.md`
   Mentioned in: [[note-1]], [[note-2]], [[note-3]]
   Suggested role line: "Role description here."

2. ...

**Lint findings:**

- *Contradictions:* [N]
  1. `_highlights.md` says "Project X is active". Newer note [[note-name]] says it closed
     YYYY-MM-DD. Update, confirm, or leave?
  2. ...
- *Orphan notes:* [N]
  1. `1-Areas/.../some-note.md`. No inbound wikilinks, not in `_highlights.md`, not referenced
     in `CLAUDE.md`, last touched YYYY-MM-DD. Mine, link, archive, or leave?
  2. ...
- *Concept gaps:* [N]
  1. "Validation framework" mentioned in [[note-a]], [[note-b]], [[note-c]] but no
     `2-Resources/concepts/validation-framework.md`. Create?
  2. ...

**Stale + mined (archive candidates):** [N]

- `1-Areas/<area>/ongoing/some-old-note.md`, last touched YYYY-MM-DD, mined N highlights

**Optional back-fill:** Once the entity notes above exist, [N] mentions across recent notes can be
converted to wikilinks. Run `/distill <area> --backfill` separately to apply.
```

In default and `--review` modes, apply the additive items as you output the block: highlights
into `_highlights.md`, entity notes, concept pages. Mark each one applied. The judgment items
stay as questions and wait for answers: lint contradictions ("Update, confirm, or leave?"),
orphan dispositions ("Mine, link, archive, or leave?"), stale + mined archive candidates, and
ambiguous mentions. Act on the answers; for declined items, drop them (do not ask follow-ups).

If the user overrides an applied item ("drop that highlight", "that entity note is wrong"),
correct it on the spot and say so. The report is what makes that a one-line fix.

When creating `_highlights.md` for the first time in an Area, use this skeleton:

```markdown
---
type: reference
created: YYYY-MM-DD
status: active
---

# [Area Name]: highlights

Curated forward-relevant items for this Area. Sourced from chat-imports, ongoing notes, and project
closeouts. Updated by `/distill`.

## Decisions

## Frameworks and models

## Facts

## Templates and artifacts

## Contacts

## Open threads
```

Group new items under the matching section. Each entry: one-line distillation + source wikilink.
Keep it scannable. This is a landing page, not a transcript.

When creating an entity note, use the schema's skeleton for the type (people, project, company,
concept, decision). Set `created`, `type`, and `aliases` (if any). Body: one paragraph of context
plus an "Active threads" section with wikilinks to the source notes that justified creation.

### Phase 6.5: Write proposal file (proposal-only mode)

Run only if `--proposal-only` was passed.

1. Compose a single markdown document containing:
   - YAML frontmatter with `created`, `window` (the `--since=Nd` value or default), `scope`
     (areas processed), and `status: pending`
   - A short summary header (areas, total counts)
   - One `## [Area Name]` block per Area, in the exact format specified in Phase 6 above
2. Write it to `0-Inbox/_distill-pending-{YYYY-MM-DD}.md`. If a file with that name already
   exists (multiple runs in one day), append a suffix like
   `_distill-pending-{YYYY-MM-DD}-2.md` rather than overwriting.
3. Skip Phase 7 entirely.
4. Proceed to Phase 8.5 wrap-up.

Frontmatter skeleton:

```markdown
---
type: distill-proposal
created: YYYY-MM-DD
window: 7d
scope: [Area1, Area2, Area3]
status: pending
generated_by: /distill --proposal-only
---

# Distill proposal: YYYY-MM-DD

Areas: N. Highlights: N. Entity notes: N. Lint findings: N. Stale candidates: N.

To review and apply: run `/distill --review`.

---

## [Area Name]
...
```

### Phase 7: Optional back-fill

Only if the user ran `/distill <area> --backfill` (or said yes to the offer in Phase 6):

1. For each newly created entity note, walk recent notes in the Area.
2. Find every plain-text mention of the entity (canonical name + aliases).
3. Apply the replacements, then report a per-note diff summary. The edits are surgical and
   revertible; if the user wants some left as plain text, put those back on request.

Skip back-fill into `archive/chat-imports/` files. Those are immutable per the import convention.

### Phase 8: Wrap-up

```
Distill complete.
- Areas processed: [list]
- Highlights added: [count by Area]
- Entity notes created: [count, with paths]
- Lint findings: [N contradictions / N orphans / N concept gaps] ([N resolved / N deferred])
- Notes flagged stale: [count]
- Back-fill applied: [Y/N, count if Y]
```

If `--review` was used, also move the source pending file from
`0-Inbox/_distill-pending-{date}.md` to
`0-Inbox/archive/distill-history/{date}_distill.md`. Create the `archive/distill-history/`
directory if it does not exist. This keeps the inbox clear and preserves a history of what was
proposed each week.

The auto-commit hook handles the commit. Do not commit manually.

### Phase 8.5: Proposal-only wrap-up

Run only if `--proposal-only` was the active mode. Replaces Phase 8.

```
Distill proposal generated.
- File: 0-Inbox/_distill-pending-{YYYY-MM-DD}.md
- Areas analyzed: [list]
- Highlights queued: [count]
- Entity notes queued: [count]
- Lint findings: [N contradictions / N orphans / N concept gaps]
- Stale candidates: [count]
- Window: [Nd]

To review and apply: /distill --review
```

Nothing in the vault is mutated by this run. The pending file is the only output. The auto-commit
hook commits the new file.

## Decision rules

- **`_highlights.md` does not exist for an Area?** Create it lazily on first promotion. Do not
  create an empty one.
- **Candidate item is borderline?** Default to skip. The user can grep the source. The bar is
  "would I be annoyed not to find this here later."
- **Entity has 2 mentions but neither is load-bearing?** Skip. The schema's bar is real role or 3+
  meaningful references.
- **Mention is ambiguous** (e.g. "Alex" could refer to more than one person)? Do not propose an
  entity note. Flag it for the user to disambiguate.
- **Conflict between chat-import digest entry and a later working note?** Trust the working note.
  The digest is a snapshot of one conversation; the working note reflects current thinking.
- **Cross-Area entity** (someone who appears in multiple Areas)? Always create in
  `2-Resources/people/`, never duplicate per Area.
- **Lint contradiction is ambiguous?** Do not auto-resolve. List both versions and ask the user
  which is current. The newer file is not always right, as sometimes a recent draft note got
  something wrong.
- **Orphan flagged but the note is genuinely just reference material** (a saved spec, a logged
  transcript)? Do not archive. Suggest moving to `raw/` if that pattern is in use, otherwise leave
  it.
- **Concept gap proposal would create a near-duplicate** of an existing entity note? Skip. Better
  to extend an existing page than fork.

## Do not

- Do not auto-stub entity notes. Per the wikilinks schema, wikilinks only point to notes that
  exist.
- Do not retrofit existing notes outside the recent window unless the user explicitly asks.
- Do not edit `archive/chat-imports/` files. They are immutable.
- Do not generate productivity metrics or analyze the user's habits. Distill is about the graph and
  the curated landing page, nothing else.
- Do not promote an item into `_highlights.md` if it is already represented there (even under a
  different phrasing). Check before adding.
- Do not ask "are you sure?" more than once per destructive action (only deletion is destructive
  here; archival moves are reversible).
- Do not run Phase 7 back-fill without an explicit `--backfill` flag or a clear "yes" from the
  user.
- Do not auto-resolve lint findings. Lint surfaces issues for review. The user decides what to fix.
- Do not flag a note as orphan during lint just because it lacks wikilinks. Check the full criteria
  (no inbound links + not in `_highlights.md` + not referenced in `CLAUDE.md` + 30+ days old).
  Many recent or genuinely-leaf notes are healthy.
- Do not touch `_index.md` or `CLAUDE.md` directly. Those are owned by the auto-index hook and
  `/refresh-context` respectively.
