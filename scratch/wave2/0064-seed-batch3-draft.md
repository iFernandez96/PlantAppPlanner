# Implementation prompt 0064 — W2 catalog seed batch 3/4: fruit + vines + succulents (15 profiles)

You are the implementation Claude for PlantApp. Apply exactly ONE logical change:
seed catalog batch 3 — 15 cited fruit/vine/succulent profiles — same pattern as
0062/0063.

Owner approval: PD-08 wave + PD-14. SQL generated from the cited research
profiles, schema-validated 75/75.

## 1. Scope — one logical change

1. NEW `supabase/migrations/0009_w2_catalog_batch3_fruit_vines_succulents.sql` —
   verbatim copy of the attachment `batch3_fruit_vines_succulents.sql` from
   `exchange/planner-outbox/0064-catalog-batch3/` (checksum-verify first).
2. EDIT `backend/tests/integration/w2-catalog.integration.test.ts` — add the
   batch-3 block and bump `EXPECTED_PROFILE_COUNT` 38 → 51.

UPSERT note: `passiflora-edulis` (passion fruit) and `physalis-philadelphica`
(tomatillo) already exist from Slice 1 — both enrich in place to version 2,
categories unchanged ('fruit'). Tomatillo's `requires_support` flips
false → true (cited: UMN/Almanac/UC say cage-or-trellis) and it keeps
`pollination_partners_required = 2`. Expected, not an error.
After this batch: 38 + 13 new = **51 rows**.

## 2. Forbidden changes — do NOT touch

- Migrations 0001–0008 (immutable). Do not edit the attachment — STOP/BLOCKED if
  it looks wrong.
- `core-tables.integration.test.ts`, backend src/, schemas, Android, engine,
  RLS/grants, seed-profiles.ts, dependencies.
- Do NOT `git add` untracked `android/.kotlin/`.

## 3. Exact files to touch

1. `supabase/migrations/0009_w2_catalog_batch3_fruit_vines_succulents.sql` (NEW, from attachment)
2. `backend/tests/integration/w2-catalog.integration.test.ts` (EDIT)

## 4. Baseline precondition — STOP if it doesn't hold

```bash
git -C /home/israel/Documents/Development/PlantApp rev-parse HEAD   # must be <SHA-AFTER-0063> — FILL BEFORE PUBLISHING
git -C /home/israel/Documents/Development/PlantApp status --short   # clean (untracked android/.kotlin/ OK)
git -C /home/israel/Documents/Development/PlantApp branch --show-current  # master
cd /home/israel/Documents/Development/PlantAppPlanner/exchange/planner-outbox/0064-catalog-batch3 && sha256sum -c SHA256SUMS
```
Local Supabase running. Differs → **STOP, BLOCKED report.**

## 5. Exact changes

### 5a. Migration (verbatim attachment copy)

```bash
cp /home/israel/Documents/Development/PlantAppPlanner/exchange/planner-outbox/0064-catalog-batch3/batch3_fruit_vines_succulents.sql \
   /home/israel/Documents/Development/PlantApp/supabase/migrations/0009_w2_catalog_batch3_fruit_vines_succulents.sql
```

### 5b. `w2-catalog.integration.test.ts` additions

Constant (old → new):
```ts
const EXPECTED_PROFILE_COUNT = 38;
```
→
```ts
const EXPECTED_PROFILE_COUNT = 51;
```

Add below `BATCH2_IDS`:
```ts
const BATCH3_IDS = [
  'actinidia-deliciosa', 'aloe-vera', 'citrus-limon', 'crassula-ovata',
  'echeveria-elegans', 'ficus-carica', 'haworthia-attenuata', 'malus-domestica',
  'passiflora-edulis', 'physalis-philadelphica', 'prunus-avium',
  'prunus-domestica', 'prunus-persica', 'pyrus-communis', 'vitis-vinifera',
];
```

Add a third describe block (after batch 2):
```ts
describe('W2 catalog batch 3 — fruit, vines, succulents', () => {
  it('all 15 batch-3 profiles are present', async () => {
    const { rows } = await client.query(
      'select id from public.plant_profiles where id = any($1) order by id',
      [BATCH3_IDS],
    );
    expect(rows.map((r) => r.id)).toEqual(BATCH3_IDS);
  });

  it('every batch-3 profile carries citations and a version', async () => {
    const { rows } = await client.query(
      "select id from public.plant_profiles where id = any($1) and (source is null or jsonb_array_length(source) = 0 or version < 1)",
      [BATCH3_IDS],
    );
    expect(rows).toEqual([]);
  });

  it('passion fruit and tomatillo were enriched in place, not duplicated', async () => {
    const { rows } = await client.query(
      "select id, category, version, pollination_partners_required from public.plant_profiles where id in ('passiflora-edulis','physalis-philadelphica') order by id",
    );
    expect(rows).toHaveLength(2);
    expect(rows[0]).toMatchObject({ id: 'passiflora-edulis', category: 'fruit' });
    expect(rows[1]).toMatchObject({ id: 'physalis-philadelphica', category: 'fruit', pollination_partners_required: 2 });
    expect(rows.every((r) => r.version >= 2)).toBe(true);
  });
});
```

## 6. Expected failure modes (not regressions)

- §7 RED: the 3 new batch-3 tests fail AND the count test fails (38 ≠ 51).
  Expected red; all else green.
- Reset wipes local auth users (known). Kong 502 → `docker restart supabase_kong_PlantApp`.
- `npm test` (unit) stays green (73).

## 7. Standalone verification (red → green, objective)

**Step 1** — apply §5b (tests only).

**Step 2 — RED:**
```bash
cd /home/israel/Documents/Development/PlantApp
npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase db reset   # 0001–0008 only
cd backend && npm run test:int
```
**Expected:** 3 new batch-3 tests + the count test fail; all else green. Batch-3
tests passing → STOP, BLOCKED.

**Step 3** — copy the migration (§5a), reset:
```bash
cd /home/israel/Documents/Development/PlantApp
npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase db reset   # 0001–0009
```
Log must show `Applying migration 0009_w2_catalog_batch3_fruit_vines_succulents.sql...`.

**Step 4 — GREEN:**
```bash
cd backend && npm run test:int   # expect 48 = 45 + 3 (report actual)
npm test                          # 73 (report actual)
```

**Citation spot-proof:** query `prunus-avium` and `physalis-philadelphica` for
`jsonb_array_length(source)`, `version`, and tomatillo's
`pollination_partners_required` (expect 2).

## 8. Commit title (Conventional Commits, exact)

```
feat(catalog): seed W2 batch 3/4 — 15 cited fruit, vine and succulent profiles
```

## 9. Push requirement

`git push origin master` — fast-forward expected. Confirm new `origin/master`.

## 10. Final report requirements

Report to `exchange/implementation-inbox/0064-catalog-batch3/` via the report
script. Include: scope confirmation (2 files) + `git show --stat HEAD`; checksum
verification; RED evidence; GREEN counts; reset log line for 0009; citation
spot-proof; commit hash + push confirmation; deviations (or "none").
