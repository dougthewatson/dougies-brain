# Changelog

All notable changes to this template are recorded here. If you adopted the template and want to pull improvements into your own vault, see the "Staying up to date" section of the README, or run `/update-system`.

The format follows [Keep a Changelog](https://keepachangelog.com/). Dates are `YYYY-MM-DD`.

## [1.1.0] - 2026-07-14

### Added

- `/cowork-brief` command: hand a task to Claude Cowork with full vault context. Writes a self-contained briefing file into a `_cowork/` subfolder of the destination folder and returns paste-ready kickoff prompts for desktop (folder connection) and phone (cloud-drive connector) sessions. New "Handing tasks to Claude Cowork" section in `START_HERE.md`.

### Changed

- Output routing philosophy: finished deliverables now go directly to their final home (a client's shared folder, an Area's external working folder). `outputs_dir` is demoted from default destination to fallback for files with no proper home. Updated in `CLAUDE.md` (intro + output destinations table), `START_HERE.md` (role table, "Where things live"), `/setup`, `/capture`, and `_ops-context.md`.

## [1.0.0] - 2026-07-13

First public release.

- Inverted-PARA vault structure (`0-Inbox/`, `1-Areas/`, `2-Resources/`, `3-Archives/`) with provenance-based filing (`projects/`, `ongoing/`, `sources/`, `archive/` per Area).
- 17 slash commands, including `/setup` (interviews you, personalizes `CLAUDE.md`, and configures your tool stack), `/weekly-planning`, `/weekly-review`, `/capture`, `/distill`, `/file-this`, `/refresh-context`, `/meeting-ingest`, `/meeting-digest`, and `/update-system` (pull template improvements into your vault).
- Role-based tool abstraction: commands resolve `task_manager`, `calendar`, `notes_dashboard`, and other roles from `config/stack.md` instead of hardcoding products.
- Five bash hooks: auto-pull and session briefing on session start, auto-index and mark-dirty on file changes, commit-and-push at end of turn.
- Safety-rail permission defaults in `.claude/settings.json`: confirmation prompts for destructive git and shell commands, denied web fetches to local and metadata addresses.
- Root `CLAUDE.md` operating contract (fill-in-the-blank template), `START_HERE.md` operating manual, sample `Example-Area` demonstrating the structure.
