# DONE — handoff 0016-advisories-api (S2.2, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** `GET /plants/:id/advisories` added (RLS-scoped, computed-on-read, no CareTask);
seed + DB enriched with ideal container ranges; the `@slice-2` BDD scenarios pass as
integration tests with every response validated against `advisory.schema.json`.
Integration 25/25, unit 67/67, typecheck + lint clean.
Final `origin/master` = `8d3e813cc35f37f6b2cbf592dfbfb47bd072b096`.

## Baseline precondition — matched
- HEAD = `4f3d76a6d8c85b6f847e01b690590c0e54a98861` == origin/master; clean.
- Local Supabase running; env via `npx supabase status -o env`; no keys committed.

## Commit 1 (RED) — `test(api): add Slice 2 advisories-endpoint integration tests (red)`
- Hash: `623c91f`
- `backend/tests/integration/advisories-api.integration.test.ts`: provisions two users;
  maps the `@slice-2` scenarios — container-size (passion fruit 19 L → `container-size`
  `high`, message cites 95 & 190), support (passion fruit, large container, no
  supportRecorded → `support` present), pollination single → present, second tomatillo →
  cleared, and RLS (user B → 404). Asserts **presence** (not array length) and validates
  every returned advisory against `advisory.schema.json`.
- `npm run test:int` (RED): the 200-expecting advisory tests failed (route missing); 22
  prior passed. Intended red.
- `git show --stat`: 1 file, +145. Pushed `4f3d76a..623c91f`.

## Commit 2 (GREEN) — `feat(api): add GET /plants/:id/advisories + seed ideal container range (Slice 2)`
- Hash: `8d3e813`
- `backend/src/app.ts`: `GET /plants/:id/advisories` (existing `onRequest` auth hook,
  request-scoped Supabase client → RLS). Loads the plant (404 if not owned/visible), its
  `plant_profiles` row, its `containers` row, and `profileInstanceCount` = count of the
  caller's `plant_instances` with the same `profile_id` (RLS scopes the count to the
  user, via `select('id', { count: 'exact', head: true })`). Maps snake→camel
  (`container_profile` jsonb is already camelCase), calls `computeAdvisories(...)`, returns
  the `Advisory[]` with 200. Persists nothing; creates no CareTask.
- `supabase/migrations/0004_slice1_profile_ideal_range.sql`: jsonb-merges
  `idealMinLiters/idealMaxLiters` into the seeded `plant_profiles.container_profile`
  (preserving `recommendedMinLiters`).
- `backend/care-engine/seed-profiles.ts`: `SeedPlantProfile.containerProfile` gains
  optional `idealMinLiters/idealMaxLiters`; each seed mirrors the migration values.
- `docs/slice-02-implementation-plan.md`: seed-gap note updated from "address in S2.1" to
  "addressed in S2.2 (migration 0004)".
- After `supabase db reset` (0001–0004): `npm run test:int` → **25 passed (25)** (4 new
  advisories tests incl. the BDD scenarios + RLS); `npm test` → **67 passed (67)**;
  `npm run typecheck` clean; `npm run lint` clean.
- `git show --stat`: 4 files, +119/−11. Pushed `623c91f..8d3e813`.

## Ideal ranges chosen per seed profile (L, ≥ recommendedMinLiters)
- `passiflora-edulis` (passion fruit): 95 / 190 (per the BDD scenario).
- `solanum-lycopersicum` (tomato): 19 / 40.
- `physalis-philadelphica` (tomatillo): 19 / 40.
- `fragaria-x-ananassa` (strawberry): 4 / 10.
- `ocimum-basilicum` (basil): 3 / 8.

## Verification
- `npm run test:int`: RED at commit 1 (route missing) → GREEN at commit 2 (25/25). The
  container-size advisory now cites the ideal range (95 & 190) because the seeded profile
  carries `idealMinLiters/idealMaxLiters` after migration 0004. Pollination clears when a
  second tomatillo is added (RLS-scoped instance count = 2). user B → 404 (RLS).
- Every returned advisory validates against `advisory.schema.json` in-test.
- No CareTask created by the endpoint (it only reads + computes).

## Compliance
- `computeAdvisories`, `computeInitialWaterTask`, `advisory.schema.json` + other schemas,
  prior migrations (0001–0003), the auth hook, and the existing POST endpoints' behavior
  UNCHANGED (`git diff --quiet HEAD`). No Android changes. No new deps. `@slice-2`
  `.feature` files untouched.
- (Pre-existing `validate-schemas` CLI failure unchanged — still pending its hygiene handoff.)

## Commit hashes + titles
1. `623c91f` — test(api): add Slice 2 advisories-endpoint integration tests (red)
2. `8d3e813` — feat(api): add GET /plants/:id/advisories + seed ideal container range (Slice 2)

Final `origin/master` SHA: `8d3e813cc35f37f6b2cbf592dfbfb47bd072b096`

## Next (S2.3, per planner follow-up — closes Slice 2)
Android: `:network` `AdvisoryDto` + `PlantAppApi.getAdvisories`; `:data` repo
`getAdvisories(plantId)` (DTO→domain); `:feature-inventory` plant detail surfaces
advisories (severity-styled messages) + a Compose UI test. Also still pending: the small
`validate-schemas` tooling-fix handoff.
