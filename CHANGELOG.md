# Changelog

All notable changes to this template are recorded here. If you adopted the template and want to pull improvements into your own vault, see the "Staying up to date" section of the README, or run `/update-system`.

The format follows [Keep a Changelog](https://keepachangelog.com/). Dates are `YYYY-MM-DD`.

## [1.0.0] - 2026-07-10

First public release.

- Inverted-PARA vault structure (`0-Inbox/`, `1-Areas/`, `2-Resources/`, `3-Archives/`) with provenance-based filing (`projects/`, `ongoing/`, `sources/`, `archive/` per Area).
- 17 slash commands, including `/setup` (interactive stack configuration), `/weekly-planning`, `/weekly-review`, `/capture`, `/distill`, `/file-this`, `/refresh-context`, `/meeting-ingest`, `/meeting-digest`, and `/update-system` (pull template improvements into your vault).
- Role-based tool abstraction: commands resolve `task_manager`, `calendar`, `notes_dashboard`, and other roles from `config/stack.md` instead of hardcoding products.
- Five bash hooks: auto-pull and session briefing on session start, auto-index and mark-dirty on file changes, commit-and-push at end of turn.
- Safety-rail permission defaults in `.claude/settings.json`: confirmation prompts for destructive git and shell commands, denied web fetches to local and metadata addresses.
- Root `CLAUDE.md` operating contract (fill-in-the-blank template), `START_HERE.md` operating manual, sample `Example-Area` demonstrating the structure.
