# Standalone verification — 0062

Type: red-first → green; checksummed attachment; objective DB spot-proof.

## 0. Attachment integrity
```
sha256sum -c SHA256SUMS → PROMPT.md: OK / batch1_vegetables_roots.sql: OK / MANIFEST.json: OK
repo copy == attachment: 99957dbb696b59251892429eee4b25b479e4c1fc35633e20bd70ee086a6d3157 (both)
```

## 1. RED (tests only; DB at 0001–0006)
```
× all 16 batch-1 profiles are present        → only 'solanum-lycopersicum' found
× every batch-1 profile carries citations    → slice-1 tomato had no source/citations
× tomato was enriched in place               → category 'fruit' (v1)
× catalog total matches the seeded batches   → 5 ≠ 20
 Test Files  1 failed | 10 passed (11)
      Tests  4 failed | 38 passed (42)
```
Rewritten core-tables subset test green in the red run; no regressions.

## 2. Migration apply
```
Applying migration 0007_w2_catalog_batch1_vegetables_roots.sql...
Finished supabase db reset on branch master.
```

## 3. GREEN
```
npm run test:int → 42 passed (42)   (4 new catalog tests included)
npm test         → 73 passed (73)   (unit suite untouched, DB-free)
```

## 4. DB spot-proof
```
daucus-carota         citations=11  version=1
solanum-lycopersicum  citations=12  version=2   (category 'vegetable')
plant_profiles total: 20
```
