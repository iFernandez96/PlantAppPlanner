# Next Implementation Prompt — S2.2: GET /plants/:id/advisories + seed ideal-range (red→green)

**Slice 2, step S2.2.** Expose advisories over the API: `GET /plants/:id/advisories`
computes them from the plant/profile/container + the caller's instance count and returns
schema-conformant `Advisory[]` (RLS-scoped). Enrich the seed/DB with the ideal container
range so the container-size advisory can cite it. Integration tests map the `@slice-2` BDD
scenarios. Advisories are computed-on-read; **no CareTask is created** (invariant).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `4f3d76a` == `origin/master`,
clean. `computeAdvisories` (`backend/care-engine/advisories.ts`) + `advisory.schema.json`
exist; `npm test` 67/67, integration 21/21. The Fastify API + auth(RLS) + the request-scoped
Supabase client + `src/mappers.ts` are in place from Slice 1. DB `plant_profiles.container_profile`
is jsonb with **camelCase** inner keys (e.g. `recommendedMinLiters`).

Suggested commits: (1) red advisories-endpoint integration tests; (2) green endpoint +
response mapping; (3) green migration `0004` + seed enrichment + plan-doc fix. (Impl may
reorder/merge as long as red precedes green.)

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the
advisories API endpoint + seed/DB ideal-range, proven by integration tests. Same Supabase
harness as Slice 1 (`npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase status`;
env via `... status -o env`).

### Baseline precondition (STOP if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect 4f3d76a6d8c85b6f847e01b690590c0e54a98861
git status --short                         # expect empty
```

### Endpoint — `GET /plants/:id/advisories` (in `backend/src/app.ts`, existing auth hook)
- RLS-scoped via the request-scoped Supabase client; **404** if the plant isn't owned/visible.
- Load the plant (`plant_instances`), its `plant_profiles` row, and its `containers` row;
  compute `profileInstanceCount` = count of the **caller's** `plant_instances` with the same
  `profile_id`. Map these (snake→camel; `container_profile` jsonb is already camelCase) into
  `ComputeAdvisoriesInput` and call `computeAdvisories(...)` from `../care-engine/advisories.js`.
- Return the engine's `Advisory[]` (already schema-shaped, camelCase) with **200**. Do not
  persist anything; do not create a CareTask.

### Migration `0004` + seed — add ideal container range
- `supabase/migrations/0004_slice1_profile_ideal_range.sql`: enrich the seeded
  `plant_profiles.container_profile` jsonb with `idealMinLiters`/`idealMaxLiters` (jsonb
  merge), at least: `passiflora-edulis` → 95 / 190 (per the BDD). Add sensible ideal ranges
  (≥ `recommendedMinLiters`) for the other four seeds. Keep the `NNNN_` ordering.
- Mirror the same `idealMinLiters/idealMaxLiters` into `backend/care-engine/seed-profiles.ts`
  so the TS catalog and DB agree (these fields are already optional in `plant-profile.schema.json`).

### Fix the stale plan line
In `docs/slice-02-implementation-plan.md`, change the seed-gap note from "address in S2.1"
to "addressed in S2.2" (enrichment happens here, not in the engine step).

### Integration tests — `backend/tests/integration/advisories-api.integration.test.ts`
Provision user(s) via the service-role admin API; reuse the conformance pattern. After
`supabase db reset` (applies 0001–0004), cover the `@slice-2` scenarios — assert
**presence** of the expected advisory (a plant may have more than one; don't assert array
length), and validate every returned advisory against `advisory.schema.json` (Ajv via
`../schema/_helpers.js`):
- **container-size:** passion fruit (`passiflora-edulis`) in a 19 L container →
  `GET /plants/:id/advisories` contains a `container-size` advisory, `severity:"high"`,
  message citing `95` and `190`.
- **support:** a plant whose profile `requiresSupport` and with no `supportRecorded` →
  a `support` advisory present.
- **pollination single:** one `physalis-philadelphica` (tomatillo) → a `pollination`
  advisory present.
- **pollination cleared:** add a second tomatillo (same user) → the first plant's
  `GET advisories` no longer contains a `pollination` advisory.
- **RLS isolation:** user B → `GET /plants/{A's id}/advisories` → **404**.

### Run / verify (the gate)
```bash
npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase db reset   # 0001–0004
cd backend && npm run test:int    # prior 21 + new advisories tests all GREEN
npm test                           # unit still green (67)
npm run typecheck && npm run lint  # clean
```
Red-first: write the advisories integration tests first (red — endpoint 404/route missing),
then implement endpoint + migration + seed → green. If a returned advisory fails schema
validation or the ideal range doesn't surface, STOP and report.

### Forbidden
- No Android changes (S2.3). Don't modify `computeAdvisories`, `computeInitialWaterTask`,
  `advisory.schema.json`, prior migrations (0001–0003), the auth hook, or the existing POST
  endpoints' behavior. No new deps. Don't change the `@slice-2` `.feature` files. The
  endpoint must NOT create a CareTask.

### Final report
1. Commit hashes + titles; final `origin/master` SHA.
2. `npm run test:int` RED→GREEN counts; `npm test` 67; typecheck + lint clean.
3. `git show --stat` per commit; the endpoint + migration `0004` + seed + plan-doc edits;
   confirm the engine/schema/prior-migrations/POST-endpoints untouched and no CareTask created.
4. The ideal ranges chosen per seed profile.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after S2.2 lands
Verify the advisories endpoint + BDD scenarios green + responses schema-valid. Then **S2.3**
(closes Slice 2): Android — `:network` `AdvisoryDto` + `PlantAppApi.getAdvisories`,
`:data` repo `getAdvisories(plantId)` (DTO→domain), and `:feature-inventory` plant-detail
surfaces advisories (severity-styled, the messages) + a Compose UI test. Vision-check S2.3.
Also still pending: the tiny `validate-schemas` tooling-fix handoff.
