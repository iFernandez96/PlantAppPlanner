# Next Implementation Prompt — A2: remaining Slice 1 tables + RLS + seeded plant_profiles (red→green)

**Milestone A, step A2.** Add the remaining Slice 1 tables (`plant_profiles` [seeded,
read-only], `containers`, `plant_instances`, `care_tasks`) with RLS, mirroring
`shared-schemas/*`. Builds on A1's Supabase-local harness. The Fastify API + endpoint
tests #15–#20 are the **next** step (A3) — not this one.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `e92bc0f` ==
`origin/master`, clean. Local Supabase works (A1); `garden_spaces` + RLS exist; 50 unit
tests + 3 integration tests green. `npx supabase` requires the cache prefix below.

Two commits: (1) red integration test; (2) green migration(s).

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add
the remaining Slice 1 DB tables with RLS, proven by an integration test. **Consult the
official Supabase/Postgres docs** for current RLS + migration syntax.

### Environment
- This machine's `npx` cache can't symlink (Drive mount), so prefix every Supabase CLI
  call: `npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase <cmd>`.
- Ensure the stack is up: `… npx supabase status` (if down, `… npx supabase start`).
- Local DB URL: `postgresql://postgres:postgres@127.0.0.1:54322/postgres`.

### Baseline precondition (STOP if it doesn't match)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect e92bc0f7bebaf02a15acea13b7f7ecd90ff47c1a
git status --short                         # expect empty
```

### Forbidden
- Do NOT modify `backend/care-engine/**`, `shared-schemas/**`, existing unit tests,
  the unit/integration vitest configs, or `supabase/migrations/0001*`/`0002*`.
- Do NOT build the HTTP server/endpoints yet (that's A3).
- No new deps (you already have `pg`).

### Tables to add — mirror `shared-schemas/*` (snake_case columns)
Author the DDL grounded in the schemas; key requirements:
- **`plant_profiles`** (catalog): `id` **text** PK (slug, `^[a-z0-9-]+$`); columns for
  the plant-profile fields — scalars (`scientific_name`, `common_names text[]`,
  `category`, `growth_habit`, `version int`, optional `requires_support`,
  `self_fruitful`, `pollination_partners_required`, `vertical_suitability`) and **jsonb**
  for the nested sub-objects (`watering_profile`, `feeding_profile`, `container_profile`,
  `light_profile`, `temperature_profile`, `seasonality`, `source`). **RLS enabled**, a
  SELECT policy for authenticated users, and **no insert/update/delete policies**
  (read-only to clients). **Seed exactly the 5 Slice 1 profiles** whose ids match
  `backend/care-engine/seed-profiles.ts`: `passiflora-edulis`, `solanum-lycopersicum`,
  `physalis-philadelphica`, `fragaria-x-ananassa`, `ocimum-basilicum` (insert them in
  the migration; the nested objects can be jsonb literals).
- **`containers`**: mirror `container.schema.json` — `id` uuid PK, `user_id` uuid FK →
  `auth.users(id)` on delete cascade, `volume_liters` numeric `check (volume_liters > 0
  and volume_liters <= 10000)`, `material`/`drainage` text with enum checks,
  `self_watering`/`saucer` bool, `soil_mix` text, `created_at`/`updated_at`. RLS
  owner-scoped (4 policies, `auth.uid() = user_id`).
- **`plant_instances`**: mirror `plant-instance.schema.json` — `id` uuid PK, `user_id`
  uuid FK → `auth.users`, `profile_id` **text** FK → `plant_profiles(id)`, `container_id`
  uuid FK → `containers(id)`, `garden_space_id` uuid FK → `garden_spaces(id)`,
  `growth_stage` text enum check (required), `last_watered_at` timestamptz (nullable),
  `nickname`/`cultivar`/`placement` optional, `created_at`/`updated_at`. RLS owner-scoped.
- **`care_tasks`**: mirror `care-task.schema.json` — `id` uuid PK, `plant_instance_id`
  uuid FK → `plant_instances(id)` on delete cascade, `user_id` uuid FK → `auth.users`
  (denormalized so RLS is simple), `kind`/`priority`/`status` text enum checks, `due_at`
  timestamptz, `rationale` text, `engine_version` text, `inputs_hash` text,
  `source_inputs` jsonb, `completed_at` timestamptz, `created_at`. RLS owner-scoped
  (`auth.uid() = user_id`).

Put these in `supabase/migrations/0003_slice1_core_tables.sql` (keep the `NNNN_`
prefix so it sorts after `0002`; you may split into `0003`/`0004`/… if cleaner).

### COMMIT 1 (RED) — `test(db): add Slice 1 core-tables integration test`
Create `backend/tests/integration/core-tables.integration.test.ts`:
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

const TABLES = ['plant_profiles', 'containers', 'plant_instances', 'care_tasks'];
const SEED_PROFILE_IDS = [
  'fragaria-x-ananassa',
  'ocimum-basilicum',
  'passiflora-edulis',
  'physalis-philadelphica',
  'solanum-lycopersicum',
];

describe('Slice 1 DB — core tables', () => {
  it.each(TABLES)('table %s exists', async (t) => {
    const { rows } = await client.query(
      "select 1 from information_schema.tables where table_schema = 'public' and table_name = $1",
      [t],
    );
    expect(rows).toHaveLength(1);
  });

  it.each(TABLES)('table %s has row-level security enabled', async (t) => {
    const { rows } = await client.query(
      "select relrowsecurity from pg_class where oid = ('public.' || $1)::regclass",
      [t],
    );
    expect(rows[0]?.relrowsecurity).toBe(true);
  });

  it('plant_profiles is seeded with the 5 Slice 1 profiles', async () => {
    const { rows } = await client.query('select id from public.plant_profiles order by id');
    expect(rows.map((r) => r.id)).toEqual(SEED_PROFILE_IDS);
  });
});
```
Bring the DB to the current state and run integration tests to confirm RED:
```bash
cd /home/israel/Documents/Development/PlantApp
npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase status   # start if down
npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase db reset  # applies 0001+0002 only
cd backend && npm run test:int
```
Expected RED: the new core-tables cases fail (tables/seed don't exist yet); the 3
garden_spaces tests still pass. Commit the test + push. (If `supabase` itself fails for
an environment reason, STOP and report.)

### COMMIT 2 (GREEN) — `feat(db): add Slice 1 core tables with RLS + seed profiles`
Add the migration(s) per the spec above, then:
```bash
cd /home/israel/Documents/Development/PlantApp
npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase db reset   # applies 0001+0002+0003
cd backend && npm run test:int     # expect ALL integration tests green
npm test                            # expect unit suite still 50/50
```
Expected GREEN: all integration tests pass (garden_spaces + 4 core tables exist, RLS
enabled, plant_profiles seeded with the 5 ids); unit suite unaffected. If a migration
error or schema mismatch occurs, STOP and report verbatim — don't weaken the test.
Commit the migration + push.

### Final report
1. Two commit hashes + titles; final `origin/master` SHA.
2. `npm run test:int` RED (commit 1) then GREEN (commit 2) with counts; `npm test` 50/50.
3. `git show --stat` per commit; confirm `care-engine/**`, `shared-schemas/**`, prior
   migrations, and existing tests untouched.
4. Brief note of any column/jsonb choices you made so the planner can design A3 against
   them (esp. `care_tasks` columns + how `source_inputs` is stored).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after A2 lands
Verify all integration tests green + the 4 tables/RLS/seed. Then **A3**: add Fastify
(+ an ADR under `docs/adr/`), the `POST /plants` flow (validate body → persist
container/space/plant → call `computeInitialWaterTask` → persist the `CareTask`) plus
`GET /plants/:id/tasks` and `DELETE /plants/:id`, covered by integration tests #15–#20
(incl. RLS isolation between two users + cascade delete). Decompose A3 if large; stop to
ask the owner only on a real blocker.
