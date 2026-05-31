# Memory Log

Records what was written to **Claude Code auto-memory** for this planner project,
and why. Auto-memory is a convenience layer for cross-session recall; it is **not**
canonical. Canonical durable state is the tracked files in this repo (`state/`,
`reviews/`, `github-checks/`, `decisions/`, `prompts/`, `handoffs/`).

## Auto-memory location
`/home/israel/.claude/projects/-home-israel-Documents-Development-PlantAppPlanner/memory/`
with `MEMORY.md` as the loaded index.

## Policy
Only **stable** facts go to auto-memory (role, hard boundaries, repo identity).
**Volatile** facts (current HEAD SHA, the current "next step") stay **out** of
auto-memory and live only in `state/current-state.md`, which is re-verified each
session. This prevents auto-memory from going stale and being trusted blindly.

## Entries written (2026-05-31)

| Memory file | Type | Gist |
|---|---|---|
| `planner-control-tower-role.md` | project | This instance = PlantAppPlanner control tower; plans/reviews/writes prompts; canonical state lives in this repo's files. |
| `plantapp-no-mutation-boundary.md` | feedback | Never edit/commit/push PlantApp; never run installs/builds/migrations there; read-only git + reads only; mutations need per-change approval. |
| `plantapp-repo-identity.md` | reference | PlantApp = github.com/iFernandez96/PlantApp, public, default branch `master`, SSH remote; separate from this planner repo. *(Updated 2026-05-31: planner repo now has its own remote `PlantAppPlanner.git`.)* |

## Deliberately NOT in auto-memory
- Current HEAD (`52c9d77` as of 2026-05-31) — see `state/current-state.md`.
- Current next step (Option A) — see `prompts/next-implementation-prompt.md`
  and `decisions/planner-decisions.md` (PD-01).

## /memory usage note
These entries were written directly as memory files (not via an interactive
`/memory` editing session). If a future session edits memory via `/memory`,
append what changed here.
