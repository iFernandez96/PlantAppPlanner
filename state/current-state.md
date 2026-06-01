# PlantApp — Current State

> Single source of truth for "where are we right now." Refresh from real git +
> GitHub at the start of every planner session; never trust this file blindly
> without re-verifying the SHAs.

| Field | Value |
|---|---|
| **Snapshot timestamp** | 2026-05-31 (after Option A landed) |
| **PlantApp repo path** | `/home/israel/Documents/Development/PlantApp` |
| **GitHub** | `github.com/iFernandez96/PlantApp` (public) |
| **Branch** | `master` |
| **Default branch** | `master` (no `main`) |
| **Local HEAD** | `b2836ca7ff4d65020f1d385d38940cf8652db459` (`b2836ca`) |
| **origin/master** | `b2836ca7ff4d65020f1d385d38940cf8652db459` (`b2836ca`) |
| **Local == remote?** | ✅ YES — in sync |
| **Working tree** | ✅ clean |
| **Uncommitted changes** | None |
| **Prev HEAD** | `52c9d77` (before Option A) |

## Last confirmed commit

```
b2836ca test(schema): remove stale GardenSpace minLength comment
```
**Option A — landed and planner-verified (2026-05-31).** Diff was comment-only
(3 insertions, 5 deletions, 1 file: `backend/tests/schema/garden-space.test.ts`).
The `validGardenSpace` fixture and all three `it(...)` assertions are unchanged;
the stale "does not yet enforce a minLength / fails red" note is gone, replaced by
an accurate one. Verified by `git show b2836ca` + `git diff --name-only
52c9d77 b2836ca` (single file).

## Current phase

**Post-scaffolding, schema contract aligned + stale comment cleaned,
pre-business-logic.** Slice 1 business logic has not begun. Next is the first
**care-engine** red-first step.

## Scaffolding state (unchanged from init)

- Backend Node+TS skeleton; `backend/care-engine/index.ts` is still the
  placeholder `export {};` (no logic).
- Android: 6-module Gradle skeleton, source dirs `.gitkeep` only (no Kotlin).
- Supabase: `0001_init_extensions.sql` (extensions only, no tables).
- 7 shared JSON Schemas; 7 project subagents in PlantApp `.claude/agents/`.

## Test state

- Schema tests: `garden-space`, `container`, `plant-instance`, `plant-profile`,
  `care-task`, `round-trip` + `_helpers.ts` (Ajv `strict: true`).
- **No care-engine unit tests yet** (`computeInitialWaterTask` only referenced as
  plan test #7).
- **`npm test` has not run yet** — `vitest` devDependency, `node_modules` absent.
  `npm install` is now **approved** (PD-04) and runs in Option B commit 1; until
  then `npm test` reports `vitest: not found`. That first run also executes the
  pre-existing schema tests for the first time (never previously run).

## Production behavior state

**Still NONE.** care-engine placeholder · no DB tables · no Kotlin · no AI /
weather / photos / notifications / auth / camera / location runtime code.

## Next recommended action

**Option B — red-first care-engine tests** for `computeInitialWaterTask`
(Slice 1 plan tests #7–#14; formula D-10), as a **two-commit** sequence (owner
approved `npm install` on 2026-05-31 — PD-04):
1. `chore(backend): install dependencies and commit lockfile` — `npm install` in
   `backend/` (`node_modules/` git-ignored), run `npm test` to establish the
   pre-existing-tests baseline (first ever execution), commit `package-lock.json`.
2. `test(care-engine): add Slice 1 watering-engine failing tests` — add
   `backend/tests/care-engine/compute-initial-water-task.test.ts` (loads the engine
   via a **dynamic import** so the suite loads and the 8 tests fail per-test, not at
   collection), run `npm test` to confirm the 8 fail red (`is not a function`), commit.

Do **not** implement the engine (keep `care-engine/index.ts` placeholder) — that is
the later green commit. Exact pasteable prompt: `prompts/next-implementation-prompt.md`.

**Watch-for:** this is the **first time vitest runs** in PlantApp, so the
pre-existing schema tests execute for the first time. If any fail, that is a new
finding to triage (separate from the intended care-engine red).

## Evidence (paths : line — fact)

- PlantApp HEAD/origin == `b2836ca` (verified `git rev-parse` both sides)
- `backend/tests/schema/garden-space.test.ts` — stale note removed at `b2836ca`
- `backend/care-engine/index.ts:5` — still `export {};`
- `shared-schemas/plant-profile.schema.json:41` — `wateringProfile.baseIntervalDays`
- `shared-schemas/plant-profile.schema.json:65` — `containerProfile.recommendedMinLiters`
- `shared-schemas/container.schema.json:13` — `volumeLiters` exclusiveMinimum 0
- `shared-schemas/care-task.schema.json:8,31-49` — CareTask required fields + `sourceInputs`

## Standalone verification gate (PD-05)

- The standalone verification gate is now part of the planner workflow (CLAUDE.md,
  `.claude/rules/prompt-contract.md`, the `implementation-prompt-writer` skill, and
  the `prompt-writer` / `slice-planner` agents).
- **Current Option B** is red-first care-engine testing, so its standalone
  verification is the backend test run: `cd backend && npm test` (after `npm install`
  in commit 1) — schema tests pass; the 8 new care-engine tests fail with
  `computeInitialWaterTask is not a function`.
- **Full Slice 1** standalone verification (e.g. `just verify-slice-1`) does **not**
  exist yet; introduce it once enough backend/API/Android code exists.
