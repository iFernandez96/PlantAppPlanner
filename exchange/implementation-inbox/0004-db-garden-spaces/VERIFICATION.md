# VERIFICATION — handoff 0004-db-garden-spaces (red→green, objective evidence)

Integration command: `cd backend && npm run test:int` (config:
`vitest.integration.config.ts`, pattern `*.integration.test.ts`).
DB: local Supabase Postgres `postgresql://postgres:postgres@127.0.0.1:54322/postgres`.

## Commit 2 (`8d1905a`) — RED (DB has only migration 0001)
After `supabase db reset` applied just `0001_init_extensions.sql`:
```
 FAIL  tests/integration/garden-spaces-schema.integration.test.ts
   × garden_spaces table exists                  -> rows.length 0
   × garden_spaces has row-level security enabled -> error: relation "public.garden_spaces" does not exist
   × garden_spaces has owner RLS policies (>= 4)  -> expected 0 to be >= 4
 Test Files  1 failed (1)
      Tests  3 failed (3)
```
- The `pg` client connected successfully; the failures are the missing
  `public.garden_spaces` relation/policies — the intended red.
- `npm run test:int` exited non-zero.

## Commit 3 (`e92bc0f`) — GREEN (migration 0002 applied)
After `supabase db reset` applied `0001` + `0002_slice1_garden_spaces.sql`:
```
 ✓ tests/integration/garden-spaces-schema.integration.test.ts (3 tests)
 Test Files  1 passed (1)
      Tests  3 passed (3)
```
Proven:
1. `public.garden_spaces` exists (information_schema lookup returns 1 row).
2. RLS enabled (`pg_class.relrowsecurity = true`).
3. ≥4 owner RLS policies present (select/insert/update/delete on `auth.uid() = user_id`).
`npm run test:int` exited 0.

## Unit suite unaffected
```
$ npm test
 Test Files  8 passed (8)
      Tests  50 passed (50)
```
Same 50/50 as before this handoff — care-engine and schema tests untouched.

## Migration apply evidence
`supabase db reset` (commit 3) log:
```
Applying migration 0001_init_extensions.sql...
Applying migration 0002_slice1_garden_spaces.sql...
Finished supabase db reset on branch master.
```
No SQL errors; `gen_random_uuid()` resolved via pgcrypto from 0001.

## Scope / integrity
- `backend/care-engine/**` and `shared-schemas/**` unchanged (`git diff --quiet HEAD`).
- Each commit changed exactly the intended files (4 / 1 / 1).
- Deps added: only `pg` + `@types/pg` (devDependencies).
- No vitest config edits; integration suite isolated from the unit suite.

## Final repo state
- origin/master = `e92bc0f7bebaf02a15acea13b7f7ecd90ff47c1a`
- local master == origin/master
- working tree clean (untracked: git-ignored `backend/node_modules/`, `supabase/.temp/`,
  `supabase/.branches`)
- Local Supabase stack left running for A2; DB URL as above.
