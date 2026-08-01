# stack.example.md: filled example

This shows what a fully populated `config/stack.md` looks like, using fictional but realistic
choices to illustrate the format. To get started, run `/setup` (it writes `stack.md` for you),
or copy this file to `config/stack.md` and replace the values with your own.

Every tool named here is an illustration, not a requirement. Any tool that covers the role
works. Secrets never go in this file; they live in environment variables.

```yaml
# config/stack.md: your tool stack
# A blank value means "not connected"; commands that need it will tell you to run /setup.
# Secrets (API keys, tokens) never go here. They live in environment variables.

# --- Paths ---
vault_root:   ~/notes/my-vault            # absolute path to this vault on disk
outputs_dir:  ~/Dropbox/Outputs           # cloud-synced finished-deliverables folder

# --- Connected roles ---
task_manager:         Todoist             # connected via native MCP
status_board:         Notion              # OPTIONAL mirror; blank is fine and fully supported
calendar:             Google Calendar     # connected via native MCP
meeting_source:       [Zoom, Otter]       # two sources; Zoom records, Otter emails summaries
transcription:        Whisper (local)     # on-device; blank would also be fine here
notification_channel: Slack               # channel: #briefings  (token is in $SLACK_BOT_TOKEN)

# --- Cross-machine sync ---
sync:
  machines:   multiple                    # this vault runs on a laptop and a desktop
  vault_repo: yourname/my-vault-private   # your PRIVATE GitHub repo (holds your notes)
  mobile:     obsidian-sync               # optional paid Obsidian subscription for phone access

# --- Per-Area routing (read by /meeting-ingest and /meeting-digest) ---
areas:
  Example-Area:
    decisions_db:      "https://notion.so/your-decisions-db-id"
    ideas_db:          "https://notion.so/your-ideas-db-id"
    meeting_mirror_db: "https://notion.so/your-meetings-db-id"
    field_map:                            # map generic labels to your DB's column names
      title:  "Name"
      status: "Status"
      owner:  "Assignee"

# --- Scheduling preferences (read by the planning commands) ---
schedule:
  hard_blocks:                            # protected windows the planner must not overwrite
    - "Mon-Fri 09:00-09:30 daily standup"
    - "Fri 15:00-17:00 deep work"
  fitness:        "3x/week, 60min, mornings preferred"

# --- Meeting skip patterns (optional) ---
meeting_skip_patterns:
  - "1:1 personal"
  - "solo test"

# --- Custom integrations (from the /setup catch-all) ---
custom:
  - role:    crm
    tool:    HubSpot
    connect: composio                     # CRM lookups in capture and brain-dump
    notes:   "portal id 1234567 (not a secret)"
  - role:    eng_tasks
    tool:    Linear
    connect: composio
    notes:   "team key ENG"
```
