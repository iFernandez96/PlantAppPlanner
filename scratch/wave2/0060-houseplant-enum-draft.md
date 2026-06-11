# Implementation prompt 0060 — "houseplant" category end-to-end (Gate B / PD-14)

You are the implementation Claude for PlantApp. Apply exactly ONE logical change:
extend the plant-profile `category` vocabulary with `"houseplant"` in BOTH places
it is enforced — the shared JSON schema and the DB check constraint — with
red-first proof at both layers.

Owner approval: Gate B resolved 2026-06-11 (planner decision log PD-14) — this
migration is the approved ripple. The wave-2 catalog (75 profiles incl. 9
houseplants) seeds in later slices; this slice ONLY widens the vocabulary.

## 1. Scope — one logical change

1. `shared-schemas/plant-profile.schema.json` — add `"houseplant"` to the
   `category` enum (after `"succulent"`, before `"other"`).
2. NEW `supabase/migrations/0005_w2_houseplant_category.sql` — widen the
   `plant_profiles.category` check constraint identically.
3. Red-first tests at both layers (schema test fixture + DB constraint test).

## 2. Forbidden changes — do NOT touch

- No other schema file; no other property of plant-profile.schema.json.
- No seed data changes (migrations 0001–0004 are immutable history; the 5 seeded
  profiles keep their categories).
- No backend src/ changes (mappers/endpoints pass `category` through as text).
- No Android changes (the DTO field is `String` — no enum on the client).
- No engine changes. No new dependencies.
- Do NOT `git add` untracked `android/.kotlin/` if present.

## 3. Exact files to touch

1. `shared-schemas/plant-profile.schema.json` (edit: one enum entry)
2. `supabase/migrations/0005_w2_houseplant_category.sql` (NEW)
3. `backend/tests/schema/plant-profile.test.ts` (add one fixture)
4. `backend/tests/integration/houseplant-category.integration.test.ts` (NEW)

## 4. Baseline precondition — STOP if it doesn't hold

```bash
git -C /home/israel/Documents/Development/PlantApp rev-parse HEAD   # must be <SHA-AFTER-0059> — FILL BEFORE PUBLISHING
git -C /home/israel/Documents/Development/PlantApp status --short   # clean (untracked android/.kotlin/ OK)
git -C /home/israel/Documents/Development/PlantApp branch --show-current  # master
```
Local Supabase must be running (`npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase status` succeeds). If anything differs: **STOP, BLOCKED report.**

## 5. Exact changes

### 5a. Schema enum

