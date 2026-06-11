# Implementation prompt 0065 — W2 catalog seed batch 4/4: ornamentals + houseplants (24 profiles, completes the 75)

You are the implementation Claude for PlantApp. Apply exactly ONE logical change:
seed the final catalog batch — 24 cited ornamental/houseplant profiles — same
pattern as 0062–0064. This completes the 75-plant pilot catalog (PD-14).

Owner approval: PD-08 wave + PD-14. SQL generated from the cited research
profiles, schema-validated 75/75. The 9 houseplants exercise the Gate B
"houseplant" category added in 0060.

## 1. Scope — one logical change

1. NEW `supabase/migrations/0010_w2_catalog_batch4_ornamentals_houseplants.sql` —
   verbatim copy of the attachment `batch4_ornamentals_houseplants.sql` from
   `exchange/planner-outbox/0065-catalog-batch4/` (checksum-verify first).
2. EDIT `backend/tests/integration/w2-catalog.integration.test.ts` — add the
   batch-4 block (incl. the catalog-complete assertions) and bump
   `EXPECTED_PROFILE_COUNT` 51 → 75.

No Slice-1 overlaps in this batch: all 24 rows are new inserts.
After this batch: 51 + 24 = **75 rows — catalog complete**.

## 2. Forbidden changes — do NOT touch

- Migrations 0001–0009 (immutable). Do not edit the attachment — STOP/BLOCKED if
  it looks wrong.
- `core-tables.integration.test.ts`, backend src/, schemas, Android, engine,
  RLS/grants, seed-profiles.ts, dependencies.
- Do NOT `git add` untracked `android/.kotlin/`.

## 3. Exact files to touch

1. `supabase/migrations/0010_w2_catalog_batch4_ornamentals_houseplants.sql` (NEW, from attachment)
2. `backend/tests/integration/w2-catalog.integration.test.ts` (EDIT)

## 4. Baseline precondition — STOP if it doesn't hold

```bash
git -C /home/israel/Documents/Development/PlantApp rev-parse HEAD   # must be <SHA-AFTER-0064> — FILL BEFORE PUBLISHING
git -C /home/israel/Documents/Development/PlantApp status --short   # clean (untracked android/.kotlin/ OK)
git -C /home/israel/Documents/Development/PlantApp branch --show-current  # master
cd /home/israel/Documents/Development/PlantAppPlanner/exchange/planner-outbox/0065-catalog-batch4 && sha256sum -c SHA256SUMS
```
Local Supabase running. Differs → **STOP, BLOCKED report.**

## 5. Exact changes

### 5a. Migration (verbatim attachment copy)

```bash
cp /home/israel/Documents/Development/PlantAppPlanner/exchange/planner-outbox/0065-catalog-batch4/batch4_ornamentals_houseplants.sql \
   /home/israel/Documents/Development/PlantApp/supabase/migrations/0010_w2_catalog_batch4_ornamentals_houseplants.sql
```

### 5b. `w2-catalog.integration.test.ts` additions

Constant (old → new):
```ts
const EXPECTED_PROFILE_COUNT = 51;
```
→
```ts
const EXPECTED_PROFILE_COUNT = 75;
```

Add below `BATCH3_IDS`:
```ts
const BATCH4_IDS = [
  'aglaonema-commutatum', 'antirrhinum-majus', 'begonia-semperflorens',
  'chlorophytum-comosum', 'cosmos-bipinnatus', 'dahlia-pinnata',
  'dracaena-trifasciata', 'epipremnum-aureum', 'ficus-elastica',
  'helianthus-annuus', 'impatiens-walleriana', 'lobularia-maritima',
  'monstera-deliciosa', 'pelargonium-x-hortorum', 'petunia-x-hybrida',
  'philodendron-hederaceum', 'rosa-x-hybrida', 'rudbeckia-hirta',
  'salvia-splendens', 'spathiphyllum-wallisii', 'tagetes-patula',
  'viola-x-wittrockiana', 'zamioculcas-zamiifolia', 'zinnia-elegans',
];
```

Add a fourth describe block (after batch 3):
```ts
describe('W2 catalog batch 4 — ornamentals + houseplants (completes the 75)', () => {
  it('all 24 batch-4 profiles are present', async () => {
    const { rows } = await client.query(
      'select id from public.plant_profiles where id = any($1) order by id',
      [BATCH4_IDS],
    );
    expect(rows.map((r) => r.id)).toEqual(BATCH4_IDS);
  });

  it('every batch-4 profile carries citations and a version', async () => {
    const { rows } = await client.query(
      "select id from public.plant_profiles where id = any($1) and (source is null or jsonb_array_length(source) = 0 or version < 1)",
      [BATCH4_IDS],
    );
    expect(rows).toEqual([]);
  });

  it('the houseplant category (Gate B) is live with 9 species', async () => {
    const { rows } = await client.query(
      "select count(*)::int as n from public.plant_profiles where category = 'houseplant'",
    );
    expect(rows[0].n).toBe(9);
  });

  it('the full 75-plant pilot catalog is seeded and cited', async () => {
    const { rows } = await client.query(
      "select count(*)::int as total, count(*) filter (where source is not null and jsonb_array_length(source) > 0)::int as cited from public.plant_profiles",
    );
    expect(rows[0].total).toBe(75);
    expect(rows[0].cited).toBe(75);
  });
});
```

## 6. Expected failure modes (not regressions)

- §7 RED: the 4 new batch-4 tests fail AND the count test fails (51 ≠ 75).
  Expected red; all else green.
- Reset wipes local auth users (known). Kong 502 → `docker restart supabase_kong_PlantApp`.
- `npm test` (unit) stays green (73).

## 7. Standalone verification (red → green, objective)

**Step 1** — apply §5b (tests only).

**Step 2 — RED:**
```bash
cd /home/israel/Documents/Development/PlantApp
npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase db reset   # 0001–0009 only
cd backend && npm run test:int
```
**Expected:** 4 new batch-4 tests + the count test fail; all else green.
Batch-4 tests passing → STOP, BLOCKED.

**Step 3** — copy the migration (§5a), reset:
```bash
cd /home/israel/Documents/Development/PlantApp
npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase db reset   # 0001–0010
```
Log must show `Applying migration 0010_w2_catalog_batch4_ornamentals_houseplants.sql...`.

**Step 4 — GREEN:**
```bash
cd backend && npm run test:int   # expect 52 = 48 + 4 (report actual)
npm test                          # 73 (report actual)
```

**Catalog-complete proof (include in report):** the per-category breakdown —
```sql
select category, count(*)::int from plant_profiles group by category order by category;
```
(expect: berry 6 · fruit 9 · herb 14 · houseplant 9 · ornamental 15 · root 2 ·
succulent 4 · vegetable 14 · vine 2 — total 75; report actual.)

## 8. Commit title (Conventional Commits, exact)

```
feat(catalog): seed W2 batch 4/4 — 24 ornamentals and houseplants; 75-plant catalog complete
```

## 9. Push requirement

`git push origin master` — fast-forward expected. Confirm new `origin/master`.

## 10. Final report requirements

Report to `exchange/implementation-inbox/0065-catalog-batch4/` via the report
script. Include: scope confirmation (2 files) + `git show --stat HEAD`; checksum
verification; RED evidence; GREEN counts; reset log line for 0010; the
per-category breakdown; commit hash + push confirmation; deviations (or "none").
