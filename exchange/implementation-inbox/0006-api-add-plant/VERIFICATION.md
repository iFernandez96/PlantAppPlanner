# VERIFICATION — handoff 0006-api-add-plant (red→green, objective evidence)

Integration command:
`set -a; eval "$(npx supabase status -o env)"; set +a; export SUPABASE_URL/ANON_KEY/SERVICE_ROLE_KEY; cd backend && npm run test:int`
(Fastify `app.inject()`; test user provisioned via service-role admin API. Keys read at
runtime from `supabase status`; never committed.)

## Commit 2 (`3b263d1`) — RED (no server yet)
```
 FAIL  tests/integration/plants-api.integration.test.ts
 Error: Failed to load url ../../src/app.js — Does the file exist?
 Test Files  1 failed | 2 passed (3)
      Tests  12 passed | 5 skipped (17)
```
The new API suite cannot load `../../src/app.js` (not implemented). Prior 12
integration tests still pass. `npm run test:int` exited non-zero — intended red.

## Commit 3 (`1cd2eac`) — GREEN
```
 ✓ tests/integration/core-tables.integration.test.ts (9 tests)
 ✓ tests/integration/garden-spaces-schema.integration.test.ts (3 tests)
 ✓ tests/integration/plants-api.integration.test.ts (5 tests)
 Test Files  3 passed (3)
      Tests  17 passed (17)
```
The 5 new API tests pass:
- **#15** `POST /plants` → 201 with one water task (engineVersion `0.1.0`, non-empty
  `inputsHash`, `priority normal`, `dueAt`, `sourceInputs.wateringBaselineAt =
  2026-05-26T07:00:00.000Z`); `GET /plants/:id/tasks` → 200 with exactly one `water` task.
- **#16** missing `containerId` → 400.
- **#17** missing `gardenSpaceId` → 400.
- **#18** unknown `profileId` → 400.
- unauthenticated `POST /plants` → 401 (auth `onRequest` hook runs before validation).
`npm run test:int` exited 0.

## Unit suite + typecheck
```
$ npm run typecheck   -> clean (tsc --noEmit)
$ npm test
 Test Files  8 passed (8)
      Tests  50 passed (50)
```

## Scope / integrity
- `backend/care-engine/**`, `shared-schemas/**`, `supabase/migrations/**`, and existing
  `backend/tests/**` unchanged (`git diff --quiet HEAD`).
- Engine imported (`computeInitialWaterTask`), not reimplemented.
- Each commit changed only its intended files (4 / 1 / 3). Deps added: fastify,
  @supabase/supabase-js. No keys committed.

## Pre-existing (not a regression)
`npm run lint` → 15 parse errors, all in `tests/**` + `eslint.config.js` +
`vitest*.config.ts` (files outside `tsconfig.include`); zero `src/**` files. Predates
this handoff; lint is not a verification gate here; config fix is out of scope (forbidden
files). Flagged in REPORT.md for a dedicated lint-config handoff.

## Final repo state
- origin/master = `1cd2eac8354427c8afe24de9304cda594d4de53e`; local == origin.
- Local Supabase stack left running; all migrations applied — ready for A3b
  (#19 RLS isolation, #20 DELETE cascade).
