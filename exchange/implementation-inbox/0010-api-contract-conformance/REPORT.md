# DONE — handoff 0010-api-contract-conformance (a2-pre, two commits red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** every API response now conforms to the camelCase shared JSON Schemas,
validated by Ajv in integration tests. Integration 21/21, unit 50/50, typecheck + lint
clean. Final `origin/master` = `678a488baa899703fc75407201f75cc9a8623062`.

## Baseline precondition — matched
- HEAD = `d0ec682b1d3e086ea8d7d35d61a404a74dd45f21` == origin/master; clean.
- Local Supabase running; test env from `npx supabase status -o env` (cache-prefixed),
  exported as SUPABASE_URL/ANON_KEY/SERVICE_ROLE_KEY; no keys committed.

## Commit 1 (RED) — `test(api): validate API responses against shared schemas (#contract)`
- Hash: `0dca7f1`
- New `backend/tests/integration/contract-conformance.integration.test.ts`: provisions a
  user, creates garden space + container + plant, and validates every response against
  the matching shared schema compiled via the existing Ajv helper
  (`compileSchema` from `../schema/_helpers.js`, strict 2020-12): `POST /garden-spaces`→
  GardenSpace, `POST /containers`→Container, `POST /plants`→ `plant` (PlantInstance) **and**
  `task` (CareTask), `GET /plants` items→PlantInstance, `GET /plants/:id`→PlantInstance,
  `GET /plants/:id/tasks` items→CareTask.
- `npm run test:int` (RED): **1 failed | 20 passed (21)** — conformance failed because the
  responses were snake_case DB rows (e.g. `user_id`, `created_at`) violating the
  camelCase `additionalProperties:false` schemas. Prior 20 still pass. Exit non-zero.
- `git show --stat`: 1 file, +133. Pushed `d0ec682..0dca7f1`.

## Commit 2 (GREEN) — `feat(api): conform responses to camelCase shared-schema contract`
- Hash: `678a488`
- New `backend/src/mappers.ts`: pure `toGardenSpace`, `toContainer`, `toPlantInstance`,
  `toCareTask` (DB row → schema-shaped object). snake→camel every column; `source_inputs`
  jsonb → `sourceInputs` as-is (inner keys already camelCase from the engine), same for
  `rationale_metadata`→`rationaleMetadata`; **null/absent optional columns omitted** (a
  `put()` helper skips null/undefined) so `additionalProperties:false` schemas validate;
  `volume_liters` coerced to `Number`. No field invented beyond the schemas.
- `backend/src/app.ts` (+13/−6): routes now return mapped bodies —
  `POST /garden-spaces`→`toGardenSpace`, `POST /containers`→`toContainer`, `POST /plants`→
  `{ plant: toPlantInstance(...), task }` (task is the engine's already-camelCase CareTask,
  left as-is and validated), `GET /plants`→`.map(toPlantInstance)`,
  `GET /plants/:id`→`toPlantInstance`, `GET /plants/:id/tasks`→`.map(toCareTask)`.
- `npm run typecheck` clean; `npm run lint` clean; `npm run test:int` → **21 passed (21)**;
  `npm test` → **50 passed (50)**.
- `git show --stat`: 2 files (`src/app.ts`, `src/mappers.ts`), +104/−6. Pushed
  `0dca7f1..678a488`.

## Mapper file + endpoints routed through it
`backend/src/mappers.ts` — used by all response paths in `backend/src/app.ts`:
`POST /garden-spaces`, `POST /containers`, `POST /plants` (plant), `GET /plants`,
`GET /plants/:id`, `GET /plants/:id/tasks`. The `POST /plants` `task` comes straight from
`computeInitialWaterTask` (already camelCase) and is validated against `care-task.schema.json`.

## Existing-test assertions updated snake→camel
**None.** The prior integration tests only referenced fields that are identical pre/post
mapping (`.id`, `.plant.id`, `task.kind`, `task.engineVersion`, `task.sourceInputs.*`,
`tasks[0].kind`) — all already camelCase (task) or unchanged keys — so no existing
assertion needed changing. `backend/tests/**` (other than the new file in commit 1) is
unchanged.

## Compliance
- `backend/care-engine/**`, `shared-schemas/**`, `supabase/migrations/**`, and
  `backend/src/auth.ts` UNCHANGED (`git diff --quiet HEAD`).
- Request validation, DB schema/migrations, auth hook, and the care-engine all unchanged;
  no new fields beyond the schemas; no new deps (reused the Ajv helper).

## Commit hashes + titles
1. `0dca7f1` — test(api): validate API responses against shared schemas (#contract)
2. `678a488` — feat(api): conform responses to camelCase shared-schema contract

Final `origin/master` SHA: `678a488baa899703fc75407201f75cc9a8623062`

## Next (a2, per planner follow-up)
Android `:network` Retrofit DTOs (kotlinx.serialization, camelCase matching the
now-conformant API + shared-schemas), validated in tests against `shared-schemas/*` via
networknt/json-schema-validator; then `:feature-inventory` Compose screens (add/list/
detail) + UI tests #21–#24 (Robolectric-first).
