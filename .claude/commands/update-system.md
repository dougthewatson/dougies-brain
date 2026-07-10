---
description: Pull improvements from the upstream Dougies Brain template into this vault, without touching your content. Interactive, per-file approval.
argument-hint: [--dry-run]
---

# /update-system

This command updates the **system files** of this vault (commands, hooks, settings wiring, docs, config templates) from the upstream template repository. It never touches your content: your Areas, Inbox, Resources, Archives, and private `config/stack.md` are out of scope by design.

Read `config/stack.md` first only to confirm nothing here depends on a connected tool. This command needs git and network access, nothing else.

## What counts as a system file

Eligible for update (the "system set"):

- `.claude/commands/*.md`, but only commands that exist upstream. Commands the user added themselves are never touched.
- `.claude/hooks/*.sh`
- `.claude/settings.json`: hooks wiring and permission rails. Treat with extra care (step 5).
- `config/stack.example.md`
- `START_HERE.md`
- `CHANGELOG.md`
- `README.md`

Never eligible, even if upstream changed them:

- Root `CLAUDE.md` (the user has personalized it; offer diffs only, per step 6)
- `config/stack.md` (private wiring, gitignored)
- Anything under `0-Inbox/`, `1-Areas/`, `2-Resources/`, `3-Archives/`
- `.gitignore` (users extend it; offer a diff only)

## Steps

### 1. Confirm the upstream remote

Check whether a remote named `upstream` exists (`git remote -v`). If not, add it:

```
git remote add upstream https://github.com/dougthewatson/dougies-brain.git
```

If the user adopted this template from a fork, ask which URL their upstream is before adding.

### 2. Fetch and compare

```
git fetch upstream
```

Compare the working tree against `upstream/main` for the system set only (`git diff HEAD upstream/main -- <paths>` and `git diff --stat`). Also list any files that exist upstream in the system set but not locally (new commands, new hooks).

### 3. Read the changelog delta

Diff `CHANGELOG.md` against upstream and read the entries the user does not have yet. Summarize them in one short list: what changed upstream and why it might matter. This is the user's decision context.

### 4. Present the plan, one file per line

For each changed or new file in the system set, show: path, one-line summary of what changed, and whether the local copy has diverged from the template (meaning the user or their sessions modified it since adoption). Format:

```
UPDATES AVAILABLE (from upstream/main):
  M  .claude/commands/distill.md        upstream improved lint pass    (local: unmodified)
  M  .claude/hooks/commit-on-stop.sh    better push-retry logic        (local: MODIFIED, will show diff)
  A  .claude/commands/new-command.md    new command                    (new file)

Skipped by policy: CLAUDE.md (personalized), .gitignore (user-extended)
Reply: "all", a list of paths, or "none". Files marked MODIFIED get a diff before you decide.
```

If `--dry-run`, stop here.

### 5. Apply approved updates

For each approved file:

- If the local copy is unmodified relative to the template's last-known version, apply the upstream version directly: `git checkout upstream/main -- <path>`.
- If the local copy has diverged, show the user the actual diff between their version and upstream, and ask: take upstream, keep local, or merge by hand (walk them through the specific hunks). Never silently overwrite local changes.
- For `.claude/settings.json`, never checkout wholesale. Diff the `hooks` block and the `ask`/`deny` permission rails separately, and apply only the pieces the user approves, preserving any local permission entries they have added.

Use the Edit and Write tools for merged results (not raw `git checkout`) whenever the outcome is a blend of local and upstream content, so the end-of-turn commit hook captures it.

### 6. Offer the CLAUDE.md diff

If upstream's root `CLAUDE.md` changed, do not apply it. Show the diff of the changed sections only and ask whether the user wants any of those improvements folded into their personalized copy. Apply only the hunks they pick, adapting them around the user's own content.

### 7. Report

End with a short summary: files updated, files skipped, anything deferred. Remind the user the change is committed by the end-of-turn hook and can be reverted with `git log` / `git revert` if anything feels off.

## Don't

- Don't update anything outside the system set, whatever upstream contains.
- Don't overwrite a locally modified file without showing the diff and getting an explicit choice.
- Don't merge upstream `main` wholesale (`git merge upstream/main` would drag in template sample content on top of user content). This command cherry-picks files, never merges branches.
- Don't touch `config/stack.md` or anything gitignored.
- Don't proceed if the working tree has uncommitted changes; tell the user to let the end-of-turn commit fire first (or commit manually), then re-run.