In `shared-schemas/plant-profile.schema.json`, `properties.category.enum`:
old `["fruit","vegetable","herb","ornamental","vine","root","berry","succulent","other"]`
new `["fruit","vegetable","herb","ornamental","vine","root","berry","succulent","houseplant","other"]`
(JSON formatting: match the file's existing one-value-per-line style.)

### 5b. Migration `supabase/migrations/0005_w2_houseplant_category.sql`

```sql
-- W2 Gate B (PD-14): the catalog adds houseplants (pothos, monstera, snake plant, ...).
-- Widen the category vocabulary; keep every existing value.
alter table public.plant_profiles
  drop constraint plant_profiles_category_check;
alter table public.plant_profiles
  add constraint plant_profiles_category_check
  check (category in (
    'fruit','vegetable','herb','ornamental','vine',
    'root','berry','succulent','houseplant','other'));
```

(If the drop fails because the auto-generated constraint name differs, query
`select conname from pg_constraint where conrelid = 'public.plant_profiles'::regclass and contype = 'c';`
and use the real name — report the deviation.)

### 5c. Schema test fixture — `backend/tests/schema/plant-profile.test.ts`

Append to `seedFixtures` (mirrors the basil fixture's shape; the schema has
`additionalProperties: false`, so add no extra keys):

```ts
  {
    species: 'pothos (houseplant category, W2 Gate B)',
    profile: {
      id: 'epipremnum-aureum',
      scientificName: 'Epipremnum aureum',
      commonNames: ['Pothos', "Devil's ivy"],
      category: 'houseplant',
      growthHabit: 'trailing',
      requiresSupport: false,
      selfFruitful: false,
      wateringProfile: { baseIntervalDays: 9, dryingTolerance: 'high' },
      feedingProfile: { baseIntervalDays: 30 },
      containerProfile: { recommendedMinLiters: 4 },
      lightProfile: { targetSunHours: 4 },
      temperatureProfile: { frostSensitive: true },
      version: 1,
    },
  },
```

### 5d. Integration test — `backend/tests/integration/houseplant-category.integration.test.ts` (NEW)

Follow `core-tables.integration.test.ts` conventions (pg Client, same DB_URL
default). The test proves the DB constraint inside a rolled-back transaction —
no persistent data change:

```ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { Client } from 'pg';

const DB_URL = process.env.SUPABASE_DB_URL ?? 'postgresql://postgres:postgres@127.0.0.1:54322/postgres';
let client: Client;

beforeAll(async () => {
  client = new Client({ connectionString: DB_URL });
  await client.connect();
});
afterAll(async () => {
  await client?.end();
});

describe('W2 Gate B — plant_profiles.category accepts houseplant', () => {
  it('check constraint allows houseplant (transaction rolled back)', async () => {
    await client.query('begin');
    try {
      await client.query(
        "update plant_profiles set category = 'houseplant' where id = 'ocimum-basilicum'",
      );
      const { rows } = await client.query(
        "select category from plant_profiles where id = 'ocimum-basilicum'",
      );
      expect(rows[0].category).toBe('houseplant');
    } finally {
      await client.query('rollback');
    }
  });
});
```

## 6. Expected failure modes (not regressions)

- §7 step 1 RED: the schema test fails with an Ajv enum error on the pothos
  fixture; the integration test fails with Postgres check-constraint violation
  `plant_profiles_category_check`. Both are the expected red.
- `npx supabase db reset` wipes local auth users + device test data
  (reviewer@example.com) — EXPECTED and accepted; the next device session
  re-signs-in via Mailpit. If Kong 502s after reset:
  `docker restart supabase_kong_PlantApp`, wait ~10s, retry.
- Gradle/Android not involved — do not run Android tasks.

## 7. Standalone verification (red → green, objective)

From `/home/israel/Documents/Development/PlantApp`:

**Step 1 — RED.** Add §5c + §5d (tests only, no schema/migration change yet):
```bash
cd backend && npm test          # pothos fixture FAILS the enum (Ajv 'must be equal to one of the allowed values')
npm run test:int                # houseplant-category test FAILS (check constraint violation)
```
Capture both failures. If either passes, STOP — baseline mismatch.

**Step 2 — implement** §5a + §5b, then apply migrations:
```bash
cd /home/israel/Documents/Development/PlantApp
npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase db reset   # applies 0001–0005
```

**Step 3 — GREEN:**
```bash
cd backend && npm test          # full unit suite green incl. the pothos fixture (report counts)
npm run test:int                # full integration suite green incl. the new test (report counts)
npm run validate-schemas        # schema files still valid
```

Report all three outputs with counts (do not assume totals).

## 8. Commit title (Conventional Commits, exact)

```
feat(schema): add houseplant category to plant-profile vocabulary (schema + DB)
```

One commit (red tests + schema + migration; red evidence in the report).

## 9. Push requirement

`git push origin master` — fast-forward expected. Confirm new `origin/master`.

## 10. Final report requirements

Report to `exchange/implementation-inbox/0060-houseplant-category/` via
`scripts/exchange-create-implementation-report.sh`. Include:
1. Scope confirmation (only the 4 listed files) + `git show --stat HEAD`.
2. RED evidence (both layers).
3. GREEN outputs (unit, integration, validate-schemas) with counts.
4. New commit hash + push confirmation.
5. Deviations (or "none") — incl. the constraint name if it differed.
