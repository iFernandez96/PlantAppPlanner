# Next Implementation Prompt — A3b: list/get/delete + RLS isolation (#19) + cascade delete (#20)

**Milestone A, step A3b (closes the Slice 1 backend DOD).** Add the plant read +
delete endpoints and prove plan tests **#19** (a second user cannot read user A's
plants/tasks — RLS isolation) and **#20** (`DELETE /plants/:id` removes the plant and
cascades its `CareTask`s).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `1cd2eac` == `origin/master`,
clean. A3a shipped Fastify + auth (request-scoped Supabase client → RLS) + `POST
/garden-spaces|/containers|/plants` + `GET /plants/:id/tasks`; integration 17/17, unit
50/50. RLS isolation is already enforced by the DB; this step adds the read/delete
surface and the tests that prove #19/#20.

Two commits: (1) red tests; (2) green endpoints.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add
plant read/delete endpoints and the #19/#20 integration tests. Same harness as A3a
(local Supabase up; `npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase status`;
test env from `npx supabase status -o env`).

### Baseline precondition (STOP if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect 1cd2eac8354427c8afe24de9304cda594d4de53e
git status --short                         # expect empty
```

### Forbidden
- Do NOT modify `backend/care-engine/**`, `shared-schemas/**`, `supabase/migrations/**`,
  existing unit tests, or the existing `POST` endpoints' behavior / the auth hook.
- No new deps. Reuse the request-scoped Supabase client + `onRequest` auth hook so RLS
  applies (do not use the service-role client in the endpoints).
- Do NOT "fix" the pre-existing lint-config issue here (separate handoff).

### Endpoints to add (in `backend/src/app.ts`, same auth hook)
- `GET /plants` → list the caller's plant_instances (RLS-scoped; returns only own rows).
- `GET /plants/:id` → the caller's single plant; **404** if not visible/owned.
- `DELETE /plants/:id` → delete the caller's plant_instance; **204** on success, **404**
  if not visible/owned. The `care_tasks` rows cascade via the existing
  `plant_instances → care_tasks ON DELETE CASCADE` FK (don't delete tasks manually).

### COMMIT 1 (RED) — `test(api): add Slice 1 RLS-isolation + delete-cascade tests (#19, #20)`
Add tests (extend `backend/tests/integration/plants-api.integration.test.ts` or a new
`*.integration.test.ts`). Provision **two** users via the service-role admin API
(`auth.admin.createUser` + `signInWithPassword`) → tokens A and B. Then:
- **#19 (RLS isolation):** user A creates a garden space + container + plant. With user
  **B**'s bearer: `GET /plants` does **not** include A's plant; `GET /plants/:id`
  (A's id) → **404**; `GET /plants/:id/tasks` (A's id) → **404 or empty**.
- **#20 (delete cascade):** user A creates a plant (which emits one CareTask), then
  `DELETE /plants/:id` → **204**; afterwards `GET /plants/:id` → **404** and `GET
  /plants/:id/tasks` → **404/empty**; and a direct DB check (via the `pg` client) shows
  **0** `care_tasks` rows for that `plant_instance_id` (cascade confirmed).
Run `npm run test:int` → RED (the new GET-list/:id and DELETE routes don't exist yet →
those assertions fail; prior 17 still pass). Commit + push.

### COMMIT 2 (GREEN) — `feat(api): add plant list/get/delete endpoints (RLS + cascade)`
Implement the three endpoints. Then:
```bash
cd /home/israel/Documents/Development/PlantApp/backend && npm run test:int   # expect all green
npm test                                                                      # expect 50/50
```
Expected GREEN: all integration tests pass (prior 17 + #19/#20); unit 50/50. If RLS
doesn't isolate or the cascade leaves orphan tasks, STOP and report — don't weaken the
test. Commit + push.

### Final report
1. Two commit hashes + titles; final `origin/master` SHA.
2. `npm run test:int` RED→GREEN counts; `npm test` 50/50.
3. `git show --stat` per commit; confirm care-engine/schemas/migrations/existing tests
   + the auth hook + POST endpoints untouched.
4. Confirm #19 isolation + #20 cascade behavior observed (quote the key assertions).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after A3b lands
Verify #19/#20 green → **Slice 1 backend DOD is met** (#1–#20: schema, deterministic
engine, seed catalog, DB+RLS, add-plant→CareTask API, isolation, cascade). Then stop and
ask the owner the next direction: (a) the Android UI slice (#21–#24 — needs the Android
toolchain/emulator + the uncommitted Gradle wrapper), (b) a small lint-config cleanup
handoff (the pre-existing `tsconfig`/ESLint project mismatch so `npm run lint` passes),
or (c) close Slice 1 at the backend boundary. This is an owner decision (scope + new
toolchain/approval), so pause the loop and ask.
