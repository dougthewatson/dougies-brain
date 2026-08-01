---
description: Ingest meeting transcripts and summaries from your connected meeting sources, then chain into interactive digest (extraction + approval + routing). One-stop meeting flow.
argument-hint: [--since=Nd | --uuid=<id> | --paste | --redact "<what>"] [--source=<source_key>|all] [--dry-run] [--no-digest]
---

# /meeting-ingest

> Read `config/stack.md`. This command uses the `meeting_source`, `transcription`, `task_manager` and `outputs_dir` roles. For each role this command actually exercises on the current run: if it is unset or its tool is not connected, stop and tell the user what to connect and how (native MCP, then Composio, then manual paste as a fallback), then exit. This command never writes to `status_board`, so that role is irrelevant here. Do not assume any specific product.

> **First action (session-title anchor).** Before any tool calls or other output, emit a single user-facing line in this exact form so the session-title summarizer locks onto it:
>
> `# Meeting Ingest: <YYYY-MM-DD HH:MM>`
>
> Use the current local time. No other prefix, no trailing prose on that line. Then continue with Phase 0 normally.

You are running the vault's meeting pipeline. The goal is to pull new meeting content from each connected source, deduplicate against what is already in the vault, route to the right Area, file consistently, then chain straight into interactive digest so decisions, questions, ideas, and actions get extracted, approved, and routed in the same session. `/meeting-digest` is still callable on its own for one-off re-runs.

**Read this entire command before acting.** Several phases require state checks (registry, per-Area CLAUDE.md, skip list) that affect later steps.

## Role-to-source mapping

Read `config/stack.md` to resolve which tool serves each role. The command supports multiple meeting sources. Common patterns (these are examples, not requirements):

| Role | Typical tools | Pull strategy |
|---|---|---|
| `meeting_source` (video platform) | Zoom, Google Meet, Teams | API search by time window, then fetch assets per meeting ID |
| `meeting_source` (status board) | Notion | Query meeting notes database by last-edited time, fetch each page |
| `meeting_source` (AI summary email) | Gemini-in-Gmail | Search inbox for AI summary emails, extract linked document URL, read document |
| `meeting_source` (transcript share email) | Otter.ai | Search inbox for summary emails, parse summary from email body |
| `meeting_source` (manual) | none | User pastes content interactively |

If `config/stack.md` has no `meeting_source` set, tell the user: "No meeting source is configured. Edit `config/stack.md` and set `meeting_source` to your video-call platform or transcript tool. Then reconnect the relevant MCP (or add via Composio)." Then exit.

## Modes

- **Default:** `/meeting-ingest`. Sweeps all sources since the last successful run (read from registry; fall back to 24h if no prior run).
- **Window override:** `--since=7d`. Explicit lookback window.
- **One-off:** `--uuid=<meeting-id>` or `--id=<notes-page-id>`. Pull a specific meeting and exit.
- **Manual paste:** `--paste`. Interactive flow (see Phase 6).
- **Source filter:** `--source=<key>` (e.g., `zoom`, `notion`, `gemini`, `otter`, `manual`, or `all`). Restrict to one source. Default `all`.
- **Redact:** `--redact "<phrase or context>"`. Applied to the manual-paste flow only. Stages content outside the vault, applies redaction, then writes the redacted version to vault.
- **Dry run:** `--dry-run`. Produce the ingest plan without writing any files. Output the list of meetings that would be filed and their target paths. Skips the digest chain.
- **No digest:** `--no-digest`. Ingest only, do not chain into digest. Use when you want to file meetings now and run digest later.

## Skip list

Always exclude these from automatic pulls (they may still be ingested manually if the user explicitly passes a UUID/ID):

