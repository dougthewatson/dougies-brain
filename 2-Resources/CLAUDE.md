# CLAUDE.md: 2-Resources

This file is loaded when you start cross-cutting reference work (AI tools, frameworks, templates). Read it before creating or modifying anything in `2-Resources/`.

---

## What lives here

`2-Resources/` holds material that is useful across multiple Areas and is not owned by any single Area. It is authored by the vault owner or by the LLM as synthesis, never third-party-sourced content (that goes in an Area's `sources/` folder).

Typical contents:

- **Templates/**: reusable document shells (meeting note template, project brief, weekly review scaffold)
- **Frameworks/**: thinking models and decision frameworks you return to across contexts
- **External-Docs/**: digested or annotated reference material you have adapted (as opposed to raw third-party articles, which belong in an Area's `sources/`)
- **wikilinks-schema.md**: the vault's wikilink naming conventions
- **Entity notes**: `people/`, `companies/`, `concepts/` subfolders, created lazily as they become useful (do not create them until there is a real entity worth tracking)

---

## Provenance rule

Everything in `2-Resources/` is either:
- **You-authored** (your frameworks, your templates, your annotated reference docs), or
- **LLM-authored** (synthesis, entity notes, distilled highlights) regeneratable from source material.

Third-party content that belongs to a single Area's domain goes in that Area's `sources/`, not here. Third-party content that is genuinely cross-cutting and you have annotated or adapted belongs in `External-Docs/`.

---

## Lazy adoption

Do not create `people/`, `companies/`, or `concepts/` subfolders until you have a real entity worth a standalone note. Add subfolders when the need arises, not pre-emptively.

---

## How to work here

- Treat existing files as editable reference (these are your frameworks and templates, not immutable sources).
- When creating a new template or framework, place it in the appropriate subfolder and add a one-line entry to `_index.md` if one exists.
- When the LLM produces a cross-cutting entity note or highlights file, it belongs here rather than in a single Area.
