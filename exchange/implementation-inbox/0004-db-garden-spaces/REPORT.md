# DONE — handoff 0004-db-garden-spaces (A1, three commits red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** Supabase local dev stood up; `garden_spaces` table + RLS added; the 3
integration tests pass; unit suite still 50/50.
Final `origin/master` = `e92bc0f7bebaf02a15acea13b7f7ecd90ff47c1a`.

## Baseline precondition — matched
- HEAD = `b32e7a46a5b8390f9d5ed1616e41dee7f701729c` == origin/master
- `git status --short` = empty
- `docker info` = docker-ok

## Environment deviation (mechanical, documented)
`npx supabase init` initially failed with `EPERM: symlink … ../supabase/dist/supabase.js
→ /media/israel/Drive/cache-mirror/npm/_npx/.../node_modules/.bin/supabase`. Root
cause: the npm/npx cache lives on an external Drive mount whose filesystem cannot
create symlinks, and npx symlinks the package bin into that `_npx` cache. The repo's
local `backend/node_modules` (on the SSD) symlinks fine — that's why `npm install`
works. Per the prompt's sanction to use `npx supabase` (and "your choice per docs"),
I redirected only the npx cache to a symlink-capable local dir for each supabase
invocation:
```
npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase <cmd>
```
This adds no dependency and changes no committed file; it is a per-command cache path
override forced by the Drive filesystem. No other deviation.

## Supabase CLI + local DB (for the planner's harness record)
- Supabase CLI version: **2.104.0** (run via `npx --yes supabase`, Node v22.22.0; docs
  require Node ≥20).
- Install method: `npx supabase` (no global/dev-dep install; bins resolved through the
  redirected local npx cache).
- Local DB URL (from `supabase status`): `postgresql://postgres:postgres@127.0.0.1:54322/postgres`
  — this is the integration suite's default (`SUPABASE_DB_URL` env can override).
- Local API URL: `http://127.0.0.1:54321`. The local-dev auth/storage keys printed by
  `supabase start` are well-known local defaults stored only in git-ignored
  `supabase/.temp/`; they were NOT committed and are not reproduced here.

## Commit 1 — `chore(backend): add pg client and init Supabase local dev`
- Hash: `661a135`
- `cd backend && npm install -D pg @types/pg` → `pg ^8.21.0` + `@types/pg ^8.20.0`
  added to devDependencies (Postgres client for integration tests).
- `npx supabase init` → created `supabase/config.toml` and `supabase/.gitignore`
  (which ignores `.branches` / `.temp`). Existing `supabase/migrations/0001_init_extensions.sql`
  and `supabase/README.md` left intact. `.temp/` is git-ignored (not committed).
- Committed: `backend/package.json`, `backend/package-lock.json`, `supabase/.gitignore`,
  `supabase/config.toml`. `git show --stat`: 4 files changed, +597. No seed.sql was
  generated.
- Pushed `b32e7a4..661a135`.

## Commit 2 (RED) — `test(db): add Slice 1 garden_spaces integration test`
- Hash: `8d1905a`
- One new file: `backend/tests/integration/garden-spaces-schema.integration.test.ts`
  (verbatim from prompt; connects via `pg` to the local DB URL, checks table existence,
  `relrowsecurity`, and ≥4 RLS policies).
- Brought the DB up: `supabase start` (pulled images), `supabase db reset` (applied only
  `0001`). Then `npm run test:int`:
  **3 failed (3)** — `garden_spaces table exists` → 0 rows; the `relrowsecurity` check
  errored `relation "public.garden_spaces" does not exist`; policy count `0 >= 4` failed.
  The `pg` connection itself succeeded (the failures are missing-relation, the intended
  red). Exit non-zero.
- `git show --stat`: 1 file changed, +37.
- Pushed `661a135..8d1905a`.

## Commit 3 (GREEN) — `feat(db): add garden_spaces table with RLS (migration 0002)`
- Hash: `e92bc0f`
- One new file: `supabase/migrations/0002_slice1_garden_spaces.sql`. Mirrors
  `shared-schemas/garden-space.schema.json` (Slice 1 subset): `id` (uuid,
  `gen_random_uuid()`), `user_id` (FK → `auth.users`, on delete cascade), `name`
  (check length 1..80), `kind` (check enum matching the schema, incl. `other`), `indoor`,
  `postal_code`, `country_code` (check `^[A-Z]{2}$`), `created_at`, `updated_at`.
  `enable row level security` + 4 owner-scoped policies (select/insert/update/delete,
  `auth.uid() = user_id`).
- `supabase db reset` applied `0001` + `0002` cleanly (no errors). Then:
  - `npm run test:int` → **3 passed (3)** (table exists, RLS enabled, ≥4 policies); exit 0.
  - `npm test` (unit) → **50 passed (50)**, unaffected.
- `git show --stat`: 1 file changed, +28.
- Pushed `8d1905a..e92bc0f`.

## Compliance
- `backend/care-engine/**` UNCHANGED (`git diff --quiet HEAD` confirmed).
- `shared-schemas/**` UNCHANGED.
- No existing unit test or `vitest.config.ts`/`vitest.integration.config.ts` modified.
- Integration tests use `*.integration.test.ts` + `npm run test:int` (separate config),
  so the unit suite is untouched and still 50/50.
- Only the prompt-sanctioned deps added (`pg`, `@types/pg`). No `npm audit fix` run.
- Did not commit `.branches`, `.temp`, Docker volumes, or any local-dev keys.

## Commit hashes + titles
1. `661a135` — chore(backend): add pg client and init Supabase local dev
2. `8d1905a` — test(db): add Slice 1 garden_spaces integration test
3. `e92bc0f` — feat(db): add garden_spaces table with RLS (migration 0002)

Final `origin/master` SHA: `e92bc0f7bebaf02a15acea13b7f7ecd90ff47c1a`

## State note for the planner (A2 readiness)
- Local Supabase stack is running (left up). DB URL above. `npx supabase` works only
  with the `npm_config_cache=/tmp/plantapp-npx-cache` prefix on this machine (Drive
  symlink limitation) — worth recording in the harness notes for A2.
- A2 next: web framework choice (planner leaning Fastify + ADR), remaining tables
  (`plant_profiles` seeded read-only, `containers`, `plant_instances`, `care_tasks`) with
  RLS, and the `POST /plants` flow calling `computeInitialWaterTask`, covered by
  integration tests #15–#20 (incl. RLS isolation + `DELETE /plants/:id`).
