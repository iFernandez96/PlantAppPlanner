# PlantAppPlanner

Control-tower / planning repo for **PlantApp**. It holds no application code.
It plans the next step, reviews the real repo and its GitHub state, keeps durable
memory in files, and emits exact copy/paste prompts for a **separate**
implementation Claude Code instance.

- **Planner repo (this):** `/home/israel/Documents/Development/PlantAppPlanner`
- **Real app repo (read-only):** `/home/israel/Documents/Development/PlantApp`
- **App on GitHub:** `github.com/iFernandez96/PlantApp` (public, default `master`)

See [`CLAUDE.md`](./CLAUDE.md) for the standing rules and hard boundaries. The
short version: **this repo never mutates PlantApp** — read-only inspection only,
mutations require explicit per-change owner approval.

## Layout

```
CLAUDE.md            Standing control-tower rules (boundaries, procedure, prompt contract).
README.md            This file.
.claude/
  agents/            7 planner subagents (read-only reviewers, model: sonnet).
  skills/            4 planner skills (audit / prompt-writing / slice review / handoff).
  rules/             Planner rules referenced by skills and subagents.
state/
  current-state.md   The single source of truth for "where are we right now".
  known-history.md   Commit + decision timeline.
  memory-log.md      What was written to Claude Code auto-memory and why.
reviews/
  latest-repo-review.md   Most recent full repo review (evidence + next action).
github-checks/
  latest-github-check.md  Most recent local-vs-GitHub comparison.
prompts/
  next-implementation-prompt.md  The exact prompt to paste into the impl Claude.
handoffs/
  latest-handoff.md  Session-to-session handoff.
decisions/
  planner-decisions.md  Planner-level decisions (PD-NN), with evidence.
scratch/             Throwaway working notes.
memory/              Planner memory index (points at state/ as canonical).
```

## How to use this repo

1. Open a planner Claude Code session here.
2. It re-reads `state/current-state.md` + `handoffs/latest-handoff.md`.
3. It refreshes real state (read-only git on PlantApp + GitHub checks).
4. It updates the review/state/github-check files.
5. It writes the next exact prompt to `prompts/next-implementation-prompt.md`.
6. You paste that prompt into the **implementation** Claude Code instance (the
   one pointed at `/home/israel/Documents/Development/PlantApp`).
7. The planner writes a handoff and commits.

## Current snapshot

See [`state/current-state.md`](./state/current-state.md) for the live snapshot.
At init (2026-05-31): PlantApp is at `52c9d77` on `master`, local == `origin/master`,
working tree clean, **no production behavior**. Next step is a tiny test-comment
cleanup (see `prompts/next-implementation-prompt.md`).
