# Example Area (Fermentation Lab): Claude Context

> **Template note:** This is a fictional example Area included with the template repo to demonstrate
> structure and conventions. Replace every section below with content that matches your actual domain.
> Delete this callout when you're done.

---

## What this Area is

This Area covers home fermentation as a hobby practice: vegetable lacto-fermentation, water kefir,
jun tea, and small-batch hot sauce. The goal is to maintain an organized knowledge base for recipes,
active batches, equipment, and reference reading so nothing gets lost between sessions.

This is an evergreen personal hobby, not a business venture. No external deadlines, no stakeholders.

---

## Folder conventions

**`projects/`**: Time-bounded goals with a clear end state. Examples:
- A specific gift batch with a delivery deadline
- A new ferment style being trialed with a verdict at the end (keep / refine / drop)
- A piece of equipment being built or procured

Name project folders in kebab-case, descriptive of the goal: `hot-sauce-small-batch-gift-run`,
`water-kefir-starter-trial`, `fermentation-chamber-build`.

**`ongoing/`**: Evergreen authored content that stays relevant indefinitely:
- `batch-log.md`: rolling log of all active and recent batches
- `equipment-inventory.md`: what you own, where it is, what you plan to acquire
- `recipes/`: stable, tested recipe files (one per ferment type)
- `troubleshooting.md`: accumulated fixes for common failure modes

**`sources/`**: Third-party authored material you have collected. Immutable. Never edit.
- Reading notes on books (e.g., notes on a fermentation guide)
- Clipped articles, forum threads, research summaries
- Purchased recipe PDFs or downloaded resource packets

**`archive/`**: Completed projects and old chat imports. Move finished project folders here.

---

## Provenance rule (copy this to your own Area CLAUDE.md)

- **Author-owned content** (your notes, logs, recipes, decisions) goes in `ongoing/` or `projects/`.
- **Third-party content** (books, articles, others' work) goes in `sources/`. Treat as immutable.
- **LLM synthesis** (summaries, distillations, entity notes) goes in `_highlights.md` or in
  `2-Resources/`. Regeneratable, not a primary source.

---

## External working directory

> **Template note:** If this Area has files that live outside the vault (cloud storage, a local working
> folder, an external drive), register the root path and subfolder structure here. Reference an
> actual external disk root, or the configured `outputs_dir` from `config/stack.md` if that's where
> this Area's material lives. Example below.

Fermentation reference files (PDFs, downloaded guides, batch photos) are stored outside the vault, in
your configured `outputs_dir`, under `Fermentation-Lab/`:

- `photos/`: batch progress photos, organized by batch number
- `references/`: downloaded PDFs and guides (third-party; also filed in `sources/` as notes)
- `labels/`: label design files for gift batches

Use the file tools to read or reference these on demand. Do not copy binary files (photos, PDFs) into
the vault.

---

## Active context

> **Template note:** Keep this section current. It is the first thing Claude reads when you say
> "let's work on [this Area]." One tight paragraph per major thread. Update at the end of work sessions.

- Batch B-24 (jalapeño hot sauce) is in active fermentation as of 2026-05-01. Taste-test target
  is June 2. Project folder: `projects/hot-sauce-small-batch-gift-run/`.
- Batch B-25 (ginger beer) started 2026-05-15. Burping daily. No project folder; this is a routine
  batch logged in `ongoing/batch-log.md`.
- Equipment wish list: fermentation chamber (mini-fridge mod) and a pH meter. No purchase decision made.

---

## People

- **Priya Nakamura**: friend who taste-tests every batch before it ships and gives blunt heat-level feedback.
- **Wes Almeida**: vendor at the Saturday farmers market who supplies fresh chili peppers in season.

`/meeting-ingest` matches meeting attendees against each Area's People section to route meetings here.

---

## Things Claude should know about this domain

- Brine percentages matter. Always calculate salt by weight of the total recipe (vegetables + water),
  not by volume or guesswork.
- Non-iodized salt only. Iodine inhibits lactobacillus.
- "Active fermentation" means the airlock is bubbling. Once it stops and pH is below 3.5, the batch
  is done. Without a pH meter, taste and smell are the practical check.
- This is a low-stakes hobby. Default to practical suggestions over perfectionism.

---

## What NOT to assume

- This is not a commercial operation. Do not frame outputs as if scaling for production or sale.
- Recipes in `sources/` are collected reference material, not proven personal recipes. The
  author-tested recipes live in `ongoing/recipes/`.
- Equipment quantities and locations in `ongoing/equipment-inventory.md` are the source of truth.
  Do not invent gear that isn't listed there.
