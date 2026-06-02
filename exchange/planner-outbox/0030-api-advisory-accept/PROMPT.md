# Next Implementation Prompt — backlog (3d-api): `POST /plants/:id/advisories/accept`

**Backlog item (3) UX follow-ups, step 3d, part 2 of N (API).** Wire the `0029` engine to an
endpoint: on **explicit user acceptance** of an advisory, create and persist a `CareTask`.
**Invariant:** the existing `GET /plants/:id/advisories` still computes-on-read and creates
nothing; only this new POST creates a task, and only via the deterministic `computeTaskFromAdvisory`.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`e4ffe4b5430870877c41327f73679b7813fe7032` == `origin/master`, clean. `care-engine/
task-from-advisory.ts` exports `computeTaskFromAdvisory` (container-size→repot, support→support,
pollination/other → **throws** `unsupported advisory kind`). `src/app.ts` already has
`GET /plants/:id/advisories` that loads the plant/profile/container + the caller's
`profileInstanceCount` and calls `computeAdvisories` (RLS-scoped; 404 if the plant isn't owned);
the add-plant flow inserts `care_tasks` rows with columns `id, plant_instance_id, user_id, kind,
due_at, priority, rationale, engine_version, inputs_hash, source_inputs, status` (+ a
`rationale_metadata` jsonb column read by `toCareTask`). `src/mappers.ts` `toCareTask` maps a
`care_tasks` row → the camelCase `care-task.schema.json` shape. Integration tests live in
`backend/tests/integration/` (provision users via service role; `app.inject`; Ajv-validate via
`compileSchema`). Backend unit 72/72, integration 31/31, `validate-schemas` green.

Single logical change (the accept endpoint) → one commit. Red-first (write the integration test
first).

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add
`POST /plants/:id/advisories/accept`. Red-first: write the integration test first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect e4ffe4b5430870877c41327f73679b7813fe7032 == origin/master
git status --short                         # expect empty
```

### Scope — `backend/src/app.ts` (one new handler)
Add `app.post('/plants/:id/advisories/accept', { onRequest: requireAuth, schema: { body: { type:
'object', required: ['kind'], properties: { kind: { type: 'string' } } } } }, async (request, reply)
=> { … })`:
1. Reuse the **same loads** as `GET /plants/:id/advisories`, but:
   - add **`garden_space_id`** and **`version`** is on the profile select — i.e. the plant select
     must include `garden_space_id` (needed for `sourceInputs.gardenSpaceId`); the profile select
     must include **`version`** (needed for `sourceInputs.profileVersion`). Keep the RLS scoping and
     the `404 not_found` when the plant isn't owned/visible.
   - compute `advisories = computeAdvisories({...})` exactly as the GET does.
2. Find `match = advisories.find(a => a.kind === body.kind)`. If none → `reply.code(400).send({
   error: 'advisory not applicable', field: 'kind' })` (the advisory must be currently applicable to
   be accepted).
3. `const now = new Date().toISOString(); const taskId = randomUUID();` then call the engine inside
   a try/catch:
   ```ts
   import { computeTaskFromAdvisory } from '../care-engine/task-from-advisory.js';
   let task;
   try {
     task = computeTaskFromAdvisory({
       id: taskId, clockUtc: now,
       advisory: { kind: match.kind, severity: match.severity, title: match.title, message: match.message },
       plant: { id: plant.id, profileId: plant.profile_id, containerId: plant.container_id, gardenSpaceId: plant.garden_space_id },
       profile: { id: profile.id, version: profile.version },
     });
   } catch (e) {
     return reply.code(400).send({ error: (e as Error).message, field: 'kind' }); // e.g. unsupported advisory kind: pollination
   }
   ```
4. Persist a `care_tasks` row (mirror the add-plant insert), including `rationale_metadata:
   task.rationaleMetadata` and `user_id: request.userId`:
   ```ts
   const ins = await request.supabase.from('care_tasks').insert({
     id: task.id, plant_instance_id: task.plantInstanceId, user_id: request.userId,
     kind: task.kind, due_at: task.dueAt, priority: task.priority, rationale: task.rationale,
     rationale_metadata: task.rationaleMetadata, engine_version: task.engineVersion,
     inputs_hash: task.inputsHash, source_inputs: task.sourceInputs, status: task.status,
   }).select().single();
   if (ins.error) return reply.code(400).send({ error: ins.error.message });
   return reply.code(201).send(toCareTask(ins.data as Record<string, unknown>));
   ```
   (Import `computeTaskFromAdvisory`; `randomUUID`, `computeAdvisories`, `toCareTask` are already
   imported in `app.ts`.)

### Tests — `backend/tests/integration/advisory-accept.integration.test.ts` (new)
Mirror `advisories-api.integration.test.ts` (provision two users; create space/container/plant via
the existing helpers; `compileSchema('care-task')`):
- Set up a plant with a **container-size** advisory (e.g. passion-fruit profile in a small
  container, as the advisories test does). First `GET /plants/:id/advisories` → contains
  `container-size`; `GET /plants/:id/tasks` → record the count.
- `POST /plants/:id/advisories/accept` `{ kind: 'container-size' }` → **201**; body validates
  against `care-task.schema.json`; `kind === 'repot'`; `priority === 'high'`.
- **Invariant:** a second `GET /plants/:id/advisories` still returns the advisory **and** the only
  new `care_tasks` row is the one from the explicit POST (i.e. GET created nothing) — assert
  `GET /plants/:id/tasks` increased by exactly 1 only after the POST, not after the GET.
- `POST … { kind: 'pollination' }` → **400** (unsupported). `POST … { kind: 'support' }` when the
  plant has no support advisory → **400** (not applicable).
- **RLS:** user B `POST` on user A's plant → **404**.

### Forbidden
- No change to the care engine, `advisories.ts`, schemas, migrations, Android, or other endpoints.
  No new dependency. The `GET /plants/:id/advisories` handler must remain create-nothing. Don't
  weaken RLS. Don't add a new task kind beyond what the engine returns.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/backend
set -a; eval "$(npm_config_cache=/tmp/plantapp-npx-cache npx supabase status -o env)"; set +a
npm run test:int            # new advisory-accept tests pass; total > 31
npm test                     # unit still 72/72
npm run validate-schemas && npm run typecheck && npm run lint   # green/clean
```
Red→green: the new integration test fails before the endpoint exists, then passes. If the local
stack isn't running, integration tests fail to connect — that is *environment*, not a regression
(start it with `npm_config_cache=/tmp/plantapp-npx-cache npx supabase start`). Report the
before/after integration count + new test names.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add backend/src/app.ts backend/tests/integration/advisory-accept.integration.test.ts
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(api): POST /plants/:id/advisories/accept creates a CareTask from an accepted advisory"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The handler (loads + RLS 404; not-applicable/unsupported → 400; engine call; persisted columns;
   returns `toCareTask`).
2. `npm run test:int` before→after + new test names; `npm test` 72/72; validate-schemas/typecheck/
   lint green. Explicitly confirm the **GET-creates-nothing** assertion passed.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only `src/app.ts` +
   the new test changed.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `app.ts` + the new test; 201 returns a `repot`/`support` task; GET still
creates nothing; pollination/absent → 400; RLS 404; `npm test` 72/72). Then **3d-android**:
`:network` `acceptAdvisory(plantId, kind)` (POST) + `:data` repo method + a `:feature-inventory`
detail-screen **"Accept"** action on each advisory (calls accept, then refreshes tasks/advisories)
+ Robolectric tests — likely decomposed net/data then ui. Then (2) emulator e2e smoke; then (4)
Slice 3 (WorkManager local first; STOP for owner Firebase/FCM setup). Vision-check each
product-surface step.
