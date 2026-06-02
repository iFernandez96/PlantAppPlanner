# VERIFICATION — handoff 0005-db-core-tables (red→green, objective evidence)

Integration command: `cd backend && npm run test:int` (config
`vitest.integration.config.ts`, pattern `*.integration.test.ts`).
DB: local Supabase Postgres `postgresql://postgres:postgres@127.0.0.1:54322/postgres`.

## Commit 1 (`e2c3795`) — RED (DB at 0001+0002)
```
 ✓ garden-spaces-schema.integration.test.ts (3 tests)
 FAIL core-tables.integration.test.ts
 Test Files  1 failed | 1 passed (2)
      Tests  9 failed | 3 passed (12)
```
- The 9 new core-tables assertions fail because `plant_profiles`, `containers`,
  `plant_instances`, `care_tasks` don't exist yet (the seed query errors
  `relation "public.plant_profiles" does not exist`). Intended red.
- The 3 garden_spaces tests (from A1) still pass — no regression.
- `npm run test:int` exited non-zero.

## Commit 2 (`670ebaf`) — GREEN (migration 0003 applied)
`supabase db reset` log:
```
Applying migration 0001_init_extensions.sql...
Applying migration 0002_slice1_garden_spaces.sql...
Applying migration 0003_slice1_core_tables.sql...
Finished supabase db reset on branch master.
```
(no SQL errors)
```
 ✓ tests/integration/garden-spaces-schema.integration.test.ts (3 tests)
 ✓ tests/integration/core-tables.integration.test.ts (9 tests)
 Test Files  2 passed (2)
      Tests  12 passed (12)
```
Proven for `plant_profiles`, `containers`, `plant_instances`, `care_tasks`:
table exists; `pg_class.relrowsecurity = true`; and `plant_profiles` contains exactly
the 5 ordered ids `fragaria-x-ananassa, ocimum-basilicum, passiflora-edulis,
physalis-philadelphica, solanum-lycopersicum`. `npm run test:int` exited 0.

## Unit suite unaffected
```
$ npm test
 Test Files  8 passed (8)
      Tests  50 passed (50)
```

## Scope / integrity
- `backend/care-engine/**`, `shared-schemas/**`, and migrations `0001`/`0002`
  unchanged (`git diff --quiet HEAD` for each).
- Commit 1 added exactly 1 file (test); commit 2 added exactly 1 file (migration).
- No deps added; no vitest config or unit test edits; no HTTP server (A3).

## Final repo state
- origin/master = `670ebaf9c68d5325de0058dcdc7ccf1eefce35b6`
- local master == origin/master
- working tree clean (untracked: git-ignored `backend/node_modules/`, `supabase/.temp/`)
- Local Supabase stack left running with all 3 migrations applied (garden_spaces + 4
  core tables, RLS, 5 seeded profiles) — ready for A3.
