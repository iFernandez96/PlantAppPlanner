# Next Implementation Prompt — A3a: Fastify API, add-plant → CareTask, validation (#15–#18)

**Milestone A, step A3a.** Stand up the backend HTTP API (Fastify) and the Slice 1
add-plant flow that calls the care-engine and persists the `CareTask`, with input
validation. Integration tests cover plan **#15–#18**. (RLS isolation #19 + DELETE
cascade #20 are the next step, A3b.)

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `670ebaf` == `origin/master`,
clean. All 5 tables + RLS exist; `plant_profiles` seeded; 50 unit + 12 integration tests
green. Care-engine `computeInitialWaterTask` is implemented and exported. DDL is
snake_case; `care_tasks.source_inputs` is `jsonb not null`; `care_tasks.user_id` is
denormalized; `plant_instances→care_tasks` is `on delete cascade`.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Build
the Slice 1 backend API with Fastify and the add-plant → CareTask flow, proven by
integration tests #15–#18. **Consult the official Fastify and Supabase (supabase-js,
Auth, local dev) docs** for current APIs.

### Environment (same harness as A1/A2)
- Local Supabase must be up; prefix CLI calls: `npm_config_cache=/tmp/plantapp-npx-cache
  npx --yes supabase <cmd>` (`supabase status` to confirm; `start` if down).
- Read local URL + keys from `supabase status` (API URL `http://127.0.0.1:54321`,
  DB URL `…54322`, plus `anon` and `service_role` keys). Do NOT commit keys; pass them
  to the test run via env (e.g. an un-committed shell export or values read at runtime).

### Baseline precondition (STOP if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect 670ebaf9c68d5325de0058dcdc7ccf1eefce35b6
git status --short                         # expect empty
```

### Architecture decisions to record (write an ADR; append-only under docs/adr/)
- **Web framework = Fastify** (D-01 is Node+TS; framework was unpinned). Rationale:
  first-class TS, built-in `app.inject()` for fast integration tests, schema-based
  validation. Add `docs/adr/0005-backend-web-framework.md`.
- **API auth = Supabase JWT forwarding.** The client sends `Authorization: Bearer
  <Supabase access token>`. The server creates a **request-scoped** `@supabase/supabase-js`
  client initialized with that token (so every DB call runs as that user and Postgres
  **RLS enforces ownership**); `user_id` columns are set from the authenticated user.
  This honors D-05 (Supabase Auth). Record in the ADR (or `docs/adr/0006-api-auth.md`).

### Dependencies (allowed — milestone A)
Add to `backend`: `fastify` and `@supabase/supabase-js` (+ any small helpers you need,
e.g. a Fastify plugin). Commit `package.json` + `package-lock.json`.

### Endpoints (backend `src/`; create `backend/src/…`)
All require a valid bearer token (401 if missing/invalid). All DB access goes through the
request-scoped Supabase client so RLS applies; set `user_id` = the authenticated user.
- `POST /garden-spaces` → insert a `garden_spaces` row; 201 + `{ id, ... }`.
- `POST /containers` → insert a `containers` row; 201 + `{ id, ... }`.
- `POST /plants` → body `{ profileId, containerId, gardenSpaceId, growthStage,
  lastWateredAt?, nickname?, cultivar?, placement? }`. Behavior:
  1. **Validate** required fields; return **400** with a field-level error if
     `containerId`, `gardenSpaceId`, or `profileId` is missing/unknown or the
     container/garden space isn't visible to the caller (see #16–#18).
  2. Insert the `plant_instances` row (server-generated `id`, `created_at = now`).
  3. Load the `plant_profiles` row (`baseIntervalDays`, `recommendedMinLiters`,
     `commonNames`, `version`) and the `containers` row (`volume_liters`).
  4. Call `computeInitialWaterTask({ id: <new uuid>, clockUtc: now, plant: { id,
     profileId, containerId, gardenSpaceId, createdAt: now, lastWateredAt }, profile:
     { id, version, commonNames, wateringProfile: { baseIntervalDays },
     containerProfile: { recommendedMinLiters } }, container: { id, volumeLiters },
     gardenSpace: { id } })` — import the real engine from `backend/care-engine/index.ts`;
     do NOT reimplement it.
  5. Insert the `care_tasks` row, mapping camelCase→snake_case and storing the engine's
     `sourceInputs` object into `source_inputs` (jsonb), `user_id` = caller.
  6. 201 + `{ plant, task }`.
- `GET /plants/:id/tasks` → the `care_tasks` for that plant (Slice 1: one `water` task);
  404/empty if not owned.

### Red-first integration tests → `backend/tests/integration/plants-api.integration.test.ts`
Use Fastify `app.inject()` (no real port). In `beforeAll`, create a test user via the
service-role admin API (`supabase.auth.admin.createUser({ email, password,
email_confirm: true })`) and obtain its access token (`signInWithPassword`); send it as
the bearer. Cover:
- **#15 happy path:** create a garden space + a container, then `POST /plants` with a
  valid body → **201**; the response (or a follow-up `GET /plants/:id/tasks`) has exactly
  **one** task with `kind: "water"`, `engineVersion: "0.1.0"`, a non-empty `inputsHash`,
  `sourceInputs` including `wateringBaselineAt`, a `dueAt`, and `priority: "normal"`.
- **#16:** `POST /plants` missing `containerId` → **400** (field-level error).
- **#17:** `POST /plants` missing `gardenSpaceId` → **400**.
- **#18:** `POST /plants` with an unknown `profileId` → **400**.
Keep tests isolated (unique emails / clean up rows you create, or use fresh ids).

### Verify
```bash
# ensure local Supabase up + migrations applied:
npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase status   # start + db reset if needed
cd backend && npm run test:int     # expect: prior 12 + the new #15–#18 all GREEN
npm test                            # unit suite still 50/50
```
Red-first: commit the failing tests first (no server → red), then implement to green.
If `supabase`/auth setup fails for an environment reason, STOP and report (blocker).

### Commits (suggested; one logical change each)
1. `chore(backend): add Fastify + supabase-js; ADRs for framework and API auth`
2. `test(api): add Slice 1 add-plant integration tests (#15–#18)` (RED)
3. `feat(api): add Fastify server + inventory endpoints and add-plant CareTask flow` (GREEN)
Push after each. Keep `npm test` (unit) green throughout.

### Forbidden
- Do NOT modify `backend/care-engine/**` (import it), `shared-schemas/**`, prior
  migrations (`0001`–`0003`), or existing unit/integration tests.
- Do NOT weaken a test or schema to pass. Do NOT commit Supabase keys.

### Final report
1. Commit hashes + titles; final `origin/master` SHA.
2. `npm run test:int` RED→GREEN with counts; `npm test` 50/50.
3. `git show --stat` per commit; confirm care-engine/schemas/prior migrations untouched.
4. The ADR file path(s) added, the endpoint list, and how auth + the request-scoped
   Supabase client are wired (for A3b's RLS-isolation tests).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after A3a lands
Verify #15–#18 green + endpoints + auth wiring. Then **A3b**: integration tests **#19**
(RLS isolation — a second user cannot read user A's plants/tasks) and **#20**
(`DELETE /plants/:id` removes the plant and cascades its `CareTask`s). After that,
re-evaluate Slice 1 DOD (backend complete) and decide with the owner whether to start
the Android UI slice (#21–#24) or close Slice 1 at the backend boundary.
