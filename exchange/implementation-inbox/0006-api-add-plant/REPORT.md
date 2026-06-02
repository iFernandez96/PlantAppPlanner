# DONE — handoff 0006-api-add-plant (A3a, three commits red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** Fastify API + add-plant→CareTask flow built; integration tests #15–#18
(+ a 401 auth test) pass; integration suite 17/17, unit 50/50.
Final `origin/master` = `1cd2eac8354427c8afe24de9304cda594d4de53e`.

## Baseline precondition — matched
- HEAD = `670ebaf9c68d5325de0058dcdc7ccf1eefce35b6` == origin/master; clean.
- Local Supabase running; all migrations applied. Test env (API_URL / ANON_KEY /
  SERVICE_ROLE_KEY) loaded at runtime from `npx supabase status -o env` (cache-prefixed)
  and exported as SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY — **no
  keys committed**.

## Commit 1 — `chore(backend): add Fastify + supabase-js; ADRs for framework and API auth`
- Hash: `118660a`
- `npm install fastify @supabase/supabase-js` → `fastify ^5.8.5`, `@supabase/supabase-js
  ^2.106.2` (dependencies).
- `docs/adr/0005-backend-web-framework.md` (Fastify; `app.inject()` for tests),
  `docs/adr/0006-api-auth.md` (Supabase JWT forwarding + request-scoped client; RLS
  authoritative; service-role key used only by tests).
- `git show --stat`: 4 files (package.json, package-lock.json, 2 ADRs). Pushed
  `670ebaf..118660a`.

## Commit 2 (RED) — `test(api): add Slice 1 add-plant integration tests (#15–#18)`
- Hash: `3b263d1`
- One new file: `backend/tests/integration/plants-api.integration.test.ts`. Uses
  `app.inject()`; `beforeAll` provisions a test user via the service-role admin API
  (`auth.admin.createUser`, `email_confirm: true`) and signs in
  (`signInWithPassword`) to get the bearer; dynamic-imports `../../src/app.js`.
  Tests: #15 happy path (201 + one water task with engineVersion/inputsHash/
  sourceInputs.wateringBaselineAt/dueAt/priority, plus a follow-up `GET
  /plants/:id/tasks` returning exactly one water task), #16 missing containerId → 400,
  #17 missing gardenSpaceId → 400, #18 unknown profileId → 400, and an unauthenticated
  POST → 401.
- `npm run test:int` (RED): the new suite failed to load (`Failed to load url
  ../../src/app.js — Does the file exist?`), 5 tests skipped; prior 12 still passed.
  Exit non-zero — intended red.
- `git show --stat`: 1 file, +174. Pushed `118660a..3b263d1`.

## Commit 3 (GREEN) — `feat(api): add Fastify server + inventory endpoints and add-plant CareTask flow`
- Hash: `1cd2eac`
- New files under `backend/src/`:
  - `config.ts` — reads `SUPABASE_URL`/`SUPABASE_ANON_KEY` (or `API_URL`/`ANON_KEY`)
    from env at build time.
  - `auth.ts` — `makeAuthHook(config)`: rejects non-Bearer with 401, verifies via
    `supabase.auth.getUser(token)`, builds a request-scoped Supabase client with the
    token in `global.headers.Authorization`, attaches `{ userId, supabase }`. Wired as
    an **onRequest** hook (runs before body validation, so unauthenticated requests get
    401 before any 400).
  - `app.ts` — `buildApp()` Fastify instance with `POST /garden-spaces`,
    `POST /containers`, `POST /plants`, `GET /plants/:id/tasks`. `POST /plants`:
    Fastify schema validation (required profileId/containerId/gardenSpaceId/growthStage
    → 400 on missing); existence/visibility checks on profile/container/garden_space
    (→ 400 with field) which double as RLS-visibility checks; insert `plant_instances`;
    load profile (`watering_profile`/`container_profile` jsonb, `common_names`,
    `version`) + container `volume_liters`; call the **real**
    `computeInitialWaterTask` (imported from `../care-engine/index.js`); insert
    `care_tasks` mapping camelCase→snake_case with `source_inputs` = engine
    `sourceInputs` (jsonb) and `user_id` = caller; 201 `{ plant, task }`.
- `npm run typecheck` clean. `npm run test:int` → **17 passed (17)** (5 API + 12 prior).
  `npm test` → **50 passed (50)**.
- `git show --stat`: 3 files (`src/app.ts`, `src/auth.ts`, `src/config.ts`), +331.
  Pushed `3b263d1..1cd2eac`.

## Endpoints + auth wiring (for A3b)
- `POST /garden-spaces` {name, kind, …} → 201 row.
- `POST /containers` {volumeLiters, material, drainage, …} → 201 row.
- `POST /plants` {profileId, containerId, gardenSpaceId, growthStage, lastWateredAt?,
  nickname?, cultivar?, placement?} → 201 {plant, task}.
- `GET /plants/:id/tasks` → 200 array of `care_tasks` rows for that plant (RLS-scoped).
- Auth: `onRequest` hook on every route. Bearer required (401 otherwise). The
  request-scoped Supabase client carries the user JWT, so **Postgres RLS enforces
  isolation** — A3b's #19 (second user cannot read user A's plants/tasks) is enforced
  by the DB already; #20 (`DELETE /plants/:id`) will rely on the
  `plant_instances→care_tasks ON DELETE CASCADE` FK plus a delete endpoint (not yet
  added — A3b adds `DELETE /plants/:id`).

## Compliance
- `backend/care-engine/**`, `shared-schemas/**`, `supabase/migrations/**`, and existing
  `backend/tests/**` all UNCHANGED (`git diff --quiet HEAD` per path).
- Engine imported, not reimplemented. No test/schema weakened. No keys committed.
- Deps added: only `fastify`, `@supabase/supabase-js` (prompt-sanctioned). No
  `npm audit fix`.

## Pre-existing finding (not introduced here; for the planner)
`npm run lint` fails with 15 parse errors — ESLint's `parserOptions.project =
tsconfig.json`, but `tsconfig.json` `include` is only `care-engine`/`src`/`scripts`, so
every file under `tests/**` plus `eslint.config.js` and the two `vitest*.config.ts`
are "not found in the project" and fail to parse. This predates A3a (the schema test
files have never been in the tsconfig project) and is unrelated to the new code — **zero
`src/**` files appear in the lint errors**. `npm run lint` was not part of this
handoff's verification (test:int + test were). Fixing it touches `tsconfig.json` /
`eslint.config.js` (forbidden here) — flagging for a dedicated lint-config handoff.

## Commit hashes + titles
1. `118660a` — chore(backend): add Fastify + supabase-js; ADRs for framework and API auth
2. `3b263d1` — test(api): add Slice 1 add-plant integration tests (#15–#18)
3. `1cd2eac` — feat(api): add Fastify server + inventory endpoints and add-plant CareTask flow

Final `origin/master` SHA: `1cd2eac8354427c8afe24de9304cda594d4de53e`
