# VERIFICATION — handoff 0010-api-contract-conformance (red→green)

Gate: every API response validates against its `shared-schemas/*.schema.json` (camelCase),
asserted with Ajv (strict 2020-12) inside the integration suite.

## Commit 1 (`0dca7f1`) — RED
```
 FAIL  tests/integration/contract-conformance.integration.test.ts
 Test Files  1 failed | 4 passed (5)
      Tests  1 failed | 20 passed (21)
```
Responses were snake_case DB rows (e.g. `user_id`, `created_at`, `due_at`) → fail the
camelCase `additionalProperties:false` schemas. Prior 20 pass. Exit non-zero.

## Commit 2 (`678a488`) — GREEN
```
 ✓ tests/integration/garden-spaces-schema.integration.test.ts (3)
 ✓ tests/integration/core-tables.integration.test.ts (9)
 ✓ tests/integration/plants-api.integration.test.ts (5)
 ✓ tests/integration/plants-rls-delete.integration.test.ts (3)
 ✓ tests/integration/contract-conformance.integration.test.ts (1)
 Test Files  5 passed (5)
      Tests  21 passed (21)
```
Each endpoint's body now validates:
- `POST /garden-spaces` → GardenSpace; `POST /containers` → Container.
- `POST /plants` → `plant` validates PlantInstance AND `task` validates CareTask.
- `GET /plants` items → PlantInstance; `GET /plants/:id` → PlantInstance;
  `GET /plants/:id/tasks` items → CareTask.

## Other gates
```
$ npm run typecheck  -> clean
$ npm run lint       -> clean (exit 0)
$ npm test           -> Test Files 8 passed (8); Tests 50 passed (50)
```

## How (no contract/DB change)
`backend/src/mappers.ts` maps DB snake_case rows → camelCase schema objects, omitting
null/absent optional fields (so `additionalProperties:false` validates) and coercing
`volume_liters`→Number; `source_inputs`/`rationale_metadata` jsonb pass through as
`sourceInputs`/`rationaleMetadata` (inner keys already camelCase). `backend/src/app.ts`
applies them in all six response paths; `POST /plants` `task` stays the engine output.

## Scope / integrity
- `backend/care-engine/**`, `shared-schemas/**`, `supabase/migrations/**`,
  `backend/src/auth.ts`, and existing `backend/tests/**` unchanged (`git diff --quiet HEAD`).
- No existing-test assertion needed a snake→camel update (none referenced snake_case).
- No new deps; request validation + DB schema untouched.

## Final repo state
- origin/master = `678a488baa899703fc75407201f75cc9a8623062`; local == origin; clean.
- Local Supabase stack left running for a2.
