---
description: Interactive first-run onboarding. Interviews you (who you are, how you like to work), personalizes CLAUDE.md for you, then walks you role by role, connects the tools you want, and writes config/stack.md. Run this once before the other commands.
argument-hint: [--reconfigure]
---

# /setup

This command WRITES `config/stack.md`. It is the one command that does not read it first, because its whole job is to create it. Every other command reads `config/stack.md` to learn which tool fills each role; if a role is blank, those commands degrade gracefully and point back here. So this is the place where naming specific products is allowed: the recommendations below are suggestions, not wiring baked into the rest of the system.

You are the guide. The user has just cloned this vault template and has connected nothing. Your job is to walk them through it conversationally, one role at a time, connect what they want, skip what they don't, and end with a written config. Move at their pace. Never dump the whole questionnaire at once.

If `--reconfigure` was passed and `config/stack.md` already exists, read it first, show the current value for each role as the default, and let the user change only what they want. Otherwise treat every role as unset.

## Before anything: check the plumbing

Run `git remote -v`. Healthy state: `upstream` pointing at the public template repo and `origin` pointing at the user's own **private** repo. If `origin` is missing or still points at the template, pause and fix it before the interview: walk the user through creating a private GitHub repo (or create it for them with `gh` if it is available and authenticated), set it as `origin`, and push. Without this, nothing they write gets backed up. If they explicitly want a local-only vault, note that and continue.

## Step zero: who you are

Before any tools, personalize the vault. The user should never have to edit a `CLAUDE.md` file by hand; that is your job.

Ask conversationally, one question at a time, and let them skip anything:

1. Their name, and what they do: roles, ventures, the domains they run.
2. Where they are based and their timezone.
3. How they like to be communicated with: direct or explanatory, brief or detailed, and any hard rules (things they never want to see in your writing).

Then rewrite the root `CLAUDE.md` from their answers: the "Who you're working with" section from 1 and 2, and the example rules in "Communication style" replaced with theirs from 3. Use the Edit tool so the change is committed. Read the result back in one short summary and adjust until they are happy.

If `--reconfigure` was passed and the root `CLAUDE.md` is already personalized, ask whether they want to revisit it; if not, go straight to the roles.

## How to run the interview

Go role by role in the order below. For each role:

1. **Say what it is** in one plain-English line.
2. **Give the recommendation** where this command has one.
3. **Ask the opt-in gate:** "Connect a `<role>`? (yes / no / skip for now)". If no or skip, write the role as unset and move to the next one. Do not push.
4. **If yes, ask "Which tool?"** Take whatever they name, even if it is not on the suggested list.
5. **Give connect guidance** using the ladder below, then record the result.

Ask one role at a time. Wait for the answer before moving on. Keep your own turns short. This should feel like a conversation, not a form.

### The connect ladder (use for every "yes")

Always try these in order and tell the user which rung applies to their tool:

1. **Native MCP first.** If the tool has a first-party Claude connector (an official MCP server), that is the cleanest path. Tell the user to connect it in their Claude client's connector or MCP settings, then confirm it shows as connected.
2. **Composio second.** If there is no native connector, Composio brokers a large catalog of apps through one connection and handles the OAuth in its cloud, so no tokens land in any local file. Point the user to the Composio connection flow for that app.
3. **Manual last.** If neither covers it, fall back to a manual path: an API the command can call, a watched folder, a paste-in step, or an export the user drops into the vault. Describe the specific manual fallback for that role.

After a tool connects, do a quick sanity check if you can (list calendars, list projects, fetch a page) so the user knows it actually works before you write it down.

### Credentials rule (state this whenever a tool needs a key)

If any path needs an API key or token, it goes in an environment variable on the user's machine, never in `config/stack.md`, never in any other vault file, and never pasted into chat or a command flag. `config/stack.md` records the tool name and any non-secret IDs only. If a manual path needs a secret, tell the user to set an environment variable and have the tool read it by name.

## The roles, in order

Walk these one at a time.

### 1. task_manager

What it is: where your captured to-dos get published so they live in your real task system, not just the vault.

Recommendation: none forced. Common picks are a dedicated task app (for example Todoist, Asana, Linear) or a tasks database in whatever you already use.

Gate, then tool, then ladder. Most task apps have either a native connector or Composio coverage; if not, the manual fallback is writing tasks to a vault list the user copies over.

### 2. notes_dashboard

What it is: your live board for priorities, strategic objectives, and status, the thing you glance at to see where everything stands.

Recommendation: **Notion** is a strong default here because it handles databases and shared boards well and has good connector support. Other workable picks: Coda, an Obsidian Dataview setup inside this vault, or any database-style notes tool.

Gate, then tool, then ladder. If they pick Notion or a tool with a native connector, use it. Otherwise Composio, then manual (priorities written to a vault file).

### 3. calendar

What it is: your schedule, so the planning commands can see your week and place time blocks.

