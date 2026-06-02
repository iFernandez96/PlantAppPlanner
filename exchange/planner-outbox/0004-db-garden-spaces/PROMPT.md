# Next Implementation Prompt — A1: Supabase local + garden_spaces migration + RLS (red→green)

**Milestone A (owner-approved), step A1.** Stand up Supabase local dev and prove the
DB migration + RLS + integration-test harness on the **smallest** table
(`garden_spaces`). This de-risks the first CLI install / Docker image pull before A2
(the full schema + Fastify API + integration tests #15–#20). D-03 = Supabase CLI.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `b32e7a4` ==
`origin/master`, clean. Docker is installed and running; the Supabase CLI is **not**
installed yet; `supabase/` has only `0001_init_extensions.sql` (no `config.toml`).
Backend has no `pg`/server deps. 50 unit tests green.

Three commits: (1) deps + `supabase init`; (2) red integration test; (3) green migration.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`).
Stand up Supabase local dev and add the first Slice 1 table with RLS, proven by an
integration test. **Consult the official Supabase local-development docs** for the
current CLI install method and commands (per the repo's framework-docs rule).

### Baseline precondition (STOP if it doesn't match)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect b32e7a46a5b8390f9d5ed1616e41dee7f701729c
git status --short                         # expect empty
docker info >/dev/null 2>&1 && echo docker-ok || echo DOCKER-DOWN   # expect docker-ok
```

### Environment notes / allowances (milestone A is approved)
- You MAY install the Supabase CLI (e.g. `npx supabase ...`, or the official Linux
  binary — your choice per docs), run `supabase start`/`db reset` (Docker), and add the
  `pg` dependency. These are in-scope for A.
- The first `supabase start` pulls several GB of images and is slow — that's expected;
  don't treat slowness as a failure. If Docker can't pull/run, STOP and report (blocker).
- Do NOT touch `backend/care-engine/**`, `shared-schemas/**`, existing tests, or the
  unit `vitest.config.ts`. Integration tests use `*.integration.test.ts` +
  `npm run test:int` (the repo already has `vitest.integration.config.ts`).

### COMMIT 1 — `chore(backend): add pg client and init Supabase local dev`
- `cd backend && npm install -D pg @types/pg` (adds the Postgres client for integration
  tests; commit the `package.json` + `package-lock.json` changes).
- From the repo root, initialize Supabase (`npx supabase init` or installed CLI) to
  create `supabase/config.toml`. Do not delete the existing `0001_init_extensions.sql`.
- Commit `backend/package.json`, `backend/package-lock.json`, `supabase/config.toml`
  (and any `supabase/.gitignore`/seed file `supabase init` generates). Do NOT commit
  `supabase/.branches`, `.temp`, or any Docker volume data (already git-ignored).
- Push.

### COMMIT 2 (RED) — `test(db): add Slice 1 garden_spaces integration test`
Create `backend/tests/integration/garden-spaces-schema.integration.test.ts`:
```ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { Client } from 'pg';

// Local Supabase Postgres (confirm host/port via `supabase status`; default below).
const DB_URL = process.env.SUPABASE_DB_URL ?? 'postgresql://postgres:postgres@127.0.0.1:54322/postgres';
let client: Client;

beforeAll(async () => {
  client = new Client({ connectionString: DB_URL });
  await client.connect();
});
afterAll(async () => {
  await client?.end();
});

describe('Slice 1 DB — garden_spaces', () => {
  it('garden_spaces table exists', async () => {
    const { rows } = await client.query(
      "select 1 from information_schema.tables where table_schema = 'public' and table_name = 'garden_spaces'",
    );
    expect(rows).toHaveLength(1);
  });

  it('garden_spaces has row-level security enabled', async () => {
    const { rows } = await client.query(
      "select relrowsecurity from pg_class where oid = 'public.garden_spaces'::regclass",
    );
    expect(rows[0]?.relrowsecurity).toBe(true);
  });

  it('garden_spaces has owner RLS policies (>= 4)', async () => {
    const { rows } = await client.query(
      "select policyname from pg_policies where schemaname = 'public' and tablename = 'garden_spaces'",
    );
    expect(rows.length).toBeGreaterThanOrEqual(4);
  });
});
```
Bring up the DB and run the integration suite to confirm RED:
```bash
cd /home/israel/Documents/Development/PlantApp
npx supabase start          # or installed CLI; first run pulls images (slow)
npx supabase db reset        # applies only 0001 (extensions) so far
cd backend && npm run test:int
```
Expected RED: all 3 tests fail (the `garden_spaces` table/policies don't exist yet —
`table exists` → 0 rows; the `regclass` lookup errors on the missing relation). Commit
the test file + push. (If `supabase start`/`db reset` itself fails for an environment
reason, STOP and report — that's a blocker, not a red.)

### COMMIT 3 (GREEN) — `feat(db): add garden_spaces table with RLS (migration 0002)`
Create `supabase/migrations/0002_slice1_garden_spaces.sql` (keep the existing
`NNNN_` naming so it sorts after `0001`). Mirror
`shared-schemas/garden-space.schema.json` (Slice 1 subset is fine); enable RLS with
owner-scoped policies. Reference implementation (adapt to match the schema + current
Supabase/Postgres RLS syntax from the docs):
```sql
-- 0002_slice1_garden_spaces.sql — Slice 1 GardenSpace table + RLS.
create table if not exists public.garden_spaces (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users (id) on delete cascade,
  name         text not null check (char_length(name) between 1 and 80),
  kind         text not null check (kind in (
                 'balcony','patio','window-ledge','indoor-room',
                 'vertical-rack-zone','hanging-zone','grow-light-shelf','other')),
  indoor       boolean not null default false,
  postal_code  text,
  country_code text check (country_code ~ '^[A-Z]{2}$'),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz
);

alter table public.garden_spaces enable row level security;

create policy "garden_spaces_select_own" on public.garden_spaces
  for select using (auth.uid() = user_id);
create policy "garden_spaces_insert_own" on public.garden_spaces
  for insert with check (auth.uid() = user_id);
create policy "garden_spaces_update_own" on public.garden_spaces
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "garden_spaces_delete_own" on public.garden_spaces
  for delete using (auth.uid() = user_id);
```
(`gen_random_uuid()` comes from `pgcrypto`, already enabled by `0001`.)

### Standalone verification (GREEN)
```bash
cd /home/israel/Documents/Development/PlantApp
npx supabase db reset        # now applies 0001 + 0002
cd backend && npm run test:int
```
Expected: **all 3 integration tests pass** (table exists, RLS enabled, ≥4 policies);
exits 0. The unit suite is unaffected (`npm test` still 50/50). If anything else
breaks, STOP and report — don't weaken the test or schema. Commit the migration + push.

### Final report
1. Three commit hashes + titles; final `origin/master` SHA.
2. `npm run test:int` output: RED at commit 2, GREEN at commit 3 (3/3).
3. `git show --stat` per commit; confirm `care-engine/**`, `shared-schemas/**`, and
   existing unit tests are untouched, and `npm test` is still 50/50.
4. The exact `supabase` CLI version + install method used, and the local DB URL from
   `supabase status` (so the planner can record the harness).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after A1 lands
Verify the 3 integration tests green + migration/RLS present. Then **A2**: choose the
web framework (planner: Fastify + an ADR under `docs/adr/`), add the remaining tables
(`plant_profiles` [seeded, read-only], `containers`, `plant_instances`, `care_tasks`)
with RLS, and the `POST /plants` flow that calls `computeInitialWaterTask`, covered by
integration tests #15–#20 (incl. RLS isolation + `DELETE /plants/:id`). Decompose A2
further if it gets large; stop to ask the owner only on a real blocker.
