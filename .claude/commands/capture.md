---
description: File a new piece of content into the right place in the vault
---

# /capture

Read `config/stack.md`. This command does not require an external tool role, but if the content being captured relates to tasks or project tracking, note that the `task_manager` role is where captured tasks publish. If that role is unset and the content is task-oriented, stop and tell the user what to connect and how (native MCP, Composio, or manual), then exit. Do not assume any specific product.

You are helping the user file something into the vault. The goal is to minimize friction: capture first, taxonomy second.

## What to do

1. **Ask what is being captured** if the user hasn't already pasted or described it. Keep the question short: "What are you capturing?"

2. **Read the content carefully.** Identify:
   - What kind of thing it is (idea, meeting note, decision, reference doc, task, contact info, link, etc.)
   - Which Area it relates to (match against the user's active Areas listed in their root CLAUDE.md)
   - Whether it's time-bounded (project) or evergreen (ongoing) or unclear

3. **Propose a destination.** State the proposed file path and a proposed filename. Use the naming convention: lowercase with hyphens, dates as YYYY-MM-DD when relevant. Examples:
   - `1-Areas/<Area>/ongoing/<subfolder>/YYYY-MM-DD-descriptive-name.md`
   - `1-Areas/<Area>/projects/<project>/YYYY-MM-DD-note.md`
   - `0-Inbox/YYYY-MM-DD-descriptive-name.md`

4. **Default to Inbox when uncertain.** If you can't confidently place something in an Area, file it in `0-Inbox/` with a descriptive filename. Don't agonize. Sorting happens in the weekly review.

5. **Confirm before writing.** One short sentence: "Filing as `[path]`, proceed?" Wait for yes.

6. **Write the file.** Format the content as a clean markdown note:
   - H1 title at the top
   - One-line context if the content lacks it (date, source, why it's here)
   - The content itself, lightly formatted for readability
   - Don't add commentary or interpretation unless the user asked for it

7. **Confirm completion.** "Filed at `[path]`." That's it. No summary, no recap.

## Decision rules

- **Has a clear Area + clear subfolder?** → File there.
- **Has a clear Area but unclear subfolder?** → File in that Area's `ongoing/` root or propose a new subfolder.
- **Multiple plausible Areas?** → Ask the user which.
- **No clear Area?** → Inbox.
- **Looks like a finished deliverable (PDF, exported doc)?** → Stop. It belongs in its final home outside the vault: the folder where it will be used (a client's shared folder, the Area's external working folder), or the configured `outputs_dir` from `config/stack.md` as a fallback (if unset, suggest running `/setup`). Ask if that's what they mean.

## Don't

- Don't reorganize existing files while capturing.
- Don't update indexes during capture (that's a separate job).
- Don't ask more than one clarifying question unless absolutely necessary.
- Don't add tags, frontmatter, or metadata the user didn't ask for.
- Don't summarize the content back to the user, they just gave it to you, they know what it is.