# memory/

This directory exists so planner-durable knowledge has a home **inside the
version-controlled repo**. It is intentionally thin.

## Canonical state is NOT here
The single source of truth for "where are we" is:
- `../state/current-state.md` — live snapshot (re-verified each session)
- `../state/known-history.md` — commit + decision timeline
- `../reviews/latest-repo-review.md` — most recent review
- `../github-checks/latest-github-check.md` — local-vs-GitHub
- `../decisions/planner-decisions.md` — planner decisions (PD-NN)
- `../prompts/next-implementation-prompt.md` — the next exact prompt
- `../handoffs/latest-handoff.md` — session handoff

## Two memory layers (don't confuse them)
1. **This repo's files** (above) — versioned, reviewable, the real durable store.
2. **Claude Code auto-memory** — at
   `/home/israel/.claude/projects/-home-israel-Documents-Development-PlantAppPlanner/memory/`
   with `MEMORY.md` as the loaded index. It holds only **stable pointers** (role,
   boundaries, repo identity). What was written there is logged in
   `../state/memory-log.md`.

## Rule
Put **stable** facts in auto-memory; keep **volatile** facts (current HEAD, the
current next step) only in `../state/current-state.md`, which is re-checked every
session. This keeps memory from going stale and being trusted blindly.
