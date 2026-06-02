# DONE — handoff 0015-advisory-engine (S2.1, two commits red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** deterministic `computeAdvisories` engine added (container-size / support /
pollination); red-first unit tests green with every advisory validated against
`advisory.schema.json`; `npm test` 67/67, typecheck + lint clean.
Final `origin/master` = `4f3d76a6d8c85b6f847e01b690590c0e54a98861`.

## Baseline precondition — matched
- HEAD = `06f581d029e191992214a1cd3ee0da0514c345e9` == origin/master; clean.

## Commit 1 (RED) — `test(care-engine): add Slice 2 advisory-engine failing tests`
- Hash: `1077764`
- `backend/tests/care-engine/compute-advisories.test.ts`: loads `computeAdvisories` via a
  dynamic import in `beforeAll`; compiles `advisory` schema via `compileSchema`. Covers
  container-size (passion-fruit-like, 19 L → one high advisory whose message contains 95 &
  190, schema-valid; 95 L → none), support (requiresSupport && not recorded → one; recorded
  → none), pollination (tomatillo-like instanceCount 1 → one mentioning "self-fruitful";
  count 2 → none), a no-advisory case, and an invariant/determinism check (returns
  `Advisory[]`, never a CareTask shape; equal inputs → equal output; all schema-valid).
- `npm test` (RED): the new file's 6 tests skipped (dynamic import of `advisories.js`
  failed in beforeAll); prior 61 pass. Intended red.
- `git show --stat`: 1 file, +149. Pushed `06f581d..1077764`.

## Commit 2 (GREEN) — `feat(care-engine): add deterministic advisory engine (Slice 2)`
- Hash: `4f3d76a`
- `backend/care-engine/advisories.ts` exports `Advisory`, `ComputeAdvisoriesInput`, and
  `computeAdvisories(input): Advisory[]` — pure (no I/O, no Date.now/random):
  - **container-size** (severity high) when `volumeLiters < recommendedMinLiters`; message
    cites the recommended minimum and the ideal range when present (`X–Y L`) and suggests
    moving to a larger container of that target size (no brand); `details` carries
    currentVolumeLiters / recommendedMinLiters / ideal min/max (omitted when absent).
  - **support** (severity medium) when `requiresSupport === true && supportRecorded !== true`.
  - **pollination** (severity medium) when `selfFruitful === false && profileInstanceCount
    < (pollinationPartnersRequired ?? 0)`; message notes it's not self-fruitful; `details`
    carries instanceCount / requiredPartners. Cleared (not emitted) when the count meets
    the requirement.
  - Display name = `commonNames[0] ?? profile.id`. Returns 0..3 advisories; never a CareTask.
- `npm test` → **67 passed (67)**; `npm run typecheck` clean; `npm run lint` clean.
- `git show --stat`: 1 file, +94. Pushed `1077764..4f3d76a`.

## Verification
- `cd backend && npm test`: RED at commit 1 (advisory-engine tests skipped/failed; 61
  pass) → GREEN at commit 2 (**67 passed**). Each emitted advisory is validated against
  `shared-schemas/advisory.schema.json` inside the tests (Ajv via `_helpers.ts`).
- Invariant verified: results are `Advisory[]` with no `engineVersion`/`inputsHash`/`dueAt`
  (no CareTask shape) and kinds limited to the three advisory kinds.

## Compliance
- No API/Android/seed/migration changes (those are S2.2). `computeInitialWaterTask`
  (`backend/care-engine/index.ts`), `advisory.schema.json`, other schemas, migrations, the
  API (`backend/src/`), and existing tests UNCHANGED (`git diff --quiet HEAD`). No new
  deps. `@slice-2` `.feature` files untouched. Engine returns no CareTasks (invariant).
- (The pre-existing `validate-schemas` CLI failure from S2.0 is unchanged and out of scope
  here; flagged previously for a tooling-hygiene handoff.)

## Commit hashes + titles
1. `1077764` — test(care-engine): add Slice 2 advisory-engine failing tests
2. `4f3d76a` — feat(care-engine): add deterministic advisory engine (Slice 2)

Final `origin/master` SHA: `4f3d76a6d8c85b6f847e01b690590c0e54a98861`

## Next (S2.2, per planner follow-up)
`GET /plants/:id/advisories` (load plant/profile/container + the caller's active-instance
count for the profile, call `computeAdvisories`, return schema-conformant `Advisory[]`,
RLS-scoped) + integration tests mapping the BDD scenarios; enrich the seed catalog + a new
migration adding `idealMinLiters/idealMaxLiters` to `plant_profiles` (e.g. passion fruit
95/190). Then S2.3 Android display. Also pending: the small `validate-schemas` tooling-fix
handoff.
