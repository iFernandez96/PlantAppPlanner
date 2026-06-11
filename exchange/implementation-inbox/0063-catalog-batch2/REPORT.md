# Implementation report — 0063-catalog-batch2

## Status: DONE

## 1. Scope confirmation + git show --stat HEAD
Exactly the 2 files:
```
 .../integration/w2-catalog.integration.test.ts     | 40 +++++++++++++++++++-
 .../0008_w2_catalog_batch2_herbs_berries.sql       | 44 ++++++++++++++++++++++ (new)
 2 files changed, 83 insertions(+), 1 deletion(-)
```
- Migration 0008 = verbatim attachment copy (byte-identical; both hash to
  `a3250d3729c9b08b7bfb7c208724a1fa012c4a46371d9f1f1d9b5dba86496401`). Sanity skim: a single
  20-row `insert … on conflict (id) do update` into `public.plant_profiles`, no DDL/grant/
  delete statements.
- Test file: `EXPECTED_PROFILE_COUNT` 20 → 38, `BATCH2_IDS` constant, batch-2 describe block —
  all verbatim §5b.
- Migrations 0001–0007, core-tables test, backend src/, schemas, Android, engine, RLS/grants,
  seed-profiles.ts untouched; `android/.kotlin/` left untracked.

## 2. Attachment checksum verification
```
$ sha256sum -c SHA256SUMS
PROMPT.md: OK
batch2_herbs_berries.sql: OK
MANIFEST.json: OK
```

## 3. RED → GREEN
**RED** (test edits in; reset applied 0001–0007 only):
```
× batch 1 > catalog total matches the seeded batches      → expected 20 to be 38
× batch 2 > all 20 batch-2 profiles are present           → only strawberry+basil found of 20
× batch 2 > every batch-2 profile carries citations…      → slice-1 strawberry/basil had none
× batch 2 > strawberry and basil were enriched in place…  → expected false to be true (v1)
 Test Files  1 failed | 10 passed (11)
      Tests  4 failed | 41 passed (45)
```
Exactly the §6-predicted red (3 batch-2 tests + the bumped count test); zero regressions.

**Reset log (after copying 0008):**
```
Applying migration 0008_w2_catalog_batch2_herbs_berries.sql...
Finished supabase db reset on branch master.
```

**GREEN:**
```
npm run test:int → Test Files  11 passed (11)   Tests  45 passed (45)
npm test         → Test Files  11 passed (11)   Tests  73 passed (73)
```

## 4. Citation spot-proof
```
fragaria-x-ananassa  citations=5   version=2   (enriched in place, category stays 'berry')
salvia-rosmarinus    citations=10  version=1   (new)
plant_profiles total: 38
```

## 5. Commit + push
- New commit: `4b7b9ad944e84bb10f43cee8d2317b2a17f4ebf5`
- Title (exact): `feat(catalog): seed W2 batch 2/4 — 20 cited herb and berry profiles`
- Pushed: `5f5b8e5..4b7b9ad  master -> master`; new `origin/master` =
  `4b7b9ad944e84bb10f43cee8d2317b2a17f4ebf5`.

## 6. Deviations
None. (Known side-effect: resets wiped local auth users again — device re-sign-in via Mailpit
at the next device session. The 0006 grants migration held — no manual DB repair needed.)
