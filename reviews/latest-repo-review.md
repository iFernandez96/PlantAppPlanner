# PlantApp — Repo Review

**Date:** 2026-05-31 (post Option A) · **Reviewer:** PlantAppPlanner control tower
**Repo:** `/home/israel/Documents/Development/PlantApp` @ `b2836ca` (`master`)
**Verdict:** Option A landed cleanly and is verified. No production behavior. Next
step is the first care-engine red-first test (Option B), gated on the `npm install`
decision.

## Option A verification (this review's focus)

| Check | Result |
|---|---|
| Commit on `origin/master`? | ✅ `b2836ca` (fast-forward from `52c9d77`) |
| Files changed | ✅ exactly 1 — `backend/tests/schema/garden-space.test.ts` |
| Comment-only? | ✅ hunk confined to header lines; imports/fixture/assertions unchanged |
| Stale claim removed? | ✅ "does not yet enforce a minLength / fails red" gone |
| Replacement accurate? | ✅ now states schema enforces `minLength:1`, empty-name test is a passing guard |
| Scope creep? | ✅ none — no other file touched |

Method: `git show b2836ca`, `git diff --name-only 52c9d77 b2836ca`,
`git show --stat b2836ca`. The planner did **not** rely on the implementation
Claude's self-report alone.

## Files reviewed for the NEXT step (Option B grounding)

| File | Finding (path:line) |
|---|---|
| `backend/care-engine/index.ts` | placeholder `export {};` (line 5) — unimplemented, correct for red-first |
| `shared-schemas/plant-profile.schema.json` | `wateringProfile.baseIntervalDays` (41, min 0.25); `containerProfile.recommendedMinLiters` (65); `commonNames` (24, minItems 1); `version` (127, int ≥1) |
| `shared-schemas/plant-instance.schema.json` | `createdAt` (39, date-time), optional `lastWateredAt` (24, date-time), `profileId`/`containerId`/`gardenSpaceId` required (8) |
| `shared-schemas/container.schema.json` | `volumeLiters` exclusiveMinimum 0 (13); `id` uuid (10) |
| `shared-schemas/care-task.schema.json` | required incl. `sourceInputs`/`engineVersion`/`inputsHash` (8); `sourceInputs` shape with `wateringBaselineAt` (31–49) |
| `backend/tests/schema/{plant-profile,plant-instance,container}.test.ts` | existing valid fixtures (e.g. tomato `solanum-lycopersicum` baseIntervalDays 2 / recommendedMinLiters 19; container `volumeLiters` 19) — reuse for engine fixtures |

## Blockers

- **None** for authoring the red-first tests.
- **Decision needed (not a blocker, a fork):** approve `npm install` so the tests
  can actually run red? See `state/current-state.md` → "Next recommended action"
  and the question posed to the owner this session.

## Nice-to-fix / track

- After Option B tests are red, the green step `feat(care-engine): implement
  computeInitialWaterTask` is the following commit (separate; not part of Option B).
- App `CLAUDE.md` "Commands" still says "placeholders until code lands"; revisit
  when the first runnable backend code lands (no action now).

## Exact next action

**Option B.** Add `backend/tests/care-engine/compute-initial-water-task.test.ts`
covering plan tests #7–#14 against the D-10 formula; do not implement the engine.
Commit `test(care-engine): add Slice 1 watering-engine failing tests`; push.
Full prompt: `prompts/next-implementation-prompt.md` (written for the no-install
default; upgradeable to a two-commit install variant on owner approval).

## Tooling note

Direct read-only inspection (Read + `git`) again; no bundled `/code-review` or
`/security-review` skill invoked (they target a working diff in the *current* repo,
not a read-only audit of a separate repo). Planner subagents/skills under
`.claude/` encode the repeatable checklists.
