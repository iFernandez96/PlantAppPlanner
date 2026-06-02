# DONE — handoff 0005-db-core-tables (A2, two commits red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** 4 remaining Slice 1 tables + RLS added; `plant_profiles` seeded with the 5
profiles; integration suite 12/12 green; unit suite still 50/50.
Final `origin/master` = `670ebaf9c68d5325de0058dcdc7ccf1eefce35b6`.

## Baseline precondition — matched
- HEAD = `e92bc0f7bebaf02a15acea13b7f7ecd90ff47c1a` == origin/master
- `git status --short` = empty
- Supabase local stack running (`supabase status` = running); DB URL
  `postgresql://postgres:postgres@127.0.0.1:54322/postgres`. All `npx supabase`
  calls used the `npm_config_cache=/tmp/plantapp-npx-cache` prefix (Drive symlink
  limitation from A1).

## Commit 1 (RED) — `test(db): add Slice 1 core-tables integration test`
- Hash: `e2c3795`
- One new file: `backend/tests/integration/core-tables.integration.test.ts` (verbatim
  from prompt): for each of `plant_profiles`, `containers`, `plant_instances`,
  `care_tasks` checks table existence + `relrowsecurity`, plus that `plant_profiles`
  holds exactly the 5 seed ids (ordered).
- `supabase db reset` applied `0001`+`0002` only, then `npm run test:int`:
  **9 failed | 3 passed (12)** — the 9 new core-tables cases fail (tables/seed absent;
  the seed check errors `relation "public.plant_profiles" does not exist`), the 3
  garden_spaces tests still pass. Exit non-zero — intended red.
- `git show --stat`: 1 file changed, +45. Pushed `e92bc0f..e2c3795`.

## Commit 2 (GREEN) — `feat(db): add Slice 1 core tables with RLS + seed profiles`
- Hash: `670ebaf`
- One new file: `supabase/migrations/0003_slice1_core_tables.sql` (+205). Adds all four
  tables with RLS and seeds the 5 profiles.
- `supabase db reset` applied `0001`+`0002`+`0003` cleanly (no SQL errors). Then:
  - `npm run test:int` → **12 passed (12)** (garden_spaces 3 + core-tables 9).
  - `npm test` (unit) → **50 passed (50)**, unaffected.
- `git show --stat`: 1 file changed, +205. Pushed `e2c3795..670ebaf`.

## Schema/DDL choices (for A3 design)
Columns are snake_case; nested schema sub-objects are stored as `jsonb`.

- **plant_profiles** (catalog, read-only): `id text` PK (`check id ~ '^[a-z0-9-]+$'`),
  `scientific_name text`, `common_names text[]`, `category`/`growth_habit` text+enum
  checks, `requires_support bool`, `self_fruitful bool` (nullable),
  `pollination_partners_required int default 0`, jsonb columns `watering_profile`,
  `feeding_profile`, `container_profile`, `light_profile`, `temperature_profile`,
  `seasonality` (nullable), `source` (nullable), `common_issues text[]`,
  `vertical_suitability numeric` (0..1), `version int`, `last_reviewed_at date`.
  RLS enabled; **one** policy: `select to authenticated using (true)` — no
  insert/update/delete policies (clients can read, only migrations/service-role write).
- **containers**: `id uuid` PK `default gen_random_uuid()`, `user_id uuid` FK →
  `auth.users` (cascade), `name text` (≤80), `volume_liters numeric`
  `check (>0 and <=10000)`, `material`/`drainage` text+enum checks, `self_watering bool`,
  `saucer bool`, `soil_mix text` (≤200), `created_at`, `updated_at`. 4 owner RLS policies.
- **plant_instances**: `id uuid` PK, `user_id uuid` FK → auth.users, `profile_id text`
  FK → `plant_profiles(id)`, `container_id uuid` FK → `containers(id)`,
  `garden_space_id uuid` FK → `garden_spaces(id)`, `nickname`/`cultivar` (≤80),
  `placement` text+enum, `placement_height_cm int`, `acquired_at`/`planted_at date`,
  `last_watered_at timestamptz` (nullable), `growth_stage text` (NOT NULL, enum check),
  `support_recorded bool`, `notes text` (≤4000), `photos text[]`, `created_at`,
  `updated_at`. 4 owner RLS policies.
- **care_tasks**: `id uuid` PK, `plant_instance_id uuid` FK → `plant_instances(id)`
  (cascade), **`user_id uuid` FK → auth.users (denormalized so RLS is a simple
  `auth.uid() = user_id`)**, `kind`/`priority`/`status` text+enum checks,
  `due_at timestamptz`, `rationale text` (≤2000), `rationale_metadata jsonb` (nullable),
  `engine_version text` (`check ~ '^\d+\.\d+\.\d+$'`), `inputs_hash text` (len ≥8),
  **`source_inputs jsonb` NOT NULL** (the whole sourceInputs object stored as one jsonb
  column — A3's `POST /plants` should `JSON.stringify` the engine's `sourceInputs` into
  this column), `completed_at timestamptz`, `feedback text` (enum, nullable),
  `created_at`. 4 owner RLS policies.

A3 note: the engine returns camelCase fields (`plantInstanceId`, `dueAt`,
`engineVersion`, `inputsHash`, `sourceInputs`, …); the `POST /plants` handler maps those
to the snake_case columns and stores `source_inputs` = the `sourceInputs` object as jsonb.

## Compliance
- `backend/care-engine/**`, `shared-schemas/**`, and `0001`/`0002` migrations UNCHANGED
  (`git diff --quiet HEAD` confirmed for each).
- No HTTP server/endpoints added (that's A3).
- No new deps. No existing unit test or vitest config modified.

## Commit hashes + titles
1. `e2c3795` — test(db): add Slice 1 core-tables integration test
2. `670ebaf` — feat(db): add Slice 1 core tables with RLS + seed profiles

Final `origin/master` SHA: `670ebaf9c68d5325de0058dcdc7ccf1eefce35b6`
