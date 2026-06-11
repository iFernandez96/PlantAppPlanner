# Implementation report — 0061-baseline-grants

## Status: DONE

## 1. Scope confirmation + git show --stat HEAD
Only the 2 new files:
```
 .../tests/integration/grants.integration.test.ts   | 29 ++++++++++++++++++++++ (new)
 supabase/migrations/0006_w2_baseline_grants.sql    | 11 ++++++++ (new)
 2 files changed, 40 insertions(+)
```
Migration 0006 verbatim §5a; grants test verbatim §5b. Migrations 0001–0005, backend src/,
schemas, Android, RLS policies, package.json all untouched; `android/.kotlin/` left untracked.

**Security note (per §1):** the grants are TABLE-level Supabase platform defaults; row access
remains governed by RLS, which is enabled on every table (anon has no policies → no rows).
Parity with hosted Supabase, no widening of row access.

## 2. RED evidence (test added; bare reset applying only 0001–0005)
```
$ npx supabase db reset   # 0001–0005, no 0006
Finished supabase db reset on branch master.
$ npm run test:int
 ❯ tests/integration/grants.integration.test.ts (2 tests | 1 failed)
   × baseline grants survive db reset (0006) > authenticated can select plant_profiles at the table-grant level
     → expected 0 to be greater than 0
 Test Files  7 failed | 3 passed (10)
      Tests  20 failed | 18 passed (38)
```
The pre-existing authed-API tests failed exactly as in 0060 — POSTs returning 400 because the
underlying inserts hit Postgres permission-denied (42501). Probe of the broken state (the
42501 sample, surfaced at the DB layer since the API maps it to a 400 body):
```
authenticated per-table privileges after bare reset:
  care_tasks / containers / garden_spaces / plant_instances / plant_profiles
    → {REFERENCES,TRIGGER,TRUNCATE}   (no SELECT/INSERT/UPDATE/DELETE)
```
The broken state was NOT manually repaired this time, per §6.

## 3. GREEN (after creating 0006 + reset)
Reset log:
```
Applying migration 0005_w2_houseplant_category.sql...
Applying migration 0006_w2_baseline_grants.sql...
Finished supabase db reset on branch master.
```
Suites:
```
npm run test:int → Test Files  10 passed (10)   Tests  38 passed (38)   (incl. the 2 new tests)
npm test         → Test Files  11 passed (11)   Tests  73 passed (73)   (unchanged, DB-free)
```
A from-scratch `db reset` now yields a fully working database with zero manual repair.

## 4. Commit + push
- New commit: `65dece9ca9e24d464bae724d6719b7ad9a61c2ff`
- Title (exact): `fix(db): baseline role grants as migration — db reset yields a working database`
- Pushed: `22067b6..65dece9  master -> master`; new `origin/master` =
  `65dece9ca9e24d464bae724d6719b7ad9a61c2ff`.

## 5. Deviations
One observational deviation from §6/§7's prediction, no action taken: the prompt expected
**both** new grants tests to fail in the red step, but only the table-grant test failed —
this CLI's reset *does* retain `usage` on schema `public` (the schema-usage test passed) while
dropping the DML table grants (only REFERENCES/TRIGGER/TRUNCATE remain). The test file was
kept verbatim as prescribed; the schema-usage test still guards the other half of the
regression surface. Also per §6 (expected): the resets wiped local auth users again — the
device account needs a Mailpit re-sign-in at the next device session.
