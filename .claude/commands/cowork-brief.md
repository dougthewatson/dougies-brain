---
description: Generate a self-contained briefing file in a destination folder so a Claude Cowork session gets full task context and saves outputs exactly where they belong
---

The user wants to hand a task to Claude Cowork (the desktop app's Cowork tab, or a cloud Cowork session on their phone). Cowork cannot see this vault: it reads no CLAUDE.md, hooks, memory, or MCP config. Everything it needs must travel in one briefing file placed in the folder where the output belongs. Your job: pick the destination, gather scoped context, write the brief there, and hand back paste-ready kickoff prompts.

Arguments: a task description. It may name a client, Area, or explicit destination. If the destination is ambiguous, act on the most plausible one and state the assumption.

## Step 1 — Resolve the destination folder

All routing judgment happens HERE, at brief time, using the vault's output destination rules. The brief pins exactly one folder; Cowork never routes. If the destination can't be resolved confidently, ask the user before writing anything (Cowork has no ask-the-user fallback mid-task).

The brief goes where the OUTPUT should land. Decision order:

1. Work for a specific client or external party → their shared folder (check the Area's CLAUDE.md for registered external directories)
2. Area work with an external working folder → that folder
3. Vault-destined output → the exact vault folder (e.g. `1-Areas/<Area>/projects/<project>/`)
4. No proper home → the `outputs_dir` configured in `config/stack.md`, under `<Area>/` (fallback only; if unset, suggest `/setup`)

## Step 2 — Gather scoped context

Read what the task needs, nothing more: the Area CLAUDE.md, relevant project files, and any constraints already decided (naming rules, prior decisions, people involved). Distill; do not paste whole files.

## Step 3 — Write the brief

Filename: `_cowork-brief-YYYY-MM-DD-<short-kebab-topic>.md`, written into a `_cowork/` subfolder of the destination (create it if missing). Briefs live there so they never clutter the working folder; outputs go to the destination folder itself. Structure:

```markdown
# Cowork brief: <topic>

Read this whole file before starting. You may be reading it from a connected
local folder (desktop) or via a cloud-drive connector (phone session); the
instructions are the same either way.

## Task
<What to produce. Definition of done. Concrete.>

## Context
<Everything needed to do the task well, self-contained. Facts, constraints,
decisions already made, names and dates spelled correctly. No references to
files outside this folder — you cannot reach them.>

## Output spec
- File(s): <exact filename(s) and format>
- Location: the parent folder of this _cowork folder<, or named subfolder>
- Quality bar: <e.g. client-ready, internal draft>

## Style rules
<The user's writing conventions relevant to the artifact. Pull from the root
CLAUDE.md communication-style section for outward-facing outputs.>

## Guardrails
- Create new files only. Do not modify or delete existing files in this folder
  unless this brief names them explicitly.
- Do not touch other folders even if connected.
- When finished, list every file you created at the end of your reply.
```

If the destination is a VAULT folder, add to Guardrails:
- Follow vault naming: lowercase-with-hyphens, YYYY-MM-DD dates, H1 title first line
- Never write into any `sources/` folder
And tell the user (not the brief) that Cowork's writes will sit uncommitted until the next Claude Code session commits them, and to avoid a concurrent Code session editing the same files.

## Step 4 — Hand off

Reply with:
1. Where the brief was written (full path)
2. TWO paste-ready Cowork prompts, each in its own code block, so the user can kick off from whatever device they're holding:

   **Desktop (folder connection):**
   "Connect this folder: <destination path>. Then: Read _cowork/_cowork-brief-<name>.md and complete the task exactly as specified. Follow its output spec, style rules, and guardrails."

   **Phone / cloud session (cloud-drive connector):**
   "Using the <Google Drive / relevant> connector, open the folder <path as it appears in the cloud drive>. Read _cowork/_cowork-brief-<name>.md there and complete the task exactly as specified. Save the output back to that same folder using the connector, following the brief's output spec, style rules, and guardrails."

   The phone variant only works when the destination lives on a cloud drive with a Cowork connector. Otherwise omit it and say phone kickoff isn't available for this task.
3. Any assumption you made about the destination

Briefs are disposable. They accumulate in `_cowork/`; the user or a weekly review sweep deletes them. Do not instruct Cowork to self-delete the brief (deletion triggers a permission prompt and fails silently if the session dies early).
