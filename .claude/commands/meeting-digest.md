---
description: Extract decisions, questions, ideas, and action items from new meetings ingested by /meeting-ingest. Interactive approval, then routing to vault, status board, and task manager. Usually invoked automatically by /meeting-ingest Phase 10; standalone for one-off re-runs.
argument-hint: [--since=Nd] [--meeting=<match-key|folder>] [--area=<name>] [--dry-run] [--no-mirror]
---

# /meeting-digest

Read `config/stack.md`. This command requires the `task_manager` role; if it is unset or its tool is not connected, stop and tell the user what to connect and how (native MCP, then Composio, then manual), then exit. Do not assume any specific product.

Check `config/stack.md` now and resolve:
- `task_manager`: where action items are published (required for routing A items)
- `status_board`: optional external mirror of the decisions, questions and ideas this command has already written to the vault
- `meeting_source`: where ingested meetings come from (informational; digest reads vault files produced by /meeting-ingest)

If `task_manager` is unset: tell the user to set it in `config/stack.md` (e.g. Asana, Linear, Todoist, Notion) and exit.
If `status_board` is unset: skip every mirror step silently and route to the vault only, including for Areas that have `decisions_db` configured. Do not warn and do not ask for confirmation. Vault routing is the complete outcome; the mirror only ever duplicated it.

---

You're running the meeting digest. The job is to read meetings filed by `/meeting-ingest`, extract structured items (decisions, open questions, ideas, action items, journal entries), and route them through an interactive approval flow into vault + status board + task manager.

`/meeting-ingest` Phase 10 chains into this command automatically with the new match_keys from that run pre-loaded as the queue. Standalone invocation is for one-off re-runs (a specific past meeting, a windowed catch-up, or after `--no-digest` was used).

**Read this entire command before acting.** The phases depend on each other and the routing rules vary per Area.

## Modes

