# DONE — handoff 0007-api-read-delete (A3b, two commits red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** plant list/get/delete endpoints added; #19 RLS isolation + #20 delete
cascade proven. Integration 20/20, unit 50/50, typecheck clean.
Final `origin/master` = `8f588af90c69b569db1abdeceb5d97020b56b6f6`.
**This closes the Slice 1 backend DOD (#1–#20).**

## Baseline precondition — matched
- HEAD = `1cd2eac8354427c8afe24de9304cda594d4de53e` == origin/master; clean.
- Local Supabase running; test env from `npx supabase status -o env` (cache-prefixed),
  exported as SUPABASE_URL/ANON_KEY/SERVICE_ROLE_KEY; no keys committed.

## Commit 1 (RED) — `test(api): add Slice 1 RLS-isolation + delete-cascade tests (#19, #20)`
- Hash: `cfb3751`
- New file `backend/tests/integration/plants-rls-delete.integration.test.ts`: provisions
  **two** users (A, B) via the service-role admin API, opens a `pg` client for the
  direct cascade check, and dynamic-imports `buildApp`.
  - **#19**: A creates garden space + container + plant; with B's bearer `GET /plants`
    excludes A's id, `GET /plants/:id` (A's) → 404, `GET /plants/:id/tasks` (A's) →
    404/empty; A can read own plant (200).
  - **#20**: A creates a plant (1 CareTask, asserted via direct `pg` count = 1),
    `DELETE /plants/:id` → 204, then `GET /plants/:id` → 404, tasks 404/empty, and a
    direct `pg` count of `care_tasks` for that plant = **0** (cascade).
  - **#20b**: B deleting A's plant → 404; A's plant still present (200).
- `npm run test:int` (RED): **3 failed | 17 passed (20)** — the new list/get/delete
  assertions fail because those routes don't exist (Fastify returns 404 for the unknown
  routes, so A's own-plant read = 404, delete = 404, post-delete-survival = 404). Prior
  17 pass. Exit non-zero — intended red.
- `git show --stat`: 1 file, +163. Pushed `1cd2eac..cfb3751`.

## Commit 2 (GREEN) — `feat(api): add plant list/get/delete endpoints (RLS + cascade)`
- Hash: `8f588af`
- `backend/src/app.ts` (+37, no deletions): added three routes on the existing
  `onRequest` auth hook + request-scoped Supabase client (so RLS applies; no
  service-role in handlers):
  - `GET /plants` → `plant_instances.select('*')` (RLS-scoped) → 200 array.
  - `GET /plants/:id` → `.eq('id', id).maybeSingle()`; 200 row or **404** when RLS
    hides the row / it doesn't exist.
  - `DELETE /plants/:id` → `.delete().eq('id', id).select('id')`; **204** when a row was
    deleted, **404** when nothing matched (not owned/visible). `care_tasks` cascade via
    the existing `plant_instances → care_tasks ON DELETE CASCADE` FK (no manual task
    delete).
- `npm run typecheck` clean. `npm run test:int` → **20 passed (20)**. `npm test` →
  **50 passed (50)**.
- `git show --stat`: 1 file (`backend/src/app.ts`), +37. Pushed `cfb3751..8f588af`.

## #19 / #20 behavior observed (key assertions, now green)
- #19: `expect(idsB).not.toContain(plantId)`; `expect(getB.statusCode).toBe(404)`;
  A's own `GET /plants/:id` → 200. → second user cannot see A's plant or tasks.
- #20: `expect(del.statusCode).toBe(204)`; post-delete `GET /plants/:id` → 404; and the
  direct DB check `select count(*) from care_tasks where plant_instance_id = $1` returns
  **1 before** delete and **0 after** → cascade confirmed at the database.
- #20b: cross-user `DELETE` → 404, A's plant survives (200).

## Compliance
- `backend/care-engine/**`, `shared-schemas/**`, `supabase/migrations/**`, existing unit
  tests, `backend/src/auth.ts`, `backend/src/config.ts`, and the existing POST endpoints
  all UNCHANGED (`git diff --quiet HEAD`; app.ts diff is purely additive +37/−0).
- No new deps; reused the request-scoped client + `onRequest` hook (no service-role in
  endpoints). Did not touch the pre-existing lint-config issue.

## Commit hashes + titles
1. `cfb3751` — test(api): add Slice 1 RLS-isolation + delete-cascade tests (#19, #20)
2. `8f588af` — feat(api): add plant list/get/delete endpoints (RLS + cascade)

Final `origin/master` SHA: `8f588af90c69b569db1abdeceb5d97020b56b6f6`

## Slice 1 backend DOD note (for planner → owner)
#1–#20 are now green: schema validation, deterministic engine, seed catalog, DB + RLS,
add-plant→CareTask API, RLS isolation, delete cascade. Per the prompt's follow-up, the
next direction is an **owner decision**: (a) Android UI slice #21–#24 (needs Android
toolchain/emulator + the uncommitted Gradle wrapper), (b) a small lint-config cleanup
handoff (pre-existing `tsconfig`/ESLint project mismatch so `npm run lint` passes), or
(c) close Slice 1 at the backend boundary. Pausing for that decision.
