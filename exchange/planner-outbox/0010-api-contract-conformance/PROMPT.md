# Next Implementation Prompt — conform API responses to the camelCase shared-schemas (a2-pre)

**Chosen (owner: A).** Make every API response conform to the camelCase shared-schemas
(`shared-schemas/*.schema.json`) — the cross-boundary contract (D-06) — and lock it with
integration tests that validate responses against those schemas via Ajv. This precedes
the Android client (a2) so it builds on a clean, schema-true contract.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `d0ec682` == `origin/master`,
clean. The API currently returns **snake_case** DB rows on `GET /plants`,
`GET /plants/:id`, `GET /plants/:id/tasks` (and `plant` in `POST /plants`), while
`POST /plants`'s `task` is camelCase (engine output) — inconsistent and non-conformant.
Backend unit 50/50, integration 20/20, lint clean.

Two commits: (1) red conformance tests; (2) green response mappers.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Make all
HTTP API responses conform to the camelCase shared JSON Schemas, and prove it with Ajv
response-validation tests. Same Supabase harness as A3 (local stack up; env from
`npm_config_cache=/tmp/plantapp-npx-cache npx --yes supabase status -o env`).

### Baseline precondition (STOP if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect d0ec682b1d3e086ea8d7d35d61a404a74dd45f21
git status --short                         # expect empty
```

### Goal / contract
Every response body conforms to the matching schema in `shared-schemas/` (camelCase):
- `garden_spaces` row → **GardenSpace** (`garden-space.schema.json`)
- `containers` row → **Container** (`container.schema.json`)
- `plant_instances` row → **PlantInstance** (`plant-instance.schema.json`)
- `care_tasks` row → **CareTask** (`care-task.schema.json`)

Apply to: `POST /garden-spaces`, `POST /containers`, `POST /plants` (**both** `plant` and
`task`), `GET /plants`, `GET /plants/:id`, `GET /plants/:id/tasks`.

Mapping rules (DB snake_case → schema camelCase):
- snake→camel every column (`user_id`→`userId`, `profile_id`→`profileId`,
  `garden_space_id`→`gardenSpaceId`, `due_at`→`dueAt`, `engine_version`→`engineVersion`,
  `inputs_hash`→`inputsHash`, `plant_instance_id`→`plantInstanceId`,
  `created_at`→`createdAt`, etc.).
- `care_tasks.source_inputs` (jsonb) → `sourceInputs` **as-is** (its inner keys are
  already camelCase from the engine). Same for `rationale_metadata`→`rationaleMetadata`.
- **Omit** null/absent optional columns (don't emit `updatedAt: null`) so the
  `additionalProperties:false` schemas validate. Do not invent fields.
- `POST /plants`'s `task` is already the engine's camelCase CareTask — keep it, just
  ensure it validates against `care-task.schema.json`; map `plant` like the others.

### Implementation
- Add `backend/src/mappers.ts` (or similar): pure functions `toGardenSpace`,
  `toContainer`, `toPlantInstance`, `toCareTask` (DB row → schema-shaped object, omitting
  nulls). Apply them in `backend/src/app.ts` response paths.
- Do NOT change request validation, the DB schema/migrations, the auth hook, or the
  care-engine. Do NOT expose new fields beyond the schemas.

### COMMIT 1 (RED) — `test(api): validate API responses against shared schemas (#contract)`
New `backend/tests/integration/contract-conformance.integration.test.ts`: provision a user,
create a garden space + container + plant, then for each endpoint **compile the matching
shared schema with Ajv and assert the response validates**. Reuse the existing Ajv helper
`backend/tests/schema/_helpers.ts` (`compileSchema(name)`, `import` from `'../schema/_helpers.js'`)
— it loads `shared-schemas/<name>.schema.json` in strict 2020-12 mode (no new dep).
Cover: `POST /garden-spaces` → GardenSpace; `POST /containers` → Container; `POST /plants`
→ `plant` validates PlantInstance **and** `task` validates CareTask; `GET /plants` items →
PlantInstance; `GET /plants/:id` → PlantInstance; `GET /plants/:id/tasks` items → CareTask.
Run `npm run test:int` → RED (current snake_case responses fail schema validation; the
prior 20 still pass). Commit + push.

### COMMIT 2 (GREEN) — `feat(api): conform responses to camelCase shared-schema contract`
Add the mappers + apply them. Then:
```bash
cd /home/israel/Documents/Development/PlantApp/backend
npm run test:int   # expect ALL green (prior 20 + new conformance)
npm test           # 50/50
npm run typecheck  # clean
npm run lint       # clean (per the new tsconfig.eslint config)
```
If a prior integration test asserted a **snake_case** response field, update that
assertion to the camelCase contract (this is conformance, not weakening) — but do not
change a test's intent. STOP and report if a response can't be made schema-valid (e.g. a
schema/DB field mismatch surfaces — that's a real finding). Commit + push.

### Final report
1. Two commit hashes + titles; final `origin/master` SHA.
2. `npm run test:int` RED→GREEN counts; `npm test` 50/50; typecheck + lint clean.
3. `git show --stat` per commit; confirm care-engine/schemas/migrations/auth-hook
   untouched; list any existing-test assertions updated snake→camel.
4. The mapper file + which endpoints now route through it.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify all responses validate against `shared-schemas/*`. Then **a2** (Android UI): build
`:network` Retrofit DTOs (kotlinx.serialization, camelCase matching the now-conformant API
+ shared-schemas; D-02), validated in tests against `shared-schemas/*` via
networknt/json-schema-validator (D-06); then `:feature-inventory` Compose screens
(add/list/detail) + UI tests #21–#24 (Robolectric). Vision-check a2 for real.
