# DONE — handoff 0030-api-advisory-accept (3d-api, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** `POST /plants/:id/advisories/accept` wired to the `0029` engine — on explicit
acceptance it creates and persists exactly one `CareTask` via `computeTaskFromAdvisory`. The
`GET /plants/:id/advisories` handler is unchanged and still creates nothing. Backend gate green.
Final `origin/master` = `53d093e0ee570dcaf1e44a926dfb343935f6c7a8`.

## Baseline + unblock
- HEAD at start = `e4ffe4b…` == origin/master; clean. Local Supabase stack up (env via
  `supabase status -o env`).

## The handler (`backend/src/app.ts`, one new POST)
`app.post('/plants/:id/advisories/accept', { onRequest: requireAuth, schema: { body: required
['kind'] } }, …)`:
1. **Loads** mirror `GET /plants/:id/advisories`, plus the plant select adds **`garden_space_id`**
   (→ `sourceInputs.gardenSpaceId`) and the profile select adds **`version`** (→
   `sourceInputs.profileVersion`). RLS-scoped: `404 not_found` when the plant isn't owned/visible.
   Then `computeAdvisories({...})` exactly as the GET does.
2. `match = advisories.find(a => a.kind === body.kind)`; if none → **400** `{ error: 'advisory not
   applicable', field: 'kind' }`.
3. `now = new Date().toISOString()`, `taskId = randomUUID()`, then `computeTaskFromAdvisory(...)`
   in a try/catch — a throw (e.g. `unsupported advisory kind: pollination`) → **400** `{ error:
   <message>, field: 'kind' }`.
4. **Persists** a `care_tasks` row (mirrors the add-plant insert) with `user_id: request.userId`
   and `rationale_metadata: task.rationaleMetadata` (+ id, plant_instance_id, kind, due_at,
   priority, rationale, engine_version, inputs_hash, source_inputs, status). On insert error →
   400; on success → **201** `toCareTask(ins.data)`.
- Import added: `computeTaskFromAdvisory` from `../care-engine/task-from-advisory.js`
  (`randomUUID`/`computeAdvisories`/`toCareTask` were already imported).

## Tests — `backend/tests/integration/advisory-accept.integration.test.ts` (new, 4)
Mirrors `advisories-api.integration.test.ts` (two provisioned users; space/container/plant
helpers; `compileSchema('care-task')`):
- **container-size accept + GET-creates-nothing invariant**: passion fruit in 19L → GET shows
  `container-size`; GET twice does **not** change the `/tasks` count (created nothing); then
  `POST {kind:'container-size'}` → **201**, body validates against care-task.schema.json,
  `kind==='repot'`, `priority==='high'`, and `/tasks` count increases by **exactly 1** only after
  the POST.
- **pollination → 400** (single tomatillo has a pollination advisory, but the engine throws
  unsupported).
- **not-applicable → 400** (strawberry in an in-range 6L container has no advisories, so `support`
  isn't applicable).
- **RLS**: user B `POST` on user A's plant → **404**.

## Gate
```
$ set -a; eval "$(npx supabase status -o env)"; set +a
$ npm run test:int     Test Files 8 passed (8) ; Tests 35 passed (35)   # was 31 → 35 (+4)
$ npm test             Tests 72 passed (72)                              # unit unchanged
$ npm run validate-schemas   all schemas valid
$ npm run typecheck && npm run lint   clean
```
**GET-creates-nothing assertion passed** (task count unchanged across two GET advisories; +1 only
after the explicit POST).

## Commit
- `53d093e` — feat(api): POST /plants/:id/advisories/accept creates a CareTask from an accepted advisory
- `git show --stat HEAD`: 2 files, +288 — only `backend/src/app.ts` +
  `backend/tests/integration/advisory-accept.integration.test.ts`.

## Compliance
- No change to the care engine, `advisories.ts`, schemas, migrations, Android, or other endpoints.
  No new dependency. `GET /plants/:id/advisories` remains create-nothing. RLS not weakened. No new
  task kind beyond what the engine returns (`repot`/`support`).

Final `origin/master` SHA: `53d093e0ee570dcaf1e44a926dfb343935f6c7a8`

## Next (3d-android, per planner follow-up)
`:network` `acceptAdvisory(plantId, kind)` (POST) + `:data` repo method + a `:feature-inventory`
detail-screen "Accept" action per advisory (accept → refresh tasks/advisories) + Robolectric
tests. Likely decomposed net/data then ui.
