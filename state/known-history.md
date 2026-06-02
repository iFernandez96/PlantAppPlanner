# PlantApp — Known History

Commit + decision timeline for the real app repo
(`github.com/iFernandez96/PlantApp`, branch `master`). Oldest → newest.
Verified from `git log --oneline` on 2026-05-31. The full history is 20 commits;
`52c9d77` is HEAD and matches `origin/master`.

## Phase 0 — Brainstorm & strategy
- `62b3ad5` docs: add initial brainstorm and product-strategy notes

## Phase 1 — Foundation & architecture
- `1300fa7` chore: establish project foundation, architecture, and Slice 1 plan
- `d2d7514` chore: add BDD feature files, shared JSON schemas, AI prompts, and eval scaffolds
- `fcf0742` chore: tighten repo foundation before Slice 1 implementation

## Phase 2 — Watering baseline & Slice 1 decisions
- `9a3ae93` docs: add Slice 1 watering baseline to care formula
- `b4020cc` docs: clean up Slice 1 implementation plan numbering
- `fd11a2e` docs: accept Slice 1 decisions D-01..D-12
- `8110844` docs: sync accepted Slice 1 decisions across foundation docs
- `5dc4d87` docs: clean up final pre-scaffolding wording
- `06c1940` docs: sync Slice 1 implementation plan after accepted decisions
- `1b6140e` docs: remove stale README pre-scaffolding wording

## Phase 3 — Scaffolding
- `2c29a85` chore: scaffold backend Node.js TypeScript skeleton
- `228acd8` chore: scaffold supabase migrations
- `dc66cca` chore: scaffold android gradle multi-module skeleton
- `5d7d42b` chore: add root task runner
- `d5294a4` docs: update README after Slice 1 scaffolding

## Phase 4 — Project subagents
- `54c4c5f` chore: add project subagents for workflow reviews
- `9509a9b` docs: tighten foundation after subagent review

## Phase 5 — Schema tests (red-first) & contract alignment
- `56b1c4f` test(schema): add Slice 1 schema-validation failing tests
- `52c9d77` test(schema): make Slice 1 schema contract assertions consistent

## Phase 6 — Stale-comment cleanup (planner Option A)
- `b2836ca` test(schema): remove stale GardenSpace minLength comment — 2026-05-31; comment-only (3 ins/5 del, 1 file), planner-verified

## Phase 7 — Slice 1 care-engine (Option B, red-first)
- `ce141da` chore(backend): install dependencies and commit lockfile — 2026-06-02; first-ever `npm test` = 39 schema tests green
- `1d4e888` test(care-engine): add Slice 1 watering-engine failing tests — 2026-06-02; 8 care-engine tests red (`is not a function`), 39 green; engine still placeholder
- `25f1dbb` feat(care-engine): implement computeInitialWaterTask — 2026-06-02; engine green, `npm test` 47/47; test file unchanged; D-10 #7–#14 done
- `7a4e19b` test(care-engine): add Slice 1 seed-catalog failing tests — 2026-06-02; red (empty catalog)
- `b32e7a4` feat(care-engine): add Slice 1 seed PlantProfile catalog — 2026-06-02; 5 profiles, `npm test` 50/50; each emits a schema-valid CareTask

## Phase 8 — Slice 1 backend DB foundation (milestone A1)
- `661a135` chore(backend): add pg client and init Supabase local dev — 2026-06-02
- `8d1905a` test(db): add Slice 1 garden_spaces integration test — 2026-06-02; red
- `e92bc0f` feat(db): add garden_spaces table with RLS (migration 0002) — 2026-06-02; 3 integration tests green

## Phase 9 — Slice 1 core tables (milestone A2)
- `e2c3795` test(db): add Slice 1 core-tables integration test — 2026-06-02; red
- `670ebaf` feat(db): add Slice 1 core tables with RLS + seed profiles — 2026-06-02; 4 tables + RLS + 5 seeded profiles; 12 integration tests green

