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
- **`npm test` still cannot run** — `vitest` devDependency, `node_modules` absent,
  `npm install` not approved. Expected: `vitest: not found`. Environmental, not a
  regression. **This gates how "red-first" works for the next step** (see below).

## Production behavior state

**Still NONE.** care-engine placeholder · no DB tables · no Kotlin · no AI /
weather / photos / notifications / auth / camera / location runtime code.

## Next recommended action

**Option B — red-first care-engine tests** for `computeInitialWaterTask`
(Slice 1 plan tests #7–#14; formula D-10).
Commit: `test(care-engine): add Slice 1 watering-engine failing tests`.
New file: `backend/tests/care-engine/compute-initial-water-task.test.ts`.
Do **not** implement the function (keep `care-engine/index.ts` placeholder) — the
implementation is a later, separate commit (green step).

**OPEN DECISION blocking the exact shape of Option B:** whether to approve
`npm install` in `backend/` so the tests can actually execute and fail red for the
right reason.
- If **approved:** Option B becomes two commits — (1) install + commit
  `package-lock.json`, (2) add tests + run `npm test` to confirm red.
- If **not approved (current default):** Option B is one commit — add the test
  file only; "red" is structural (it imports an unimplemented export); `npm test`
  still reports `vitest: not found`.
The pasteable prompt in `prompts/next-implementation-prompt.md` is written for the
**no-install default**; it will be upgraded if install is approved.

## Evidence (paths : line — fact)

- PlantApp HEAD/origin == `b2836ca` (verified `git rev-parse` both sides)
- `backend/tests/schema/garden-space.test.ts` — stale note removed at `b2836ca`
- `backend/care-engine/index.ts:5` — still `export {};`
- `shared-schemas/plant-profile.schema.json:41` — `wateringProfile.baseIntervalDays`
- `shared-schemas/plant-profile.schema.json:65` — `containerProfile.recommendedMinLiters`
- `shared-schemas/container.schema.json:13` — `volumeLiters` exclusiveMinimum 0
- `shared-schemas/care-task.schema.json:8,31-49` — CareTask required fields + `sourceInputs`