Recommendation: **Google Calendar or Outlook**, whichever your day already runs on. Pick the one tied to your primary email.

Gate, then tool, then ladder. Both Google and Outlook calendars typically have native connectors; use that first, Composio if needed, manual (the command prints a plain-text schedule you enter yourself) as the fallback.

### 4. meeting_source

What it is: where your meeting transcripts and summaries come from so they can be ingested into the vault.

Recommendation: none forced. Common sources are a video platform that records and transcribes (for example Zoom, Google Meet, Teams), an AI notetaker that emails summaries (for example Otter, Gemini-in-Gmail), or your notes dashboard if your meeting notes already land there.

Gate, then tool, then ladder. This role can hold more than one source; ask if they use several and record each. If nothing connects, the manual fallback is the paste-in flow (`/meeting-ingest --paste`), which always works.

### 5. transcription

What it is: turns raw audio files (voice memos, recordings without a built-in transcript) into text.

Recommendation: none forced. Pick any speech-to-text service you have access to. If your `meeting_source` already produces transcripts, you may not need this at all, so skipping is fine.

Gate, then tool, then ladder. Transcription is usually a manual-rung path: an API the assistant calls when audio needs transcribing. Record only the service name in `config/stack.md`; the API key lives in an environment variable.

### 6. notification_channel

What it is: where short pushes go, daily briefings, meeting digests, reminders, so you get them on your phone or in a chat app instead of only in the terminal.

Recommendation: none forced. Common picks are a chat app you already watch (for example Slack, a messaging bot) or email to yourself.

Gate, then tool, then ladder. Native connector first (for example a chat-app connector), Composio second, manual third (the manual path is typically a bot or webhook the command posts to, with the token in an environment variable). Record the channel name and any non-secret channel/chat ID; keep the token in the environment.

### 7. outputs_dir

What it is: the fallback folder for finished deliverables (PDFs, Word docs, decks, spreadsheets) that have no proper home. The vault holds working drafts and sources; most finished files go directly to the folder where they'll be used (a client's shared folder, an Area's external working folder), and this folder catches the rest. If it's cloud-synced, those files are reachable from your phone.

Recommendation: **any cloud-synced folder you already have** (for example a Dropbox, Google Drive, or iCloud folder on this machine). Cloud-syncing it is the point: it puts finished files on your other devices without extra steps.

Gate, then path. This one is a filesystem path, not a connected tool, so there is no ladder. Ask for the absolute path to the folder. If they do not have one yet, suggest they make a folder inside their existing cloud-sync directory and paste that path. Record it as `outputs_dir` in `config/stack.md`; commands read that value at runtime rather than using a fixed placeholder.

## Special question: cross-machine sync

After the seven roles, ask this one separately because it is two different things that people often confuse. Explain both in plain English before asking.

> Two things can keep your vault in more than one place, and they solve different problems.
>
> **(A) More than one computer.** If you use this vault on, say, a laptop and a desktop, the setup keeps them in step through your own private GitHub repository. Each session, the vault auto-commits your changes and pushes them up; the next session on the other machine pulls them down before you start. The hooks that do this are already in the template. You just point them at a private GitHub repo that you own and keep private (it holds your notes). Nothing here is shared publicly.
>
> **(B) Your notes on your phone.** If what you really want is to read and edit notes on your phone, the cleanest path is Obsidian's own sync service. That is a separate paid subscription (roughly $4 a month, billed by Obsidian, not part of this template) and it is entirely optional. It syncs the Obsidian vault across your devices including mobile, independently of the GitHub setup.
>
> Which fits you?
>   (a) Multiple computers (set up the private GitHub repo)
>   (b) Phone access via Obsidian (note the optional paid sync)
>   (c) Both
>   (d) Just this one machine, no sync

Handle the answer:

- **(a) or (c), multiple computers:** Ask for the user's private vault GitHub repo (the `{{VAULT_REPO}}`). If they do not have one, walk them through creating a new private repo and setting it as the remote. Confirm the repo is private (it contains personal notes). Record `sync.machines: multiple` and `sync.vault_repo: <repo>`. Tell them the auto-commit and pull hooks will use that remote; no secret goes in `config/stack.md` (any token the push needs lives in an environment variable).
- **(b) or (c), phone via Obsidian:** Confirm they understand it is a separate, optional, paid Obsidian subscription (about $4/mo) that they set up inside the Obsidian app, not through this command. Record `sync.mobile: obsidian-sync`. Do not try to configure it here; it is an Obsidian-side setting.
- **(d), single machine:** Record `sync.machines: single`. Nothing else to do.

If they pick both, record both keys.

## Catch-all: anything else to connect?

End the interview with an open door:

> Anything else you want wired in? CRM, email, accounting, a custom API, anything. (yes / no)

If no, move to writing the file.

If yes, for each thing they name:

