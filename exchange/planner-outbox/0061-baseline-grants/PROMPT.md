# Implementation prompt 0061 — baseline grants migration (fix `db reset` harness break)

You are the implementation Claude for PlantApp. Apply exactly ONE logical change:
make the local database harness self-contained by adding the standard Supabase
role grants as a migration, so `supabase db reset` produces a working database
without manual repair.

Background (your own 0060 report, §5): the current unpinned `npx supabase` CLI no
longer applies the platform-default grants for `anon/authenticated/service_role`
on schema `public` during reset. You restored them manually; that fix lives only
in the current container and dies on the next reset. Every W2 seed-batch slice
will run `db reset`, so this must be a migration. (Pinning the CLI was considered;
a grants migration is more robust and mirrors the hosted platform's posture.)
Owner approval for migration work: PD-14's W2 ripple + this is harness repair for
the already-approved wave (PD-08).

## 1. Scope — one logical change

1. NEW `supabase/migrations/0006_w2_baseline_grants.sql` — the standard Supabase
   grants + default privileges (exactly the statements that fixed the env in 0060).
2. NEW `backend/tests/integration/grants.integration.test.ts` — regression tests
   that fail on any future grant-less reset.

Security note for the report: `grant all ... to anon` is TABLE-level only and is
the Supabase platform default; row access is still governed by RLS, which is
enabled on every table (anon has no policies → no rows). This migration restores
parity with hosted Supabase, it does not widen row access.

## 2. Forbidden changes — do NOT touch

- Migrations 0001–0005 (immutable history).
- No backend src/, schema-file, Android, or engine changes.
- No RLS policy changes — grants only.
- No CLI version pinning / package.json changes.
- Do NOT `git add` untracked `android/.kotlin/` if present.

## 3. Exact files to touch (both NEW)

1. `supabase/migrations/0006_w2_baseline_grants.sql`
2. `backend/tests/integration/grants.integration.test.ts`

## 4. Baseline precondition — STOP if it doesn't hold

```bash
git -C /home/israel/Documents/Development/PlantApp rev-parse HEAD   # must be 22067b6a619f8b955db2ee24df0212be40c231d2
git -C /home/israel/Documents/Development/PlantApp status --short   # clean (untracked android/.kotlin/ OK)
git -C /home/israel/Documents/Development/PlantApp branch --show-current  # master
```
Local Supabase running. If anything differs: **STOP, BLOCKED report.**

## 5. Exact changes

### 5a. `supabase/migrations/0006_w2_baseline_grants.sql`

```sql
-- Baseline grants (W2 harness fix): newer Supabase CLI resets no longer apply the
-- platform-default grants, leaving every API call at 42501 permission-denied.
-- These are the standard Supabase defaults; row access remains governed by RLS
-- (enabled on all tables; anon has no policies and therefore sees no rows).
grant usage on schema public to anon, authenticated, service_role;
grant all on all tables    in schema public to anon, authenticated, service_role;
grant all on all sequences in schema public to anon, authenticated, service_role;
grant all on all functions in schema public to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables    to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
```

### 5b. `backend/tests/integration/grants.integration.test.ts` (NEW)

Follow `core-tables.integration.test.ts` conventions (pg Client, same DB_URL):

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

describe('baseline grants survive db reset (0006)', () => {
  it('api roles have usage on schema public', async () => {
    const { rows } = await client.query(
      "select r as role, has_schema_privilege(r, 'public', 'usage') as ok from unnest(array['anon','authenticated','service_role']) as r",
    );
    expect(rows.filter((x) => !x.ok)).toEqual([]);
  });

  it('authenticated can select plant_profiles at the table-grant level', async () => {
    const { rows } = await client.query(
      "select 1 from information_schema.role_table_grants where table_schema = 'public' and table_name = 'plant_profiles' and grantee = 'authenticated' and privilege_type = 'SELECT'",
    );
    expect(rows.length).toBeGreaterThan(0);
  });
});
```

## 6. Expected failure modes (not regressions)

- §7 step 2 RED: after the bare `db reset` (0006 not yet created), BOTH new grants
  tests fail AND most pre-existing integration tests fail with Postgres `42501`
  permission-denied — that whole broken state IS the expected red; do not "fix" it
  manually this time.
- The reset wipes local auth users again (device account re-signs-in later — known).
- If Kong 502s after reset: `docker restart supabase_kong_PlantApp`, wait ~10s.
- `npm test` (unit) is DB-free and must stay green throughout (73 passing).

## 7. Standalone verification (red → green, objective)

From `/home/israel/Documents/Development/PlantApp` (test:int needs the Supabase
env exported, as in 0060).

**Step 1** — add ONLY `grants.integration.test.ts` (§5b). Do not create 0006 yet.

**Step 2 — RED:**
```bash
npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase db reset   # applies 0001–0005; grants vanish
cd backend && npm run test:int
```
**Expected:** the 2 new grants tests FAIL and pre-existing authed-API tests fail
with `42501 permission denied`. Capture a sample. If everything passes, STOP —
the harness premise changed; BLOCKED report.

**Step 3** — create §5a, then:
```bash
cd /home/israel/Documents/Development/PlantApp
npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase db reset   # applies 0001–0006
```
Confirm the output ends with `Applying migration 0006_w2_baseline_grants.sql...`.

**Step 4 — GREEN:**
```bash
cd backend && npm run test:int   # full suite green incl. the 2 new tests (expect 38; report actual)
npm test                          # unit suite unchanged (73; report actual)
```

This proves: a from-scratch reset now yields a fully working database with zero
manual repair — the property every future seed-batch slice depends on.

## 8. Commit title (Conventional Commits, exact)

```
fix(db): baseline role grants as migration — db reset yields a working database
```

One commit (test + migration; red evidence in the report).

## 9. Push requirement

`git push origin master` — fast-forward from `22067b6`. Confirm new `origin/master`.

## 10. Final report requirements

Report to `exchange/implementation-inbox/0061-baseline-grants/` via
`scripts/exchange-create-implementation-report.sh`. Include:
1. Scope confirmation (only the 2 new files) + `git show --stat HEAD`.
2. RED evidence (grants tests + a 42501 sample from the broken state).
3. GREEN outputs (test:int and unit counts) + the reset log line showing 0006 applied.
4. New commit hash + push confirmation.
5. Deviations (or "none").
