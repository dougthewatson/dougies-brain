# Wikilinks Schema

Convention for using `[[wikilinks]]` in this vault. Forward-looking -- applies to any wikilinks created from this point on by either you or Claude. Existing notes are not retrofitted; the convention lands as new content gets added.

---

## Purpose

Wikilinks should make the Obsidian graph surface meaningful connections, not generate noise. The schema exists so that:

1. Wikilinks always resolve (no broken or auto-stubbed targets)
2. Naming is consistent and searchable
3. The graph reflects real relationships, not casual mentions
4. Adding a wikilink doesn't create maintenance debt

---

## Core principles

**Wikilink to entities, not concepts.** A wikilink should point to something that has its own dedicated note: a person, a project, a decision, a recurring external entity. Don't wikilink generic terms like `[[process]]` or `[[feedback]]` -- those are tags or just text.

**Entity notes are intentional, never auto-stubbed.** Wikilinks only point to notes that already exist. Create the entity note first when you have something worth saying about that entity. If an entity is mentioned but has no note yet, leave it as plain text; don't create a wikilink that resolves to nothing.

**Tags vs wikilinks:**
- Tags (`tags: [project/area-name]` in frontmatter, or `#tag` inline) say "this note is *about* X."
- Wikilinks say "this note *references* the entity X."
- A note can have both. A meeting note might be tagged `#project/client-work` AND wikilink to `[[person-name]]` because that person attended the meeting.

**Folder navigation vs wikilinks:**
- `_index.md` and `CLAUDE.md` files are navigated via folder structure, not wikilinks. Don't wikilink to them.
- Notes inside a project folder reference each other by basename wikilink, not by relative path.

---

## Naming conventions

**Filenames are the wikilink targets.** Always:
- kebab-case lowercase: `person-name.md`, `project-name.md`
- ASCII only (no accents, no special chars)
- Date-prefixed for temporal notes (meetings, events): `2026-04-15-meeting-summary.md`
- No spaces, no underscores, no camelCase

**Wikilink syntax:**
- Default: basename only -- `[[person-name]]`. Obsidian resolves any unique basename across the vault.
- Disambiguate with path fragment when basenames clash: `[[1-Areas/AreaName/decisions/decision-slug|display text]]`
- Use display alias when the basename is awkward in prose: `[[person-name|First Name]]`
- Block reference (`[[note#heading]]`) is allowed but rare -- use only when linking to a specific section matters

**Obsidian frontmatter aliases:**
For entities with multiple known names (renames, abbreviations, casual forms), set aliases on the canonical note:
```yaml
aliases:
  - OldName
  - Abbreviation
```
This lets `[[OldName]]` resolve to the canonical note in Obsidian.

---

## Entity types and where they live

### People → `2-Resources/people/<slug>.md`

Cross-cutting. A person who appears in multiple Areas shouldn't have three separate notes.

Create when:
- The person appears in 3+ notes, OR
- The person plays a defining role in an Area (advisor, co-founder, key client, key vendor)

Skeleton:
```markdown
---
type: person
aliases: [First, Nickname]
created: YYYY-MM-DD
role: Role description, Area (status)
relationship: business | personal | professional
---
# Full Name

## Context
<one paragraph: who they are, how you know them, current status of the relationship>

## Active threads
- [[date-meeting-or-project-note]]

## Mentions
- (back-links surface here automatically via Obsidian)
```

### Projects → `1-Areas/<Area>/projects/<project-slug>/<project-slug>.md`

Hub note inside the project folder, named the same as the folder. Other notes in the folder are children.

```
1-Areas/AreaName/projects/project-name/
  project-name.md          <- wikilink target
  2026-04-24-scoping.md
  meeting-notes-2026-04-30.md
```

`[[project-name]]` from anywhere in the vault resolves to the hub.

### Companies / organizations → `2-Resources/companies/<slug>.md`

External entities referenced repeatedly:
- Customers: `[[customer-name]]`
- Competitors: `[[competitor-name]]`
- Vendors: `[[vendor-name]]`
- Government bodies: `[[regulatory-body-name]]`
- Agencies: `[[agency-name]]`

### Decisions → `1-Areas/<Area>/decisions/<date>-<slug>.md`

A wikilink target for "the time we decided X." Date-prefixed.
- `[[2026-02-09-partnership-structure]]`
- `[[2026-04-22-project-time-allocation]]`

Decisions get their own folder per Area when there are 3+; otherwise live as date-prefixed notes in `ongoing/`.

### Concepts → `2-Resources/concepts/<slug>.md`

Sparingly. Only for recurring frameworks or terms with non-obvious meaning in your context:
- `[[framework-name]]` -- a specific named methodology you return to repeatedly
- `[[your-coined-term]]` -- vocabulary you've coined that appears across notes

Most "concepts" are better expressed as tags.

### Conversations / source materials

Imported chat files in `archive/chat-imports/` are wikilinked from a derived note when they're a primary source for a claim or decision. Don't wikilink them casually -- the graph would explode with hundreds of archive nodes.

---

## When to add aliases

Set `aliases` in the canonical note's frontmatter when the entity has:

- **Renaming history**: OldName → NewName
- **Common abbreviations**: Org → Full Organization Name
- **Casual forms**: "the pilot project" → `[[project-slug]]`

This lets you write naturally in notes and have Obsidian resolve to the canonical note.

---

## When NOT to wikilink

- Generic verbs and processes (`[[review]]`, `[[feedback]]`, `[[framework]]`) -- use plain text or tags
- Dates on their own -- use date-prefix in filename instead
- Hashtag-shaped categorization (`[[project-product]]`) -- that's a tag, not a wikilink
- Section anchors within the same note -- use Obsidian heading link syntax `[[#heading]]`
- Back-references in `archive/` -- too noisy for the graph

---

## Frontmatter conventions

Recommended fields on entity notes:

```yaml
---
type: person | project | decision | company | concept | meeting | reference | conversation
aliases:
  - other names
created: YYYY-MM-DD
status: active | archived | superseded
related:
  - "[[other-note-1]]"
  - "[[other-note-2]]"
---
```

- `type` and `aliases` are the high-value fields
- `related` is optional but creates a structured forward-link section that Obsidian renders as a list
- `status: archived` on a person note (e.g., past advisor) lets you filter the graph

---

## Retrofit policy for the existing vault

If your vault has pre-existing notes that predate this schema, a mass retrofit is not required. This schema governs:

1. Any wikilink Claude generates from this point on
2. Any wikilink you add when working on a note
3. The structure of new entity notes when they're created

Existing wikilinks that don't yet resolve are expected -- the targets get created lazily as you encounter specific entities worth deepening.

---

## Building your entity list (lazy, on-demand)

Identify entities across your vault that appear repeatedly and would benefit from a hub note. Good candidates:

**High-value (create soon):**
- People who appear in 3+ notes across Areas
- Key client or partner organizations
- Active projects without a hub note
- Recurring decisions or policy frameworks

**Defer until needed:**
- People or companies mentioned only in passing
- Concepts that are adequately handled by tags
- Historical entities with no ongoing relevance

Don't create deferred entity notes in advance. Create them when the next note that would link to them gets written.

---

## Decision tree (quick reference)

When writing a note and considering whether to wikilink something:

1. **Is the thing a discrete entity (person, project, company, decision)?** If no -- plain text or tag.
2. **Does a note for it already exist?** If no -- plain text. Don't create a wikilink to a non-existent note.
3. **Is it the canonical name or an alias?** Use canonical basename, or alias if the canonical note has it in `aliases`.
4. **Will the link be useful in graph view?** If the link is one-off and not useful for navigation, leave it as text.
