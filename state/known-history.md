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
- `f6c8155` feat(android-network): add Slice 1 Retrofit DTOs + API client — 2026-06-02; `:network` tests 10/10 (networknt schema-valid), `:app:assembleDebug` OK
- `0f8c596` test(android-data): add Slice 1 repository mapping tests — 2026-06-02; red
- `a99cb75` feat(android-domain-data): add inventory domain models + repository over :network — 2026-06-02; `:domain` 2/2, `:data` 5/5, assembleDebug OK; Room deferred

## Phase 14 — Slice 1 Android UI (a3b) — DOD #1–#24 complete
- `da0eee0` test(android-inventory): add Slice 1 Compose UI tests (#21–#24) — 2026-06-02; red
- `a568a4d` feat(android-inventory): add add-plant/list/detail screens + nav (Slice 1 UI) — 2026-06-02; UI 4/4 (Robolectric), `:app:assembleDebug` OK. **Slice 1 DOD #1–#24 complete** (retro: `reviews/slice-1-retro.md`).

## Phase 15 — Slice 2 advisories (in progress)
- `5e77801` docs(slice-02): add Slice 2 plan + advisory schema-validation test (red) — 2026-06-02
- `06f581d` feat(schema): add Advisory shared schema (Slice 2 contract) — 2026-06-02; `npm test` 61/61
- `1077764` test(care-engine): add Slice 2 advisory-engine failing tests — 2026-06-02; red
- `4f3d76a` feat(care-engine): add deterministic advisory engine (Slice 2) — 2026-06-02; `npm test` 67/67
- `623c91f` test(api): add Slice 2 advisories-endpoint integration tests (red) — 2026-06-02; red
- `8d3e813` feat(api): add GET /plants/:id/advisories + seed ideal container range (Slice 2) — 2026-06-02; integration 25/25, all 5 `@slice-2` scenarios green
- `63440be` test(android-advisories): add Slice 2 advisory DTO/repo/UI tests — 2026-06-02; red
- `c4e4396` feat(android-advisories): surface plant advisories on the detail screen (Slice 2) ← **HEAD / origin/master** — 2026-06-02; **Slice 2 complete end-to-end** (retro: `reviews/slice-2-retro.md`)

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
- **2026-06-02** — a3a landed (`0f8c596`/`a99cb75`): `:domain`/`:data` repo over `:network`,
  `:domain` 2/2 + `:data` 5/5, assembleDebug OK, Room deferred. a3b (`0013-android-inventory-ui`:
  Compose add/list/detail + UI #21–#24) published, vision ALIGNED, in flight — closes Slice 1
  (#1–#24); then a one-page retro + owner decision on Slice 2.
- **2026-06-02** — a3b landed (`da0eee0`/`a568a4d`): Compose inventory UI + UI tests #21–#24
  (Robolectric 4/4), `:app:assembleDebug` OK. **Slice 1 DOD #1–#24 engineering-complete.**
  Loop **paused**; one-page retro written (`reviews/slice-1-retro.md`); owner to decide next
  (device-acceptance run / UX follow-ups / Slice 2 / CI). 13 handoffs, all green, no regressions.
- **2026-06-02** — Owner chose **Slice 2 (advisories)**. S2.0 published
  (`0014-slice2-foundation`: slice-02 plan + `advisory.schema.json` + red→green schema
  test), vision ALIGNED, in flight. Decomposition: S2.0 schema → S2.1 engine → S2.2 API →
  S2.3 Android. BDD: `features/container-health.feature` `@slice-2` (5 scenarios).
- **2026-06-02** — S2.0 landed (`5e77801`/`06f581d`): slice-02 plan + `advisory.schema.json`
  + schema test, `npm test` 61/61. S2.1 (`0015-advisory-engine`: deterministic
  `computeAdvisories`, 3 rules + invariant) published, vision ALIGNED, in flight. Surfaced a
  pre-existing broken gate: `npm run validate-schemas` red (ajv-cli lacks `ajv-formats`) —
  tracked, not blocking.
- **2026-06-02** — S2.1 landed (`1077764`/`4f3d76a`): deterministic `computeAdvisories`, npm
  test 67/67. S2.2 (`0016-advisories-api`: `GET /plants/:id/advisories` + migration 0004
  ideal-range + integration tests for the 5 `@slice-2` scenarios) published, vision ALIGNED,
  in flight; S2.3 = Android advisory display (closes Slice 2).
- **2026-06-02** — S2.2 landed (`623c91f`/`8d3e813`): `GET /plants/:id/advisories` + migration
  0004 ideal-range + seed; integration 25/25; all 5 `@slice-2` scenarios green. S2.3
  (`0017-android-advisories`: Android advisory display) published, vision ALIGNED, in flight —
  closes Slice 2.
- **2026-06-02** — S2.3 landed (`63440be`/`c4e4396`): Android advisory display, module + UI
  tests green, `:app:assembleDebug` OK. **Slice 2 (advisories) complete end-to-end** (engine
  + API + Android); all 5 `@slice-2` scenarios exercised. Loop **paused**; retro
  `reviews/slice-2-retro.md`. 17 handoffs across Slices 1–2, all green, no regressions. Owner
  to direct next (validate-schemas fix / device run / UX follow-ups / Slice 3).
- **2026-06-02** — Owner said **"do all"**: validate-schemas fix → UX follow-ups → e2e/device
  smoke → Slice 3. (1) published `0018-validate-schemas-fix` (in flight). Slice 3 will stop
  for Firebase/FCM creds; the on-device human acceptance stays with the owner.
- **2026-06-02** — `0018` ✅ landed (`392ba86`): `validate-schemas` green (ajv-formats +
  diagnosis-result `type:"array"`); 2 files, +2/−2; `npm test` 67/67. Verified vs real git.
  Item (3a) published `0019-list-endpoints` (in flight): read-only `GET /plant-profiles`
  (catalog) + `GET /garden-spaces`/`/containers` (RLS) + `toPlantProfile` mapper + integration
  tests, feeding the add-plant selectors. Vision-check ALIGNED.
- **2026-06-02** — `0019` ✅ landed (`c7b8c54`): 3 read-only list endpoints + `toPlantProfile` +
  `lists-api.integration.test.ts`; 3 files; integration 25→31, unit 67/67, validate-schemas
  green. Verified vs real git (read-only handlers, RLS lists rely on RLS, protected paths
  untouched). Item 3b (Android selectors) decomposed network→data→ui; published
  `0020-android-network-lists` (in flight): `:network` `PlantProfileDto` + 3 GET calls +
  networknt schema test. Vision-check ALIGNED.
- **2026-06-02** — `0020` **BLOCKED at gate**, not code: Android SDK (`~/Android/Sdk` →
  `/media/israel/Drive/...`), `~/.gradle`, `~/.npm` all dangling — the external Drive was
  **unmounted after the session restart** (same Drive-symlink class as the earlier npm/gradle
  blockers). Impl implemented the 4 `:network` files correctly but left them **uncommitted**
  (gate `:network:testDebugUnitTest` un-runnable), mounted nothing. Owner **re-mounted** the
  Drive (SDK resolves: android-34/35/36; caches restored). Re-issued as
  `0021-android-network-lists-rerun` (identical `:network` scope; baseline updated to expect the
  4 pre-existing uncommitted edits; run gate → commit). **Tripwire:** the Drive must be mounted
  before any Android (`gradlew`) or npm/npx step; it can drop on restart.
- **2026-06-02** — `0021` ✅ landed (`ce59e5e`): the `0020` `:network` edits gate-verified +
  committed (`:network` SchemaValidationTest 4→5, BUILD SUCCESSFUL). Only `android/network/**`;
  `local.properties` not committed. Verified vs real git. **NB:** `0021` added 3 abstract methods
  to `PlantAppApi` without updating the `:data` test double `FakePlantAppApi` →
  `:data:testDebugUnitTest` compile is **red** on `ce59e5e` (latent; the `0021` gate only ran
  `:network`). Published `0022-android-data-lists` (in flight) which fixes it red→green:
  `:domain` `PlantProfile` + 3 repo read methods, `:data` mapper/impl + `FakePlantAppApi` update
  + mapping test. Vision-check ALIGNED.
- **2026-06-02** — `0022` ✅ landed (`3fba718`): `:domain` `PlantProfile` + 3 repo read methods,
  `:data` mapper/impl + `FakePlantAppApi` overrides + 2 new mapping tests; `:data`
  InventoryRepositoryImplTest 7/7, `:domain` 2/2 (resolved `0021`'s latent `:data` compile-red).
  6 files, only `android/domain|data/**`. Verified vs real git. **Task-name note:** `:domain`
  is kotlin-jvm → `:domain:test` (not `:domain:testDebugUnitTest`). Published
  `0023-android-profile-dropdown` (3b-ui split a/b; in flight): replace add-plant Profile-id
  text field with a Material3 catalog dropdown (`getPlantProfiles()`) + `AddPlantViewModel` load
  + 1-line `:app` route wiring + Robolectric tests. Vision-check ALIGNED.
- **2026-06-02** — `0023` ✅ landed (`20f4e35`): add-plant Profile-id text field replaced by a
  Material3 catalog dropdown (`ExposedDropdownMenuBox`, `getPlantProfiles()`); `AddPlantViewModel`
  loads the catalog; `:app` route passes `profiles`. `InventoryScreensTest` 5/5 (updated #22/#24 +
  new dropdown test), `:app:assembleDebug` OK. 5 files, only `feature-inventory|app/**`. Verified
  vs real git (`FIELD_PROFILE_ID` removed). Published `0024-android-gardenspace-selector` (3b-ui-b;
  in flight): garden-space **select-or-create** (dropdown + inline create via
  `createGardenSpace(name,kind)`; create form name+kind only — no location). Vision-check ALIGNED.
- **2026-06-02** — `0024` ✅ landed (`5ce6f29`): add-plant Garden-space id field replaced by a
  select-or-create control (dropdown of `getGardenSpaces()` + inline create via
  `createGardenSpace`); `AddPlantViewModel` loads spaces + `createGardenSpace`; `:app` wiring.
  `InventoryScreensTest` 7/7 (updated #22/#24 + 2 new), assemble OK. 5 files, only
  `feature-inventory|app/**`. Verified vs real git (`FIELD_GARDEN_SPACE_ID` removed). Published
  `0025-android-container-selector` (3b-ui-c, final selector; in flight): container
  select-or-create + validation onto selection. After it lands, 3b is complete (add-plant fully
  selector-driven). Vision-check ALIGNED.
- **2026-06-02** — `0025` ✅ landed (`8d51874`): container select-or-create (dropdown of
  `getContainers()` + inline create via `createContainer`); container-required validation moved
  onto the selection. `InventoryScreensTest` 9/9, assemble OK. 5 files, only `feature-inventory|app/**`.
  Verified vs real git (all 3 raw-id fields removed). **3b (Android add-plant selectors) COMPLETE
  — profile (0023) + garden-space (0024) + container (0025), form fully selector-driven.** Next =
  3c sign-in; paused to ask the owner the auth approach (token plumbing already exists:
  `SettingsStore.setToken`→`AuthTokenProvider`→OkHttp; missing = a sign-in UI that obtains a token;
  needs the Supabase anon key + auth URL on device).
- **2026-06-02** — Owner chose **email-OTP-code** sign-in. `0026` ✅ landed (`a2f5e75`): `:network`
  Supabase GoTrue auth client — `AuthDtos` (`@SerialName` snake_case), `SupabaseAuthApi`
  (otp+verify), `SupabaseAuthApiFactory` (public anon `apikey` header, BASIC logging no PII, auth
  `Json` encodeDefaults=true). `AuthDtoTest` 3/3. 4 new files, only `android/network/**`; no
  key/URL hard-coded. Verified vs real git. Published `0027-android-auth-data` (3c-data; in
  flight): `:domain` `AuthRepository` + `:data` impl persisting token via `SettingsStore.setToken`
  (`TokenWriter` seam) + DI/config (auth URL + public local anon key from `npx supabase status`).
  Vision-check ALIGNED-WITH-NOTES (secrets-safe: public anon key only; service_role never touched).
- **2026-06-02** — `0027` ✅ landed (`28f69ea`): `:domain` `AuthRepository` + `:data`
  `AuthRepositoryImpl` (verify → `SettingsStore.setToken` via `TokenWriter` seam) + DI/config
  (`DEFAULT_AUTH_BASE_URL` 10.0.2.2:54321 + `DEFAULT_ANON_KEY` = public local-dev anon JWT). `:data`
  8→10, `:domain` 2. 5 files, only `domain|data/**`. Verified vs real git — **committed JWT decodes
  `role=anon`/`iss=supabase-demo` (NOT service_role)**, local.properties not committed. Published
  `0028-android-signin-ui` (3c-ui; in flight): stateless `SignInScreen` + `SignInViewModel` over
  `AuthRepository` + `:app` token-gating + Robolectric tests. Vision ALIGNED-WITH-NOTES (sign-in in
  `:feature-inventory` = tracked structural debt; migrate to `:feature-auth` later).
- **2026-06-02** — `0028` ✅ landed (`e76ff8d`): email-OTP `SignInScreen` + `SignInViewModel` over
  `AuthRepository` + `:app` token-gating (`tokenBlocking()`→start dest; verify→nav to list).
  `:feature-inventory` 11→14, `:app:assembleDebug` OK. 6 files, only `feature-inventory|app/**`.
  Verified vs real git. **3c (sign-in) COMPLETE.** Next = 3d advisory→accept→CareTask (grounded:
  care-task schema already allows `repot`/`support` kinds; plan = pure `computeTaskFromAdvisory`
  engine fn [container-size→repot, support→support; pollination unsupported] → accept endpoint
  [explicit user action; GET still creates nothing] → Android accept action; decomposed
  engine→api→android).
- **2026-06-02** — `0029` ✅ landed (`e4ffe4b`): pure deterministic `computeTaskFromAdvisory`
  (care-engine; container-size→repot, support→support, pollination/other throws; priority from
  severity; dueAt=clockUtc; `inputsHash`=sha256(canonicalJson({kind,sourceInputs})); output
  schema-valid). 2 new files; `index.ts`/`advisories.ts` untouched; `npm test` 67→72. Verified vs
  real git (pure — Date.now/random only in a comment; not endpoint-wired). Published
  `0030-api-advisory-accept` (3d-api; in flight): `POST /plants/:id/advisories/accept {kind}` →
  recompute advisories (RLS 404), match applicable (400 if absent/unsupported), engine → persist
  one care_tasks row → return CareTask; tests assert GET-creates-nothing invariant. Vision ALIGNED
  (reviewer verified columns/RLS vs real repo; closes the `0016` no-CareTask DB-assert follow-up).
- **2026-06-02** — `0030` ✅ landed (`53d093e`): `POST /plants/:id/advisories/accept {kind}` →
  recompute advisories (RLS 404), match applicable (400 if absent/unsupported), engine → persist
  one care_tasks row → 201 `toCareTask`. 2 files (app.ts + new integration test). `test:int` 31→35
  incl. GET-creates-nothing assertion; `npm test` 72. Verified vs real git (GET-advisories handler
  334–411 has no insert; only insert is inside the accept handler). Published
  `0031-android-accept-netdata` (3d-android net+data; in flight): `:network` `acceptAdvisory` +
  `AcceptAdvisoryRequest` + `:domain`/`:data` repo method + `FakePlantAppApi` update + tests
  (net+data combined to avoid the interface-break). Vision ALIGNED (D-09: client holds no care
  logic; task server-computed/opaque). After 3d-android-ui, backlog (3) complete.
- **2026-06-02** — `0031` ✅ landed (`bfdd946`): `:network` `acceptAdvisory` + `AcceptAdvisoryRequest`,
  `:domain` port, `:data` impl + `FakePlantAppApi` override + tests. `:network` 16→17, `:data`
  10→11, `:domain` 2. 7 files, only `network|domain|data/**`. Verified vs real git. Published
  `0032-android-accept-ui` (final 3d step; in flight): per-advisory Accept button on
  `PlantDetailScreen` (container-size/support only) → `PlantDetailViewModel.accept` →
  `acceptAdvisory` → reload + `:app` wiring + Robolectric tests. Vision ALIGNED. **After it,
  backlog (3) UX follow-ups COMPLETE.**
- **2026-06-02** — `0032` ✅ landed (`d1bda81`): per-advisory **Accept** button on
  `PlantDetailScreen` (container-size/support only; not pollination) → `PlantDetailViewModel.accept`
  → `acceptAdvisory` → reload; `:app` DETAIL route wires `onAccept`. `:feature-inventory` 14→16,
  assemble OK. 5 files, only `feature-inventory|app/**`. Verified vs real git. **🎉 Backlog (3) UX
  follow-ups COMPLETE** (selector-driven add-plant · email-OTP sign-in + gating ·
  advisory→accept→CareTask e2e: engine→API→:network/:data→detail Accept). **Paused for owner
  decision on (2) e2e smoke approach.** Grounding: no instrumented-test scaffolding yet; emulator +
  system-images (30/34/37) + AVD `Babage_Pixel` are available, so a real `connectedAndroidTest` is
  feasible (heavy) — vs a JVM/Robolectric NavHost smoke vs deferring to the owner's manual device run.
- **2026-06-02** — Owner chose the **Robolectric NavHost smoke** for (2). Published
  `0033-navhost-smoke` (in flight): test-only `:feature-inventory` Robolectric test driving a
  mirrored `NavController`/`NavHost` over the real screens + ViewModels built from fake
  `InventoryRepository`/`AuthRepository` (no Hilt-test/emulator/backend) — gated journey
  sign-in→list→detail→accept (+ add); adds `navigation-compose` testImpl + a guard comment that
  the test mirrors `MainActivity`'s graph. Vision ALIGNED-WITH-NOTES (test-only; D-09 safe).
  After it, only **(4) Slice 3** remains.
- **2026-06-02** — `0033` ✅ landed (`da020e3`), **test-only**: Robolectric `NavSmokeTest` +
  `NavSmokeFakes` in `:feature-inventory` — mirrored NavHost over real screens+VMs with fake repos;
  gated sign-in→list→detail→accept. `:feature-inventory` 16→18; only feature-inventory test sources
  + 1 testImpl dep; no `src/main`. Verified vs real git. **🎉 Backlog (1)+(2)+(3) COMPLETE.**
  **Slice 3 STARTED** — published `0034-slice3-opener` (in flight): `docs/slice-03-reminders-plan.md`
  + pure deterministic `computeReminders` in `:domain` (red-first). Vision ALIGNED-WITH-NOTES
  (D-09 honored — delivery timing on-device, care computation backend; ratified as D-13-style in
  the doc; FCM STOP gate preserved; no permission/dep yet). Next: WorkManager local notification
  path (new deps + `POST_NOTIFICATIONS`) → app-open scheduling → STOP for owner Firebase/FCM.
- **2026-06-02** — `0034` ✅ landed (`79944a5`): `docs/slice-03-reminders-plan.md` (scope + STOP
  gates + **D-13** ratified) + pure deterministic `computeReminders` in `:domain` (`ReminderSpec`;
  filters pending, stale-window, lead time; no `Instant.now`/random). `:domain` 2→9. 3 files
  (doc + `:domain`). Verified vs real git (pure; `Instant.now` only in a comment). Published
  `0035-workmanager-local-reminders` (Slice 3 step 2; in flight): `ReminderWorker` +
  `ReminderScheduler` + WorkManager dep + `POST_NOTIFICATIONS` + channel; Robolectric scheduling
  tests. Vision ALIGNED (cited ChatHistory lines 1/167-168/175/177/556) + **no-mutation guardian
  PASS**. Local-only; FCM STOP gate intact; runtime-perm UI + app-open wiring deferred to next.
- **2026-06-02** — `0035` ✅ landed (`6f6f58b`): WorkManager **local** plumbing — `ReminderScheduler`
  (unique delayed work/task) + `ReminderWorker` (inputData-driven, permission-guarded post) +
  WorkManager 2.9.1 dep + `POST_NOTIFICATIONS` + channel; Robolectric `WorkManagerTestInitHelper`
  scheduling tests. `:data` 11→14. 7 files (libs + `:data` + `:app` manifest). Verified vs real git
  (scoped; only "FCM" hit is an absence-comment; no google-services). Published
  `0036-reminder-sync-appopen` (Slice 3 step 3; in flight): `ReminderSync` coordinator (pending
  tasks across plants → `computeReminders` → schedule) + `ReminderScheduling` seam + `Clock` +
  `PlantListViewModel` fire-and-forget trigger + test. Vision ALIGNED. Local-only. **Next = runtime
  `POST_NOTIFICATIONS` UI → STOP for owner Firebase/FCM.**
- **2026-06-02** — `0036` ✅ landed (`e8aaeec`): `ReminderSync` (pending tasks across plants →
  `computeReminders` → `ReminderScheduler.schedule`) + `ReminderScheduling` seam + `Clock` +
  `PlantListViewModel` fire-and-forget app-open trigger; `ReminderSyncTest` (fixed clock, only
  pending scheduled). `:data` 14→15; `:feature-inventory` 18 (NavSmoke updated for the new VM ctor
  param). 7 files (`:data`+`:feature-inventory`). Verified vs real git (no FCM). Published
  `0037-post-notifications-permission` (Slice 3 step 4, last LOCAL; in flight): runtime
  `POST_NOTIFICATIONS` request (Android 13+) via Compose `RequestPermission` launcher in the LIST
  route + pure `NotificationPermission.shouldRequest` helper + test. Vision ALIGNED. **After it →
  STOP and ask owner for Firebase/FCM setup (project + google-services.json).**
- **2026-06-02** — `0037` ✅ landed (`369f2f0`): runtime `POST_NOTIFICATIONS` request — pure
  `NotificationPermission.shouldRequest(sdkInt, granted)` helper + Compose `RequestPermission`
  launcher in MainActivity's LIST route. `:feature-inventory` 18→22; assemble OK. 3 files
  (`:feature-inventory`+`:app`); no FCM. Verified vs real git. **✅ LOCAL Slice 3 reminder path
  COMPLETE** (computeReminders → WorkManager scheduling → app-open sync → runtime permission).
  **⏸ Loop PAUSED at the FCM STOP gate — asked the owner** (proceed with FCM [needs Firebase project
  + google-services.json + backend FCM sender + token registration] vs defer / mark Slice 3 done at
  local). **"Do all" backlog (1)(2)(3)(4) all delivered except the owner-gated FCM remainder.**
