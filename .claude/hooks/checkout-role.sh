#!/usr/bin/env bash
# .claude/hooks/checkout-role.sh
#
# Sourced by ensure-main.sh, commit-on-stop.sh and auto-pull.sh. Not a hook
# itself. It defines one function, checkout_is_shared, which answers one
# question:
#
#   Is this working copy a SHARED CHECKOUT (a clone that outlives sessions:
#   your laptop, your desktop, a dev container you keep coming back to), or an
#   EPHEMERAL SANDBOX (a throwaway clone a task harness created for a single
#   session and will delete afterwards)?
#
# It matters because a `claude/*` branch means opposite things in the two. In a
# shared checkout it is drift: a resumed cloud or mobile session left its branch
# checked out, and every commit made here afterwards lands on that branch
# instead of the default branch, somewhere you never look. In a sandbox it is
# the branch the harness assigned, and dragging the session back to the default
# branch fights the harness and strands the work.
#
# This is not an operating-system question. Shared checkouts exist on macOS and
# Linux, and sandboxes are mostly Linux, so keying the guard off `uname` would
# switch the protection off for every macOS and Linux user, which is the inverse
# of the fix.
#
# Direction of failure: a wrong "ephemeral" answer silently removes a user's
# branch-drift guard, so every rule below has to produce positive evidence of
# ephemerality. Anything unknown, unreadable or unparseable falls through to
# "shared" and the guard stays on.
#
# Overrides, highest precedence first, for when the heuristics get it wrong:
#   CLAUDE_HOOKS_CHECKOUT=shared|ephemeral            (environment)
#   git config claudeHooks.checkout shared|ephemeral  (this clone only)
# The git config form lives in .git/config, which is per-clone and never travels
# with a push, so pinning one machine cannot change another.
#
# Known residual: a checkout dormant long enough for `git gc` to expire its
# whole reflog can look freshly created. Pin it if you hit that.

# CHECKOUT_ROLE_REASON is read by the hooks that source this file.
# shellcheck disable=SC2034

# A workspace and the branch on it, created within this many seconds of each
# other, were provisioned together. Overridable for testing.
CHECKOUT_ROLE_GRACE_SECONDS=${CHECKOUT_ROLE_GRACE_SECONDS:-300}
# A per-task sandbox does not live this long; a shared checkout passes it in its
# first week. Long on purpose: erring long only re-enables the guard.
CHECKOUT_ROLE_MAX_AGE_SECONDS=${CHECKOUT_ROLE_MAX_AGE_SECONDS:-604800}

# Set by checkout_is_shared to a short human-readable reason for its answer.
CHECKOUT_ROLE_REASON=""

# Unix timestamp of the OLDEST reflog entry for ref $1, empty if there is none
# (reflogs disabled, ref never existed, entries expired). --no-decorate keeps
# the line shape parseable for users who set log.decorate.
_checkout_role_reflog_oldest() {
  git reflog show --no-decorate --date=unix "$1" 2>/dev/null \
    | sed -n 's/^[^ ]* [^ ]*@{\([0-9][0-9]*\)}:.*$/\1/p' \
    | tail -n 1
}

# True when a build agent set one of the usual environment flags. CODESPACES and
# GITPOD_WORKSPACE_ID are deliberately not in this list: those workspaces persist
# and are somebody's daily driver, which makes them shared checkouts.
_checkout_role_env_is_ephemeral() {
  local _name _value
  for _name in CI CONTINUOUS_INTEGRATION GITHUB_ACTIONS GITLAB_CI CIRCLECI \
               BUILDKITE JENKINS_URL TEAMCITY_VERSION; do
    _value=${!_name}
    case "$_value" in
      ""|0|false|False|FALSE|no|NO) ;;
      *) return 0 ;;
    esac
  done
  return 1
}

# Returns 0 (true) for a shared checkout, 1 for an ephemeral sandbox.
checkout_is_shared() {
  local pin branch default_branch clone_at branch_at now age delta
  CHECKOUT_ROLE_REASON=""

  # 1. An explicit pin always wins. Unrecognised values fall through to the
  #    heuristics rather than failing.
  pin=${CLAUDE_HOOKS_CHECKOUT:-}
  if [ -z "$pin" ]; then
    pin=$(git config --get claudeHooks.checkout 2>/dev/null || true)
  fi
  case "$pin" in
    shared)
      CHECKOUT_ROLE_REASON="pinned shared"
      return 0
      ;;
    ephemeral)
      CHECKOUT_ROLE_REASON="pinned ephemeral"
      return 1
      ;;
  esac

  # 2. Build agents are ephemeral by definition, and merging a branch into the
  #    default branch and pushing it from one would be actively destructive.
  #    Checked before the reflog test because a reused runner workspace can be
  #    old enough to read as shared.
  if _checkout_role_env_is_ephemeral; then
    CHECKOUT_ROLE_REASON="CI environment variable set"
    return 1
  fi

  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

  # 3. The default branch is created at the same moment as the clone in every
  #    clone that has ever existed, so provenance can say nothing about it.
  #    Answer shared and let the caller decide on its own terms.
  default_branch=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
  case "$branch" in
    "$default_branch"|main|master)
      CHECKOUT_ROLE_REASON="on the default branch"
      return 0
      ;;
  esac

  # 4. Provenance. A harness clones the workspace and puts the session branch on
  #    it in the same breath, so branch and workspace are the same age. Drift is
  #    the opposite shape: the workspace has been here for days and the branch
  #    turned up this afternoon. Requiring the workspace to be young as well
  #    stops an old checkout whose early reflog `git gc` has expired from
  #    reading as a fresh clone.
  clone_at=$(_checkout_role_reflog_oldest HEAD)
  branch_at=""
  if [ -n "$branch" ] && [ "$branch" != "HEAD" ]; then
    branch_at=$(_checkout_role_reflog_oldest "refs/heads/$branch")
  fi
  now=$(date +%s 2>/dev/null || echo "")
  if [ -n "$clone_at" ] && [ -n "$branch_at" ] && [ -n "$now" ]; then
    delta=$((branch_at - clone_at))
    if [ "$delta" -lt 0 ]; then delta=$((0 - delta)); fi
    age=$((now - clone_at))
    if [ "$age" -lt 0 ]; then age=0; fi
    if [ "$delta" -le "$CHECKOUT_ROLE_GRACE_SECONDS" ] \
       && [ "$age" -le "$CHECKOUT_ROLE_MAX_AGE_SECONDS" ]; then
      CHECKOUT_ROLE_REASON="branch and workspace provisioned together (${delta}s apart, workspace ${age}s old)"
      return 1
    fi
    CHECKOUT_ROLE_REASON="workspace predates this branch (${delta}s apart, workspace ${age}s old)"
    return 0
  fi

  # 5. Fail safe: keep the guard.
  CHECKOUT_ROLE_REASON="provenance unreadable, assuming shared"
  return 0
}