1. **Solo single-attendee test meetings.** `attendee_size: 1` AND topic matches a generic default meeting title (e.g., the platform's default "Personal Meeting Room" label), duration under 5 min. These are test artifacts.
2. **Meetings with no transcript and no summary.** `has_transcript: false` AND `has_summary: false`. Nothing to file.
3. **Status-board calendar placeholders.** Notes pages with an empty or stub title indicating an auto-created placeholder from calendar sync. Check your notes tool's pattern (e.g., a trailing arrow character or a title of only whitespace).

You may add personal skip rules to `config/stack.md` under a `meeting_skip_patterns` key (list of attendee name fragments or topic patterns to always exclude). The command reads that list in Phase 0.

## Phases

### Phase 0: Parse args and load registry

1. Read flags. Resolve mode.
2. Read `config/stack.md`. Confirm all required roles are set. If any role used by this run is unset, stop with the graceful error described in the role-to-source mapping section above.
3. Read the registry at `.claude/state/meeting-ingest/imported-meetings.jsonl` (one JSON object per line: `{match_key, sources: [...], filed_paths: [...], imported_at, area}`). Create the directory and empty file if missing.
4. Load any `meeting_skip_patterns` from `config/stack.md`.
5. Determine the lookback window:
   - If `--since` provided, use that.
   - Else find the latest `imported_at` in the registry; use one minute before it as the window start.
   - If registry empty, default to 24h.
6. State the plan in one line: `Ingesting from [sources] since [window-start].`

### Phase 1: Pull from each source

For each source configured in `config/stack.md` and not excluded by `--source`, run the source-specific query using its MCP tool. The exact MCP calls depend on which tool is connected; the logic below describes what to fetch regardless of product.

**Video platform (e.g., Zoom):**
1. Search meetings in the window (UTC timestamps).
2. For each result, capture: meeting ID/UUID, topic, actual start time, actual end time, attendees, host, `has_transcript`, `has_summary`.
3. Apply skip list (including any patterns from `config/stack.md`). For surviving meetings, fetch assets per meeting ID. Capture the AI summary (markdown) and transcript items.
4. Note: many video platforms return `start_time` as the SCHEDULED time. Prefer the actual start time when the API provides it separately.

**Status board (e.g., Notion):**
1. Query the meeting notes database filtering by last-edited time within the window. If date-filter syntax errors, list all and filter client-side by last-edited field.
2. Apply skip list (drop stub/placeholder entries).
3. For each remaining row, fetch full page content.

**AI summary email (e.g., Gemini-in-Gmail):**
1. Search the inbox for AI meeting summary emails from the sender address configured in `config/stack.md` (e.g., `gemini-notes@google.com`), filtered to the window.
2. For each thread, fetch the full message body.
3. Extract any linked document URL (look for `docs.google.com/document/d/<id>` or equivalent).
4. Fetch the linked document content via the appropriate Drive/Docs MCP.

**Transcript share email (e.g., Otter):**
1. Search the inbox for transcript summary emails from the sender address configured in `config/stack.md`, filtered to the window.
2. Filter to summary emails (subject starts with a summary-type prefix). Skip share-notification emails.
3. For each, fetch the full message body. The summary is inline; no need to follow the link.

**Manual paste:** skip in Phase 1; handled separately in Phase 6.

### Phase 2: Compute match key per meeting

For each meeting candidate, compute a match key (used to dedupe across sources and runs):

1. **Primary** (preferred): `<YYYY-MM-DDTHH:MM rounded to 5min>_<sha1(sorted(attendee names lowercased))[0:8]>`
2. **Fallback if no attendees:** `<YYYY-MM-DDTHH:MM rounded to 5min>_<source>_<source_id>`
3. **Fallback if no time:** `manual_<sha1(first 200 chars of content)>`

Store the match key for the next phase.

### Phase 3: Dedupe

For each candidate:

1. Look up the match key in the registry.
2. If present, this meeting is already imported. Skip writing a new file but if the source is not in the registry's `sources` list, add it (and write the new source file alongside the existing meeting folder, same `<date>/` directory).
3. If absent, this is a new meeting. Continue to Phase 4.

### Phase 4: Route to Area

For each new meeting, determine the Area folder:

1. **By attendee match (preferred):** Read each Area's `CLAUDE.md` `## People` section. Match meeting attendees against listed names. Attribute to the Area with the most attendee matches. Tie-breaker: prefer Areas with active projects.
2. **By topic keyword (fallback):** Match meeting title against Area names and known project names from `_index.md`.
3. **Default:** `0-Inbox/meetings/<date>/` if no Area matches confidently.

Use the meeting's actual start date (not scheduled date) for the folder name: `<Area or 0-Inbox>/ongoing/meetings/raw/<YYYY-MM-DD>/` (or `0-Inbox/meetings/<YYYY-MM-DD>/`).

### Phase 5: Write files

For each new or augmented meeting, write to the target folder:

1. **`<source>-summary.md`**: the AI summary from this source. Strip any platform-internal task-tracking link patterns (e.g., Zoom task links, Otter task references) from the content.
2. **`<source>-transcript.md`**: the full transcript if available. Collapse consecutive turns by the same speaker, format as `**Speaker** (HH:MM:SS): text`.
3. **`_meeting.yaml`**: match-key and canonical metadata. Format:
```yaml
match_key: <key>
canonical_title: <human-readable title; pick the cleanest of the source titles>
date: YYYY-MM-DD
start_time: <ISO with timezone>
end_time: <ISO with timezone>
attendees: [list]
sources:
  - source: <source_key>
    source_id: <platform_id>
    files: [<source_key>-summary.md, <source_key>-transcript.md]
imported_at: <ISO>
imported_by: meeting-ingest
```

If `_meeting.yaml` already exists for this folder, MERGE: add the new source to the `sources` array, update `imported_at` to now. Do not overwrite `canonical_title` or `attendees` unless they are missing.

**Frontmatter on each markdown file:**
```yaml
---
type: meeting-<summary|transcript>
source: <source_key>
match_key: <key>
meeting_topic: "<title>"
date: YYYY-MM-DD
attendees: [list]
---
```

**Banned content rules** (apply to all generated copy in the files):
- Apply the writing rules from the Communication style section of the root CLAUDE.md, including
  any hard rules the user added.

### Phase 6: Manual paste flow (only when `--paste`)

1. Ask the user: "Paste the meeting content. End with a blank line and `EOF` on its own line."
2. After paste, ask three short questions in sequence:
   - "Meeting title?"
   - "Date and start time? (ISO 8601, e.g. 2026-05-02T14:00 with timezone)"
   - "Attendees? (comma-separated, or 'unknown')"
3. If `--redact` was passed, stage the content in a temporary location outside the vault, apply the redaction (replace the redaction phrase with `[REDACTED]`), then read the redacted version. Write the redaction summary to `.redaction-audit/pending/<date>-<slug>.md` per the redaction protocol (do NOT describe redacted content in chat or commit messages). After the staging file is consumed, delete it.
4. Compute match key (Phase 2 fallback chain), route to Area (Phase 4), write to vault as `manual-content.md` (no separate transcript/summary split for manual).

### Phase 7: Per-Area CLAUDE.md auto-update

For each Area that received a meeting in this run:

1. Check if `1-Areas/<Area>/CLAUDE.md` contains the marker `<!-- meeting-ingest-block -->`.
2. If absent, append the standard block to the end of the Area's CLAUDE.md file:

```markdown

<!-- meeting-ingest-block -->
## Meeting ingest

Meetings filed under this Area land in `ongoing/meetings/raw/<YYYY-MM-DD>/`. Each meeting folder contains:

- `<source>-summary.md` and `<source>-transcript.md` per source
- `_meeting.yaml` with match-key, canonical title, attendees, and sources list

Pulled by `/meeting-ingest` (on demand or scheduled). Distilled into highlights via `/distill`. Routed into decisions, questions, and actions via `/meeting-digest`.
<!-- /meeting-ingest-block -->
```

The auto-commit hook captures this. No manual intervention.

### Phase 8: Update registry

For each meeting filed (new OR augmented), append a JSON line to `.claude/state/meeting-ingest/imported-meetings.jsonl`:

```json
{"match_key": "...", "sources": ["<source_key>", "<source_key2>"], "filed_paths": ["1-Areas/<Area>/ongoing/meetings/raw/<YYYY-MM-DD>/<source>-summary.md", "..."], "area": "<Area>", "imported_at": "<ISO>"}
```

If a registry line for this match_key already exists, write a new line that supersedes it (do not try to edit in place; the latest line wins on read).

### Phase 9: Output ingest summary

Print a single tight block:

```
Ingested N meetings from [sources, counts].
  - <YYYY-MM-DD> <Title> (<Area>) [source, source]
  - ...

Skipped M meetings: [breakdown by skip reason]
```

If `--dry-run`, print the same block prefixed with `DRY RUN: no files written.` and STOP (do not run Phase 10).

If `--no-digest`, stop after this phase and print `Ingest complete. Digest chain skipped (--no-digest). Run /meeting-digest separately when ready.`

### Phase 10: Chain into interactive digest

If at least one meeting was newly filed in Phase 5 (augmenting an existing meeting with an additional source does NOT trigger a re-digest; it is already been digested), continue.

1. Collect the set of match_keys for NEW meetings filed in this run (not the augmented ones).
2. Read `.claude/commands/meeting-digest.md` and follow its phases in order, with these scoping rules:
   - **Skip Phase 0's window calculation.** Use the match_keys from step 1 as the queue.
   - **Phase 1:** locate the folder for each match_key (via registry `filed_paths` or by walking `1-Areas/*/ongoing/meetings/raw/*/` and `0-Inbox/meetings/*/`). Skip the windowed walk.
   - **Phases 2 through end:** run normally: extract structured items, present the approval list in chat, wait for the user's routing instructions, execute routing, update the digest registry, print the digest summary.
3. If Phase 10 is reached but the match_key set is empty (e.g., everything in this run was an augmentation or a skip), print `No new meetings to digest.` and exit cleanly.

The interactive approval prompt in digest Phase 4 is the natural pause point. The user reviews, gives routing instructions, and routing executes in the same session.

## Do not

- Do not process meetings matching any skip list pattern (skip list from this file plus any patterns in `config/stack.md`), even on manual run, unless the user explicitly passes the UUID/ID.
- Do not describe redacted content in chat or commit messages. Audit summaries go to `.redaction-audit/pending/` only.
- Do not auto-create new Areas. If routing cannot find a confident Area, file to `0-Inbox/meetings/`.
- Do not write to the status board in this command. That is `/meeting-digest`'s job.
- Do not run `/distill` automatically after this. Distill is a separate, higher-cadence operation.
- Do not use Bash redirects (`>`, `>>`) to write vault files. Use the `Write` tool so the auto-commit hook captures the change.
