---
description: Search for existing tools/skills/MCPs/plugins/packages that solve a Claude Code capability gap before falling back to building.
---

# /find-solution

Read `config/stack.md`. This command does not require an external tool role. Do not assume any specific product.

You are searching for existing public solutions to a capability gap. The gap is: $ARGUMENTS

(If $ARGUMENTS is empty, ask what gap to search for, then proceed.)

## Process

Default 30-60 seconds total. Hard cap: 2 minutes. Do not pad to fill the budget.

1. **Frame the gap precisely.** What capability is needed? What would success look like? One sentence is enough.

2. **Quick search in this order, stop as soon as 2-3 viable candidates surface:**
   - `awesome-claude-code` (`gh api repos/hesreallyhim/awesome-claude-code/contents/README.md` and grep)
   - GitHub keyword/topic search via `gh search repos "<keywords>" --limit 10`
   - npm registry (web or `npm search`)
   - WebSearch for broader ecosystem

3. **For each candidate, report:**
   - What it actually does (verify against the README, not just the description)
   - Stars and last update (active vs. abandoned)
   - Fit for the specific gap
   - Install effort
   - Verdict: install, evaluate further, or skip

4. **If fewer than 2 viable candidates surface in the quick search**, ask whether to do a more exhaustive search (broader web sweep, blog posts, less-popular repos, academic work) before falling back to "we'd have to build it."

5. **Final recommendation:** install one, evaluate further, build it ourselves, or shelve it.

## Quality bar

- Honest reads. Don't oversell candidates that don't fit just because you found them.
- Verify with the actual README, not just the description string. Descriptions overpromise.
- Star count is one signal, not the only signal. A 200-star repo that solves the exact gap beats a 20K-star repo that's adjacent.
- If the search returns nothing useful, say so and recommend either build-it or shelve-it. Don't manufacture options.