- **Default:** `/meeting-digest`: process every meeting since the last successful digest run (read from registry; fall back to 24h). Interactive approval required.
- **Window override:** `--since=7d`
- **One-off:** `--meeting=<match-key>` or `--meeting=<folder-path>` (e.g. `--meeting=2026-04-24T15:25_9b98f944` or `--meeting=1-Areas/MyArea/ongoing/meetings/raw/2026-04-24/`)
- **Area filter:** `--area=<AreaName>` (restricts to that Area's meetings only)
- **Dry run:** `--dry-run`: produce the extraction list and proposed routing without writing anything
- **Skip mirror:** `--no-mirror`: do extractions, but skip writing to the status board Meetings DB
- **Chained from ingest:** when invoked by `/meeting-ingest` Phase 10, treat the ingest-supplied match_key set as the queue and skip Phase 0's window calculation.

## Routing rules (the heart of this command)

### Per-Area routing

Routing targets (status board DBs) are configured per Area in `config/stack.md` under `areas.<AreaName>`. Each Area entry may define:

```yaml
areas:
  MyArea:
    decisions_db: "<status-board DB ID or URL>"
    ideas_db: "<status-board DB ID or URL>"
    meeting_mirror_db: "<status-board DB ID or URL>"
```

Areas without these fields get vault-only routing (no status board writes).

At runtime: read `config/stack.md`, collect the list of Areas that have `decisions_db` set. Those are the "mirror Areas." All other Areas are vault-only.

### Vault routing (every Area)

| Item type | Path |
|---|---|
| Decision | `1-Areas/<Area>/ongoing/decisions/<YYYY-MM-DD>_<slug>.md` (or `0-Inbox/decisions/` if 0-Inbox meeting) |
| Open question | `1-Areas/<Area>/ongoing/questions/<YYYY-MM-DD>_<slug>.md` |
| Idea | `1-Areas/<Area>/ongoing/ideas/<YYYY-MM-DD>_<slug>.md` |
| Journal | `1-Areas/<Area>/ongoing/journal/<YYYY-MM-DD>_<slug>.md` |

### Action item routing (everywhere)

Single-sink to the configured `task_manager`. Project mapping stored in `.claude/state/meeting-digest/project-mapping.json`. If the mapping doesn't yet have an entry for this Area, prompt the user for the project ID or URL once, then save it for future runs.

For 0-Inbox meetings: routes to a generic "Inbox" project in the task manager.

If the task manager MCP is unauthenticated, surface the auth prompt and wait. Don't drop tasks.

### Status board meeting mirror (mirror Areas only)

For every meeting from a mirror Area filed by ingest, create one row in the corresponding Meetings DB:

- **Status-board-sourced meetings:** stub-and-link. Page properties only (Title, Date, Source=status-board, Source URL=original page URL, Match Key, Attendees, Vault Path, Status=Digested). Body: "See original page (link above) and vault file for full content."
- **Other sources (meeting_source, transcription, manual):** full mirror. Page properties + body = vault summary file content + transcript file content (if present).

Mark `Status=Digested` after the digest runs. Ingest-only meetings should be `Status=Ingested` until digested.

### Vault frontmatter on routed items

Every routed vault file gets frontmatter:

```yaml
---
type: decision | question | idea | journal
date: YYYY-MM-DD
source_meeting:
  match_key: <key>
  title: "<title>"
  path: "<vault path to meeting folder>"
area: <Area name>
notes_page_id: <id, after status board write completes>  # for round-trip updates
status: open | decided | captured | ...  # type-specific
---
```

## Phases

### Phase 0: Parse args and load registry

1. Parse flags. Resolve mode (default | one-off | windowed).
2. Read `.claude/state/meeting-digest/digested-meetings.jsonl`. Each line: `{match_key, area, decisions, questions, ideas, actions, journal_entries, notes_pages_created, task_ids, digested_at}`.
3. Determine the lookback window:
   - `--meeting=`: just that one
   - `--since=Nd`: use that
   - Else: latest `digested_at` in registry minus 1 minute. If empty, 24h.
4. Read project-mapping config at `.claude/state/meeting-digest/project-mapping.json`. Initialize `{}` if missing.
5. Read `config/stack.md`. Collect mirror Areas and task manager tool. If required roles are unset, stop per the config contract above.
6. State the plan in one line: `Digesting meetings from [window] across [Areas].`

### Phase 1: Find new meetings

Walk:
- `1-Areas/*/ongoing/meetings/raw/*/`
- `0-Inbox/meetings/*/`

For each folder, read `_meeting.yaml`. If `match_key` not in digest registry AND meeting was filed within the window, queue it for digest.

Apply ingest skip list as a sanity check (personal-only meetings, solo test meetings, empty meetings). Should already be filtered by ingest, but defense-in-depth.

For `--meeting=<spec>`, locate the single folder by match_key or path; skip the rest.
For `--area=<name>`, restrict to `1-Areas/<name>/`.

### Phase 2: Extract structured items per meeting

For each queued meeting, read all summary and transcript files in the folder. Concatenate them in order: summary first, transcript second.

Extract:

**Decisions:** anything explicitly decided in the meeting. Pattern: "we'll do X", "agreed to Y", "decided to Z", "[person] will own this". Each decision: short title (100 chars max), full text, owner if named, related context.

**Open questions:** explicit questions raised but not answered, OR implicit unresolved tensions worth tracking. Each: short title, context.

**Ideas:** net-new product/business/process ideas surfaced in conversation that aren't decisions or questions. Future state, to consider later.

**Action items:** concrete tasks with an owner. Pattern: "[Person] to do X by Y". Each: title, owner (vault user if implicit), due date if mentioned, context.

**Journal entries:** personal observations, reflections, notes worth keeping that aren't decisions/questions/ideas/actions. Vault only, never status board.

Apply the writing rules from the Communication style section of the root CLAUDE.md, including any
hard rules the user added. For extractions specifically: lead with the punchline, then context;
tight and factual.

### Phase 3: Match decisions against existing OPEN rows (mirror Areas only)

For each decision extracted from a mirror Area meeting:

1. Query the Area's Open Questions and Decision Log DB for rows where Status="Open" or Status="In Progress".
2. For each OPEN row, compute a semantic similarity score against the decision (LLM judgment, not embedding math).
3. If similarity is high (judgment call: would resolving this OPEN justify creating this DECISION row?), flag the OPEN as a resolution candidate.

Don't auto-link. Surface for the user's confirmation in Phase 4.

### Phase 4: Approval list (interactive)

Present everything in chat. Use this exact format:

```
=== Meeting: <date> <canonical_title> [<Area>] ===

DECISIONS (N):
  D1: <short title>
       <one-line context>
       may resolve OPEN: <existing question> (row id <short_id>)
  D2: <short title>
       <one-line context>

OPEN QUESTIONS (N):
  Q1: <short title>
       <one-line context>

IDEAS (N):
  I1: <short title>
       <one-line context>

ACTION ITEMS (N):
  A1: [<owner>] <task title> (due: <date or "none">)
       <one-line context>

JOURNAL (N):
  J1: <short title>
       <one-line content preview>

=== End meeting <next meeting if any> ===

Routing defaults: D* and Q* → vault + status board (mirror Areas only). I* → Ideas Backlog (mirror Areas only). A* → task manager. J* → vault only.

Reply with routing instructions, e.g.:
  "all": accept all defaults
  "D1,D2; A1-A3; discard Q1; link D1<>OPEN-row": explicit routing
  "skip meeting": skip this meeting entirely
  "D1: edit title to 'Revised decision title'": edit before routing
```

Wait for the user's response. Parse routing instructions:
- `all` or `accept`: all defaults
- `D1,D2,A1`: only those items
- `discard Q1`: drop that item
- `link D1<>OPEN-row`: confirm a resolution link from Phase 3 flagging
- `D1: edit title to '<text>'`: update the item before routing
- `skip meeting`: mark as digested without routing

If `--dry-run`, skip the wait and just print the proposed plan.

### Phase 5: Execute routing

For each approved item, in this order:

1. **Vault writes first.** Write the markdown file with frontmatter. Use `Edit` or `Write` (never Bash redirects).
2. **Status board writes.** For mirror Area decisions and questions: upsert into Open Questions and Decision Log. For NEW: create a new row. For RESOLVING existing OPEN: update the OPEN row in place, set Status="Decided", append decision text to Resolution field, set Source Meeting and Date Raised if empty. Don't rename the title.
3. **Status board ideas.** Mirror Areas only: create row in Ideas Backlog with Status="Captured", default Phase="Future State", Priority="Important".
4. **Status board Meeting Mirror.** For mirror Area meetings, create the row in the Meetings DB per the mirror rules above.
5. **Task manager tasks.** Create one task per A item. Use the Area's mapped project. If no mapping exists yet, prompt for it once, save, continue.
6. **Update vault frontmatter.** After status board writes complete, write `notes_page_id` back to the vault file's frontmatter so future digests can do round-trip updates instead of duplicating.
7. **Update meeting `_meeting.yaml`.** Set `digested_at: <now>` and `digest_status: routed`.

### Phase 6: Update digest registry and report

Append one JSON line per meeting to `.claude/state/meeting-digest/digested-meetings.jsonl`:

```json
{"match_key":"...","area":"...","decisions":<count>,"questions":<count>,"ideas":<count>,"actions":<count>,"journal_entries":<count>,"notes_pages_created":<count>,"task_ids":[...],"digested_at":"<ISO>"}
```

Print summary:

```
Digested N meetings.
  - 2026-04-24 Team Sync (MyArea): 3 decisions, 2 questions, 1 idea, 4 actions, 0 journal
  - 2026-04-27 Strategy Review (MyArea): ...

Status board writes: D=N, Q=N, I=N, Meeting mirrors=N, Resolutions linked=N
Task manager tasks: N created

Skipped: M meetings [reasons]

Next: review surfaced items in your status board. Run /distill for synthesis pass when ready.
```

If `--dry-run`, prefix with `DRY RUN: no writes performed.`

## Phase 5 details: status board field mapping

Field names below use generic labels. Map them to your actual status board DB schema. If your DB uses different column names, update `config/stack.md` under `areas.<AreaName>.field_map` and reference those mappings here at runtime.

### Open Questions and Decision Log row: new DECISION

```
Question / Decision: "DECISION: <short title>"
Status: "Decided"
Resolution: "<full decision text>"
Source Meeting: "<canonical meeting title> (<date>)"
Date Raised: "<YYYY-MM-DD>"
Owner: "<owner if named, else vault user>"
Category: <inferred from meeting context>
Priority: "Medium" (default unless meeting context is clearly High/Low)
Context: "<short context>"
```

### Open Questions and Decision Log row: new OPEN QUESTION

```
Question / Decision: "OPEN: <short title>"
Status: "Open"
Source Meeting: "<title> (<date>)"
Date Raised: "<YYYY-MM-DD>"
Owner: <vault user> (default)
Category: <inferred>
Priority: "Medium"
Context: "<short context>"
```

### Open Questions and Decision Log row: resolving existing OPEN

```
Status: "Open" -> "Decided"
Resolution: append "<decision text> [from <meeting title>, <date>]" to existing field
Source Meeting: leave existing if set, else fill in
```

### Ideas Backlog row (mirror Areas only)

```
Item: "<short idea title>"
Status: "Captured"
Phase: "Future State"
Priority: "Important"
Category: <inferred>
Source: "<canonical meeting title> (<date>)"
Notes: "<full idea text>"
Dependencies: "" (default empty)
```

### Meeting mirror row (mirror Areas only)

```
Title: "<canonical meeting title>"
Date: <date>
Source: <meeting_source tool name | manual>
Status: "Digested"
Match Key: "<key>"
Source URL: "<URL if status-board-sourced, else empty>"
Attendees: "<comma-separated>"
Vault Path: "<relative path to meeting folder>"
```

Body content for non-status-board sources: copy summary file content + transcript file content with H2 headers (`## Summary` and `## Transcript`).

Body content for status-board sources: short stub `"Original page: [link]. Vault summary: [path]."`

## Project mapping config format

`.claude/state/meeting-digest/project-mapping.json`:

```json
{
  "areas": {
    "MyArea": {
      "task_project_id": "<project ID in your task manager>",
      "task_project_name": "My Area Tasks"
    },
    "0-Inbox": {
      "task_project_id": "<inbox project ID>",
      "task_project_name": "Inbox"
    }
  },
  "default_owner": "<your name>",
  "task_workspace_id": "<workspace or org ID if required by your task manager>"
}
```

When a new Area is encountered without a mapping, prompt:

```
No task manager project mapped for <Area>. Paste the project URL or ID.
```

Save the response to the mapping file. Don't ask again until the user clears the mapping.

## Skip list (carries over from ingest)

These never get processed automatically:

1. Meetings flagged as personal-only in `_meeting.yaml`
2. Solo test meetings (single attendee, no substantive content)
3. Empty meetings (no transcript and no summary)
4. Calendar placeholder stubs with no real content

Manual `--meeting=<key>` overrides any skip rule.

## Cadence

Fully manual. Run `/meeting-ingest` (which chains into this command automatically via Phase 10), or invoke `/meeting-digest` directly for one-off re-runs. No scheduled automation.

## Don't

- Don't write to the status board before vault. Vault is source of truth. If the status board fails, the vault file still exists and a future run can retry.
- Don't auto-link decisions to existing OPEN rows. Always surface the candidate to the user for confirmation.
- Don't run `/distill` automatically after digest. Distill stays manual and separate.
- Don't process meetings on the skip list, even on manual run, unless the user passes explicit `--meeting=`.
- Don't use Bash redirects (`>`, `>>`) for vault writes. Use `Write`/`Edit`.
- Don't commit the digest registry to git. It's covered by the existing `.claude/state/` gitignore rule.
- Don't drop action items if the task manager auth fails. Surface the failure and ask the user to authenticate.
- Don't create status board meeting mirror rows for Areas that aren't configured as mirror Areas in `config/stack.md`.
- Don't auto-rename existing OPEN row titles when resolving them. Just update Status and Resolution.

## Notes

- Action items route to the configured `task_manager` only (single-sink). If you previously used a different tool for tasks, update `config/stack.md` and the project-mapping file.
- The status board may have older meeting databases from previous configurations. This command does NOT touch them. Cleanup is a separate session.
- For meetings on the same date with multiple sub-meetings, the meeting folder uses a `<YYYY-MM-DD>-<slug>` naming pattern, set by ingest. Digest reads whatever folder structure ingest produced.
