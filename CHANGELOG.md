# Changelog

All notable changes to this template are recorded here. If you adopted the template and want to pull improvements into your own vault, run `/update-system` (see "Make it yours" in the README).

The format follows [Keep a Changelog](https://keepachangelog.com/). Dates are `YYYY-MM-DD`.

## [1.1.0] - 2026-08-08

Hygiene release.

- `.claude/hooks/checkout-role.sh`: decides whether the working copy is a shared checkout (a clone that outlives sessions) or an ephemeral sandbox (a throwaway clone a task harness made for one session). Pin it per clone with `git config claudeHooks.checkout shared|ephemeral`, or per process with `CLAUDE_HOOKS_CHECKOUT`.
- The branch-drift guards in `ensure-main.sh` and `commit-on-stop.sh` now stand down inside an ephemeral sandbox, where a `claude/*` branch is the branch the harness assigned rather than drift left behind by a resumed session. The test is how the checkout was created, not which operating system it runs on, so shared checkouts on macOS and Linux keep the protection. Anything the detector cannot read falls through to "shared" and the guard stays on.
- `commit-on-stop.sh` pushes a branch that has no upstream yet with `git push -u origin HEAD`, which a bare `git push` cannot do, and its retry now rebases onto the branch's own upstream and gets a real second attempt when there is no upstream to rebase onto.

## [1.0.0] - 2026-08-01

First public release.

- Inverted-PARA vault structure (`0-Inbox/`, `1-Areas/`, `2-Resources/`, `3-Archives/`) with provenance-based filing (`projects/`, `ongoing/`, `sources/`, `archive/` per Area).
- 17 slash commands, including `/setup` (interviews you, personalizes `CLAUDE.md`, and configures your tool stack), `/brain-dump`, `/daily-checkin`, `/weekly-planning`, `/weekly-review`, `/schedule-week`, `/capture`, `/distill`, `/file-this`, `/refresh-context`, `/focus`, `/archive`, `/meeting-ingest`, `/meeting-digest`, `/system-review`, `/find-solution`, and `/update-system` (pull template improvements into your vault).
- Role-based tool abstraction: commands resolve `task_manager`, `calendar`, `status_board`, and other roles from `config/stack.md` instead of hardcoding products.
- Vault-first capture. Decisions, open questions, ideas and objectives are written to `1-Areas/<Area>/ongoing/{decisions,questions,ideas,objectives}/` as dated markdown by every command that produces them, with no connected tool required. `status_board` is an optional external mirror of that content; leaving it blank is a fully supported configuration.
- Review-and-revert operating model. Additive in-vault work applies directly and is reported after the fact; commands stop and ask only at the hard stops (deleting a file, a link-breaking move, overwriting user-authored content, publishing to an external tool, or a judgment call), and a missing external tool never blocks vault-only work.
- Six bash hooks: branch-drift guard, auto-pull and session briefing on session start, auto-index and mark-dirty on file changes, commit-and-push at end of turn.
- Direct-to-destination output routing: finished deliverables go straight to their final home (a client's shared folder, an Area's external working folder); `outputs_dir` is the fallback for files with no proper home.
- Safety-rail permission defaults in `.claude/settings.json`: confirmation prompts for destructive git and shell commands, denied web fetches to local and metadata addresses.
- Root `CLAUDE.md` operating contract (fill-in-the-blank template), `START_HERE.md` operating manual, `ARCHITECTURE.md` system internals, sample `Example-Area` demonstrating the structure.
