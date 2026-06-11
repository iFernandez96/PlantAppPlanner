# Standalone verification — 0065

Type: red-first → green; checksummed attachment; objective DB catalog-complete proof.

## 0. Attachment integrity
```
sha256sum -c SHA256SUMS → PROMPT.md: OK / batch4_ornamentals_houseplants.sql: OK / MANIFEST.json: OK
repo copy == attachment: 259fcf1a7bace3071153a289267cbdefc6bb547a06f9a5b7d86334bde81ad613 (both)
```

## 1. RED (test edits only; DB at 0001–0009)
```
× batch 1 > catalog total …            (51 ≠ 75)
× batch 4 > all 24 present
× batch 4 > houseplant category live with 9 species
× batch 4 > full 75-plant catalog seeded and cited
 Test Files  1 failed | 10 passed (11)
      Tests  4 failed | 48 passed (52)
```
(Citations test vacuously green with zero batch-4 rows — noted in REPORT §3.)

## 2. Migration apply
```
Applying migration 0010_w2_catalog_batch4_ornamentals_houseplants.sql...
Finished supabase db reset on branch master.
```

## 3. GREEN
```
npm run test:int → 52 passed (52)
npm test         → 73 passed (73)
```

## 4. Catalog-complete proof
```
┌──────────────┬────┐
│ berry        │ 6  │
│ fruit        │ 9  │
│ herb         │ 14 │
│ houseplant   │ 9  │
│ ornamental   │ 15 │
│ root         │ 2  │
│ succulent    │ 4  │
│ vegetable    │ 14 │
│ vine         │ 2  │
└──────────────┴────┘
total: 75   cited: 75
```
Matches the §7 expected breakdown exactly.
