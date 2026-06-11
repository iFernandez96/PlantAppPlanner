# Standalone verification — 0061

Type: red-first → green; proves a from-scratch `db reset` yields a working database.

## 1. RED (grants test present, migration 0006 absent; bare reset 0001–0005)
```
 ❯ tests/integration/grants.integration.test.ts (2 tests | 1 failed)
   × baseline grants survive db reset (0006) > authenticated can select plant_profiles at the table-grant level
     → expected 0 to be greater than 0
 Test Files  7 failed | 3 passed (10)
      Tests  20 failed | 18 passed (38)
```
- Pre-existing authed-API tests broken in the same run (POST → 400 wrapping Postgres
  permission-denied), reproducing the 0060 harness break end-to-end.
- DB-layer probe of the broken state: `authenticated` held only
  `{REFERENCES,TRIGGER,TRUNCATE}` on all 5 public tables — no SELECT/INSERT/UPDATE/DELETE.
- Note: schema `usage` survived the reset, so the first grants test passed; only the
  table-grant test was red (deviation noted in REPORT §5).
- No manual repair performed (per §6).

## 2. Migration apply
```
Applying migration 0006_w2_baseline_grants.sql...
Finished supabase db reset on branch master.
```

## 3. GREEN
```
$ npm run test:int
 Test Files  10 passed (10)
      Tests  38 passed (38)        # incl. both grants tests

$ npm test
 Test Files  11 passed (11)
      Tests  73 passed (73)        # DB-free unit suite, unchanged throughout
```
Zero manual repair between reset and green — the property every future seed-batch slice
depends on.
