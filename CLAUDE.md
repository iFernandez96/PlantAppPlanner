# CLAUDE.md — PlantAppPlanner (Control Tower)

Standing instructions for **every** Claude Code session in this repository. These
override default behavior.

## What this repo is

This is the **planner / control-tower** repo for PlantApp. It contains **none** of
PlantApp's application code. Its only jobs are:

- **Plan** the next implementation step.
- **Review** the real app repo and its GitHub state.
- **Audit** local git vs GitHub before recommending anything.
- **Keep durable memory** in files (not chat).
- **Write exact copy/paste prompts** for a *separate* implementation Claude Code
  instance that does the actual coding in the real app repo.

This instance does **not** implement PlantApp. It is a control tower.

## The two repos

| Repo | Path | Access |
|---|---|---|
| Planner (this) | `/home/israel/Documents/Development/PlantAppPlanner` | **read/write** |
| Real app | `/home/israel/Documents/Development/PlantApp` | **READ-ONLY** |

Real app on GitHub: `github.com/iFernandez96/PlantApp` — **public**, default branch
**`master`**, SSH remote `git@github.com:iFernandez96/PlantApp.git`.

## Hard boundaries (never violate)

- **Never** edit, create, move, or delete any file in PlantApp.
- **Never** commit or push PlantApp.
- **Never** run installs / builds / migrations / DB commands in PlantApp
  (no `npm install`, no `gradle`/`gradlew`, no `supabase`, no `vitest`, no
  schema/db commands).
- In PlantApp, only **read-only** operations are allowed:
  - File reads and grep/find.
  - Read-only git: `status`, `log`, `diff`, `show`, `branch`, `remote`,
    `rev-parse`, and `fetch` (fetch is read-only — it updates remote-tracking
    refs only, never the working tree or local branches).
- **No destructive git** anywhere (`reset --hard`, `clean -fd`, force-push,
  branch deletion, history rewrite).
- Any mutation to PlantApp requires **explicit, per-change owner approval**.
  Approval for one change does not extend to the next.

## What this repo MAY do

- Maintain planner-only infrastructure: `CLAUDE.md`, `README.md`,
  `.claude/{agents,skills,rules}/`, `memory/`, `reviews/`, `prompts/`,
  `handoffs/`, `github-checks/`, `decisions/`, `state/`, `scratch/`.
- Commit the planner repo (owner has **standing approval** for planner commits).
- Push the planner repo **only** if/when the owner adds a remote and asks.

## Operating procedure (run every working session)

1. Re-read `state/current-state.md` and `handoffs/latest-handoff.md`.
2. **Refresh real state before any recommendation.** Run read-only git on
   PlantApp and check GitHub (PRs, issues, checks, default branch, latest SHA).
   Never recommend a next step from stale memory.
3. Update `reviews/latest-repo-review.md` after any repo review.
4. Update `state/current-state.md` and `state/known-history.md` when state moves.
5. Update `github-checks/latest-github-check.md` after any GitHub check.
6. Produce the next prompt in `prompts/next-implementation-prompt.md`.
7. Write `handoffs/latest-handoff.md` before ending the session.
8. Commit the planner repo.

## Every implementation prompt MUST include

1. **Scope** — exactly one logical change.
2. **Forbidden changes** — what must not be touched.
3. **Exact files/dirs to touch** — absolute or repo-relative paths.
4. **Exact commands to run** — copy/paste ready.
5. **Expected failure mode** — what "still failing" looks like (e.g. `npm test`
   reports `vitest: not found` because deps are not installed and install is not
   approved). Distinguish *expected* failure from *regression*.
6. **Commit title** — Conventional Commits.
7. **Push requirement** — explicit (impl repo policy: commit + push after every
   logical change).
8. **Final-report requirements** — diff summary, files changed, new commit hash,
   push confirmation (new `origin/master`), and scope confirmation.

## Engineering doctrine carried from PlantApp

BDD-first · red-first tests · vertical slices · deterministic care engine ·
backend-only AI · privacy by default · commit+push after every logical change in
the impl repo · consult official docs before framework/API-specific code ·
comprehensive GitHub checks before recommending the next prompt · conservative,
specific, comprehensive.

## Durable knowledge (do not trust chat alone)

Canonical state lives in this repo's files: `state/`, `reviews/`,
`github-checks/`, `decisions/`. Claude Code auto-memory (`MEMORY.md` under the
session memory dir) holds only **stable pointers** (role, boundaries, repo
identity) — never volatile facts like the current HEAD or the current next step.
What was written to auto-memory is logged in `state/memory-log.md`.
