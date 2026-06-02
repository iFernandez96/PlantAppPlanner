# DONE — handoff 0019-list-endpoints (backlog 3a, red→green, one commit)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** three read-only list endpoints added (`GET /plant-profiles`,
`GET /garden-spaces`, `GET /containers`) feeding the future add-plant selectors, with
schema-validated, RLS-isolated integration tests. Integration 31/31, unit 67/67,
validate-schemas + typecheck + lint clean.
Final `origin/master` = `c7b8c54fa70163c3e974d50bec5d9fa9f4f3464d`.

## Baseline precondition — matched
- HEAD = `392ba8640aea98f4091e8a61c4180495c4bbf0f9` == origin/master; clean.
- Local Supabase running; env via `npx supabase status -o env`; no keys committed.

## The three handlers (all `onRequest: requireAuth`, read-only)
- **`GET /plant-profiles`** — global species catalog: `select * from plant_profiles order
  by id asc`, mapped through the new `toPlantProfile`. **Not user-scoped** (the catalog
  RLS allows all authenticated reads).
- **`GET /garden-spaces`** — the caller's spaces: `select * order by created_at asc` →
  `toGardenSpace`. **RLS-scoped** (no manual `user_id` filter — mirrors `GET /plants`).
- **`GET /containers`** — the caller's containers, same shape → `toContainer`.
All three only read; none insert/update/delete; none create a CareTask.

## New mapper — `toPlantProfile` (backend/src/mappers.ts)
Maps `plant_profiles` snake_case → the camelCase keys in `plant-profile.schema.json`
using the existing `put()` helper (omits null/undefined optionals). Required: id,
scientificName, commonNames, category, growthHabit, requiresSupport,
pollinationPartnersRequired, wateringProfile/feedingProfile/containerProfile/
lightProfile/temperatureProfile (jsonb passed through camelCase), version. Optional via
put(): selfFruitful, seasonality, commonIssues, verticalSuitability (coerced with
`Number(...)` when present — pg `numeric` deserializes as string, schema requires number),
source, lastReviewedAt. No field invented beyond the schema.

## Red-first → green
- Wrote `backend/tests/integration/lists-api.integration.test.ts` first; `npm run
  test:int` (RED): **6 failed | 25 passed (31)** — the three list endpoints don't exist
  yet (200/401 expectations fail). Then implemented the mapper + endpoints.
- After: `npm run test:int` → **31 passed (31)**; `npm test` → **67 passed (67)**;
  `npm run validate-schemas` green; `npm run typecheck` + `npm run lint` clean.

## Tests (the new file)
- `GET /plant-profiles` → 200, non-empty (≥5 seed profiles), every element validates
  against `plant-profile.schema.json`, contains `solanum-lycopersicum`.
- `GET /garden-spaces` → user A creates one, then GET returns it (schema-valid); user B's
  GET excludes it (RLS isolation).
- `GET /containers` → same shape/assertions against `container.schema.json`.
- All three without a bearer token → 401.

## Compliance
- Only 3 files changed (`git show --stat`: `backend/src/app.ts` +33, `backend/src/mappers.ts`
  +31, the new test +113). `backend/care-engine/**`, `shared-schemas/**`, `supabase/**`,
  `backend/src/auth.ts`, `backend/src/config.ts`, and `android/**` UNCHANGED
  (`git diff --quiet HEAD`). No schema/migration/seed/engine/POST-handler change. No new
  deps. Endpoints strictly read-only; RLS lists rely on RLS (no manual `user_id` filter).

## Commit
- `c7b8c54` — feat(api): list endpoints for plant-profiles, garden-spaces, containers

`npm run test:int`: 25 → **31** (new: GET /plant-profiles catalog; GET /garden-spaces
RLS; GET /containers RLS; 401×3 parameterized).

Final `origin/master` SHA: `c7b8c54fa70163c3e974d50bec5d9fa9f4f3464d`

## Next (3b, per planner follow-up)
Android add-plant **selectors**: profile dropdown from `GET /plant-profiles`;
garden-space/container select-or-create from the new lists — `:network` DTOs +
`:data` calls + `:feature-inventory` Compose UI tests, replacing the id text fields.
Then 3c (magic-link sign-in → DataStore token), 3d (advisory→accept→CareTask).