## Phase 10 — Slice 1 backend API (milestone A3a)
- `118660a` chore(backend): add Fastify + supabase-js; ADRs for framework and API auth — 2026-06-02
- `3b263d1` test(api): add Slice 1 add-plant integration tests (#15–#18) — 2026-06-02; red
- `1cd2eac` feat(api): add Fastify server + inventory endpoints and add-plant CareTask flow — 2026-06-02; integration 17/17, unit 50/50

## Phase 11 — Slice 1 backend DOD complete (milestone A3b)
- `cfb3751` test(api): add Slice 1 RLS-isolation + delete-cascade tests (#19, #20) — 2026-06-02; red
- `8f588af` feat(api): add plant list/get/delete endpoints (RLS + cascade) — 2026-06-02; **#1–#20 green** (test:int 20/20, unit 50/50)

## Phase 12 — Backend lint hygiene + Android toolchain (post-DOD)
- `603869e` chore(backend): fix ESLint TypeScript project config so lint passes — 2026-06-02; lint 16→0 via `tsconfig.eslint.json`; build tsconfig untouched; unit 50/50
- `d0ec682` chore(android): generate Gradle wrapper — 2026-06-02; a1: wrapper committed, `:app:assembleDebug` BUILD SUCCESSFUL (compileSdk 35, android-35 installed)

## Phase 13 — API contract conformance + Android network (a2-pre, a2)
- `0dca7f1` test(api): validate API responses against shared schemas (#contract) — 2026-06-02; red
- `678a488` feat(api): conform responses to camelCase shared-schema contract — 2026-06-02; `src/mappers.ts`; responses Ajv-valid vs shared-schemas; integration 21/21
- `e69f6a0` test(android-network): add Slice 1 DTO + schema-validation tests — 2026-06-02; red
- `f6c8155` feat(android-network): add Slice 1 Retrofit DTOs + API client ← **HEAD / origin/master** — 2026-06-02; `:network` tests 10/10 (networknt schema-valid), `:app:assembleDebug` OK
- *(in flight)* `0012-android-domain-data` (a3a) — `:domain` models + `:data` repository over `:network`

## Accepted decisions (canonical record in `docs/slice-01-decision-log.md`)

All accepted 2026-05-26:

| ID | Pin |
|---|---|
| D-01 | Node.js + TypeScript API runtime |
| D-02 | Retrofit + OkHttp + kotlinx.serialization (Android) |
| D-03 | Supabase migrations CLI |
| D-04 | No background-job runner in Slice 1 (defer) |
| D-05 | Supabase Auth, email magic link only |
| D-06 | Ajv on backend; handwritten DTOs + kotlinx.serialization on Android |
| D-07 | Crash reporting deferred to Slice 3 |
| D-08 | API hosting deferred until first deploy |
| D-09 | Care-engine **backend-only** for Slice 1 (no `:care-engine` Android module) |
| D-10 | Care-engine v0.1.0 watering formula with `wateringBaselineAt` |
| D-11 | No photos in Slice 1 |
| D-12 | Postal code only; no precise location in Slice 1 |

## Slice 1 scope (locked)

"Add a `PlantInstance` in a `Container` in a `GardenSpace`, then generate one
deterministic `water` `CareTask`." Excludes weather, feedback, advisories,
feeding, AI, notifications, photos, camera, production auth flows, precise
location.

## Care-engine v0.1.0 formula (D-10, for the on-deck care-engine tests)

```
wateringBaselineAt = plant.lastWateredAt ?? plant.createdAt
containerFactor    = clamp(container.volumeLiters
                           / profile.containerProfile.recommendedMinLiters, 0.5, 1.5)
dueAt              = wateringBaselineAt + profile.wateringProfile.baseIntervalDays × containerFactor
priority           = "normal"
engineVersion      = "0.1.0"
sourceInputs       = { plantInstanceId, profileId, profileVersion, containerId,
                       gardenSpaceId, clockUtc, wateringBaselineAt,
                       weatherWindowRef: null, feedbackWindowRef: null }
inputsHash         = sha256(canonical-json(sourceInputs))
```

## Planner timeline

- **2026-05-31** — Planner control tower initialized. Verified PlantApp at
  `52c9d77`, clean, no production behavior. Recorded planner decision PD-01
  (choose Option A) in `decisions/planner-decisions.md`.
- **2026-05-31** — Option A landed (`b2836ca`) and planner-verified comment-only.
  Owner added a remote for the planner repo
  (`git@github.com:iFernandez96/PlantAppPlanner.git`) and pushed `master`.
  Next step set to Option B (care-engine red-first tests #7–#14), pending the
  `npm install` decision.
- **2026-06-02** — Autonomous in-session ping-pong adopted (planner ↔ impl Claude via
  exchange watchers; impl runs `--dangerously-skip-permissions`). Option B red-first
  landed: `ce141da` (deps+lockfile; 39 schema tests green on first run) + `1d4e888`
  (8 care-engine tests red). Planner verified and published green prompt
  `0002-care-engine-green`.
- **2026-06-02** — Green landed: `25f1dbb` implements `computeInitialWaterTask`,
  `npm test` 47/47 (planner-verified: function exported, test file unchanged).
  Care-engine #7–#14 complete. Planner **paused the loop** to ask the owner the next
  milestone (Postgres-gated API tests vs. an approval-free seed-catalog step vs. Android).
- **2026-06-02** — Owner chose "B, then A". B done: `7a4e19b` (red) + `b32e7a4`
  (green seed catalog), `npm test` 50/50, planner-verified. Toward A, planner found the
  local DB env not ready (Supabase CLI not installed; no web framework chosen) and
  **paused to ask the owner** the A approach (Supabase CLI vs. Dockerized Postgres) +
  framework, proposing A1 migrations/RLS then A2 server/endpoints.
- **2026-06-02** — Owner chose Supabase CLI (i) + Fastify (for A3). A1 landed
  (`661a135`/`8d1905a`/`e92bc0f`): Supabase local + `garden_spaces` + RLS; 3 integration
  tests green; planner-verified. A2 (`0005-db-core-tables`: remaining tables + RLS +
  seed) published and in flight.
- **2026-06-02** — A2 landed (`e2c3795` red + `670ebaf` green): 4 tables + RLS + seeded
  `plant_profiles`; 12 integration tests green. A3a (`0006-api-add-plant`: Fastify +
  ADRs + add-plant→CareTask + #15–#18) published and in flight.
- **2026-06-02** — A3a landed (`118660a`/`3b263d1`/`1cd2eac`): Fastify API + auth (RLS) +
  add-plant→CareTask + #15–#18; integration 17/17, unit 50/50; planner-verified. Added the
  **vision-alignment gate** (each published prompt checked vs `../PlantApp/ChatHistory.md`;
  log `reviews/vision-checks.md`). A3b (`0007-api-read-delete`: #19 RLS isolation + #20
  cascade) published, vision-checked ALIGNED, in flight.
- **2026-06-02** — A3b landed (`cfb3751`/`8f588af`): plant list/get/delete + #19 RLS
  isolation + #20 delete cascade. **Slice 1 backend DOD #1–#20 complete** (`npm run
  test:int` 20/20, unit 50/50, typecheck clean). Loop **paused** for owner decision:
  Android UI #21–#24 / lint-config cleanup / close Slice 1 at backend boundary.
- **2026-06-02** — Owner chose "b, then a". b done (`603869e`): `npm run lint` passes
  (16→0, `tsconfig.eslint.json`). a1 (`0009-android-wrapper-build`: Gradle wrapper +
  skeleton assemble) published, in flight; a2 = `:network` DTOs + Compose screens + UI
  tests #21–#24 next.
- **2026-06-02** — a1 landed (`d0ec682`): Gradle wrapper + skeleton assembles
  (`:app:assembleDebug` OK, compileSdk 35). **Paused before a2** on an API-contract
  decision: API responses are snake_case / inconsistent vs the camelCase shared-schemas;
  owner to choose conform-to-camelCase (rec) vs snake-wire vs proceed-and-map. The
  vision-alignment gate surfaced this.
- **2026-06-02** — Owner chose A. Published `0010-api-contract-conformance` (snake→camel
  response mappers + Ajv response-validation tests vs `shared-schemas/*`), in flight; a2
  (Android UI) resumes once the API is schema-conformant.
- **2026-06-02** — A landed (`0dca7f1`/`678a488`): all API responses conform to camelCase
  shared-schemas, Ajv-locked (21/21). a2 (`0011-android-network`: `:network` DTOs + Retrofit
  + networknt schema tests) published, vision-checked ALIGNED, in flight; a3 = Compose
  screens + UI tests #21–#24.
- **2026-06-02** — a2 landed (`e69f6a0`/`f6c8155`): `:network` DTOs + Retrofit, JVM tests
  10/10 (networknt schema-valid). a3a (`0012-android-domain-data`: `:domain`+`:data` over
  `:network`, Room deferred) published, vision ALIGNED, in flight; a3b = Compose screens +
  UI tests #21–#24 (closes Slice 1).
