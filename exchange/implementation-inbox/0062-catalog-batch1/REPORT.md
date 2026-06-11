# Implementation report — 0062-catalog-batch1

## Status: DONE

## 1. Scope confirmation + git show --stat HEAD
Exactly the 3 files:
```
 .../integration/core-tables.integration.test.ts    |  7 ++-
 .../integration/w2-catalog.integration.test.ts     | 56 ++++++++++++++++++++++ (new)
 .../0007_w2_catalog_batch1_vegetables_roots.sql    | 40 ++++++++++++++++ (new)
 3 files changed, 101 insertions(+), 2 deletions(-)
```
- Migration 0007 = **verbatim attachment copy** (byte-identical; both files hash to
  `99957dbb696b59251892429eee4b25b479e4c1fc35633e20bd70ee086a6d3157`). Pre-copy sanity skim:
  one clean 16-row `insert … on conflict (id) do update` into `public.plant_profiles`, no
  DDL/grant/delete statements.
- `w2-catalog.integration.test.ts` verbatim §5b; `core-tables` seed test rewritten to the
  §5c subset assertion.
- Migrations 0001–0006, backend src/, schemas, Android, engine, `seed-profiles.ts`,
  RLS/grants all untouched; `android/.kotlin/` left untracked.

## 2. Attachment checksum verification
```
$ cd …/exchange/planner-outbox/0062-catalog-batch1 && sha256sum -c SHA256SUMS
PROMPT.md: OK
batch1_vegetables_roots.sql: OK
MANIFEST.json: OK
```

## 3. RED → GREEN
**RED** (tests added; reset applied 0001–0006 only):
```
× all 16 batch-1 profiles are present        → expected [ 'solanum-lycopersicum' ] to deeply equal [ 'allium-fistulosum', …(15) ]
× every batch-1 profile carries citations…   → expected [ { id: 'solanum-lycopersicum' } ] to deeply equal []
× tomato was enriched in place…              → expected 'fruit' to be 'vegetable'
× catalog total matches the seeded batches   → expected 5 to be 20
 Test Files  1 failed | 10 passed (11)
      Tests  4 failed | 38 passed (42)
```
Exactly the 4 new tests red; the rewritten core-tables subset test passed; zero regressions.

**Reset log (after copying 0007):**
```
Applying migration 0006_w2_baseline_grants.sql...
Applying migration 0007_w2_catalog_batch1_vegetables_roots.sql...
Finished supabase db reset on branch master.
```
(0006 grants migration from 0061 did its job — no manual repair needed at any point.)

**GREEN:**
```
npm run test:int → Test Files  11 passed (11)   Tests  42 passed (42)
npm test         → Test Files  11 passed (11)   Tests  73 passed (73)
```

## 4. Citation spot-proof
```
┌─────────┬────────────────────────┬───────────┬─────────┐
│ (index) │ id                     │ citations │ version │
├─────────┼────────────────────────┼───────────┼─────────┤
│ 0       │ 'daucus-carota'        │ 11        │ 1       │
│ 1       │ 'solanum-lycopersicum' │ 12        │ 2       │
└─────────┴────────────────────────┴───────────┴─────────┘
```
Carrot (new) carries 11 citations; tomato enriched in place to version 2 with 12 citations,
category now `vegetable` (expected per §1). Catalog total: 20 rows.

## 5. Commit + push
- New commit: `5f5b8e5f644d7f352ccfb8b39654b1e76f30935d`
- Title (exact): `feat(catalog): seed W2 batch 1/4 — 16 cited vegetable and root profiles`
- Pushed: `65dece9..5f5b8e5  master -> master`; new `origin/master` =
  `5f5b8e5f644d7f352ccfb8b39654b1e76f30935d`.

## 6. Deviations
None. (Known §6 side-effect: the resets wiped local auth users again — device account
re-signs-in via Mailpit at the next device session.)
