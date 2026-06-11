# Standalone verification — 0064

Type: red-first → green; checksummed attachment; objective DB spot-proof.

## 0. Attachment integrity
```
sha256sum -c SHA256SUMS → PROMPT.md: OK / batch3_fruit_vines_succulents.sql: OK / MANIFEST.json: OK
repo copy == attachment: a6ccab483f10eb422f87395bdbb7f23756a9ec3e393fe52b5d207d5cd8e8fdf3 (both)
```

## 1. RED (test edits only; DB at 0001–0008)
```
× batch 1 > catalog total …  (38 ≠ 51)
× batch 3 > all 15 present
× batch 3 > citations + version
× batch 3 > enriched in place
 Test Files  1 failed | 10 passed (11)
      Tests  4 failed | 44 passed (48)
```

## 2. Migration apply
```
Applying migration 0009_w2_catalog_batch3_fruit_vines_succulents.sql...
Finished supabase db reset on branch master.
```

## 3. Post-apply: one stale pre-existing assertion (deviation)
```
× Slice 2 API — container-size … citing 95 and 190
  → expected 'Passion fruit prefers at least 95 L (…' to contain '190'
```
DB shows the cited enrichment: `container_profile.idealMaxLiters = 150` (was 190 in the
Slice-2 seed). Assertion literal updated 190 → 150 (title + comment too). See REPORT §6.

## 4. GREEN
```
npm run test:int → 48 passed (48)
npm test         → 73 passed (73)
```

## 5. DB spot-proof
```
physalis-philadelphica  citations=5  v2  partners=2  requires_support=true
prunus-avium            citations=13 v1
total rows: 51
```
