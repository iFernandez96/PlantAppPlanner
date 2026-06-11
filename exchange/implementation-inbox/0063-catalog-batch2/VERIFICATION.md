# Standalone verification — 0063

Type: red-first → green; checksummed attachment; objective DB spot-proof.

## 0. Attachment integrity
```
sha256sum -c SHA256SUMS → PROMPT.md: OK / batch2_herbs_berries.sql: OK / MANIFEST.json: OK
repo copy == attachment: a3250d3729c9b08b7bfb7c208724a1fa012c4a46371d9f1f1d9b5dba86496401 (both)
```

## 1. RED (test edits only; DB at 0001–0007)
```
× batch 1 > catalog total …            → expected 20 to be 38
× batch 2 > all 20 present             → [fragaria-x-ananassa, ocimum-basilicum] ≠ 20 ids
× batch 2 > citations + version        → slice-1 strawberry/basil rows flagged
× batch 2 > enriched in place          → version 1 (expected ≥ 2)
 Test Files  1 failed | 10 passed (11)
      Tests  4 failed | 41 passed (45)
```

## 2. Migration apply
```
Applying migration 0008_w2_catalog_batch2_herbs_berries.sql...
Finished supabase db reset on branch master.
```

## 3. GREEN
```
npm run test:int → 45 passed (45)
npm test         → 73 passed (73)
```

## 4. DB spot-proof
```
fragaria-x-ananassa  citations=5   version=2
salvia-rosmarinus    citations=10  version=1
total rows: 38
```