1. Ask what it is and what they want it to do in one line.
2. Find the best path with the same ladder: native MCP first, Composio second, manual (API, webhook, watched folder, export) third. Say which rung fits.
3. Connect it (or describe the manual path), sanity-check if possible.
4. Record it under a `custom:` list in `config/stack.md` with a short role name the user picks, the tool, and how it connects.

Loop until they say they are done. Keep the same credentials rule: secrets in environment variables, names and non-secret IDs only in the file.

## Writing config/stack.md

Before writing anything else, silently set `vault_root` to the absolute path of this vault's own root directory (the directory containing the `.claude` folder). Detect it; do not ask the user.

When the interview is done, write `config/stack.md` (overwrite if it exists, but if `--reconfigure`, preserve any keys you did not touch). Use this `role: value` format. Leave a role blank (empty value) when the user skipped it, and keep the inline comment so they can fill it in later by hand.

```yaml
# config/stack.md: your tool stack
# Each command reads this to learn which tool fills each role.
# A blank value means "not connected"; commands that need it will tell you to run /setup.
# Secrets (API keys, tokens) never go here. They live in environment variables.

# --- Paths ---
vault_root:                       # auto-filled by /setup: absolute path to this vault on disk
outputs_dir:                      # absolute path to your cloud-synced finished-deliverables folder

# --- Connected roles ---
task_manager:                     # e.g. Todoist | Asana | Linear   (connect: native MCP > Composio > manual)
notes_dashboard:                  # e.g. Notion (recommended) | Coda | Obsidian Dataview
calendar:                         # e.g. Google Calendar | Outlook
meeting_source:                   # one or a list, e.g. [Zoom, Otter]   (or "manual" for paste-only)
transcription:                    # e.g. a speech-to-text service, or blank if your meeting_source transcribes
notification_channel:             # e.g. Slack | a chat bot | email-to-self
                                  #   (record channel/chat IDs here; tokens stay in env vars)

# --- Cross-machine sync ---
sync:
  machines:                       # single | multiple
  vault_repo:                     # {{VAULT_REPO}} (your PRIVATE GitHub repo, only if machines: multiple)
  mobile:                         # obsidian-sync (separate optional paid subscription), or blank

# --- Per-Area routing (filled in as you use the vault) ---
# areas:
#   YourArea:
#     decisions_db:               # notes_dashboard DB ID or URL
#     ideas_db:
#     meeting_mirror_db:
#     field_map:                  # map generic field names to your DB's column names

# --- Scheduling preferences (optional; the planning commands read these) ---
# schedule:
#   hard_blocks:                  # protected time windows the planner must not overwrite
#   fitness:                      # recurring fitness block: frequency, duration, preferred time

# --- Meeting skip patterns (optional) ---
# meeting_skip_patterns:          # attendee-name fragments or topic patterns to always ignore

# --- Custom integrations (from the catch-all) ---
# custom:
#   - role:                       # short name you picked
#     tool:                       # the product
#     connect:                    # native-mcp | composio | manual
#     notes:                      # non-secret IDs or endpoints; secrets stay in env vars
```

Fill in every value the user gave you. Drop the commented example blocks only if you actually populated them; otherwise leave them as guidance. Write the file with the `Write` tool so the auto-commit hook captures it. Do not use Bash redirects.

After writing, show the user a tight summary: the personalization written into `CLAUDE.md`, which roles are connected, which are blank, the sync choice, and any custom integrations. Then tell them they can re-run `/setup --reconfigure` anytime to change one thing, and that the other commands are now ready.

## Sample interview turn

So the flow is clear, here is one role handled end to end. Yours should read like this, one role at a time.

```
Assistant: Next role: calendar. This is your schedule, so the planning
commands can see your week and drop in time blocks. I'd recommend Google
Calendar or Outlook, whichever your day already runs on.

Connect a calendar? (yes / no / skip for now)

User: yes, google

Assistant: Google Calendar has a native Claude connector, so that's the
clean path (rung 1 of 3: native MCP). Open your Claude client's connector
settings and enable the Google Calendar connector, then tell me when it
shows connected.

User: done

Assistant: Let me confirm it's live.
[lists calendars]
Got it, I can see your calendars. Recording calendar: Google Calendar.

Moving on. Next role: meeting_source...
```

## Don't

- Don't dump all the questions at once. One role per turn.
- Don't push a tool the user said no to. Skip means skip; write it blank and move on.
- Don't write any secret into `config/stack.md` or echo one in chat. Names and non-secret IDs only; secrets go in environment variables.
- Don't assume a product elsewhere in the system. This file is the only place tool names belong; the commands resolve roles at runtime.
- Don't configure Obsidian Sync from here. It is a paid, optional, Obsidian-side subscription. Just note the choice.
- Don't skip the sanity check when a tool connects, if a quick read is available. Confirm it works before recording it.
- Don't use Bash redirects to write the config. Use the `Write` tool so the change is committed.
