# Next Implementation Prompt — a2: Android :network layer (Retrofit DTOs + schema-validated)

**Milestone a (Android UI), step a2.** Build the `:network` module — kotlinx.serialization
DTOs (camelCase, matching the now-conformant API + `shared-schemas/*`) + a Retrofit client
for the Slice 1 endpoints — with JVM unit tests that validate the DTOs against the shared
schemas (D-06). No Compose/UI yet (that's a3). Per D-02: **Retrofit + OkHttp +
kotlinx.serialization** (not Ktor).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `678a488` == `origin/master`,
clean. API responses conform to camelCase `shared-schemas/*` (Ajv-validated). Android
skeleton assembles (`:app:assembleDebug` OK; Gradle 8.11.1 wrapper committed). Build with
`GRADLE_USER_HOME=/tmp/plantapp-gradle-home` (`~/.gradle` is on the slow external Drive).
The `:network` module stack is in `android/gradle/libs.versions.toml` (Retrofit 2.11,
OkHttp 4.12, kotlinx-serialization 1.7.3).

Two commits: (1) red `:network` tests; (2) green DTOs + Retrofit API.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Build the
Android `:network` module's Slice 1 DTOs + Retrofit API, proven by JVM unit tests that
validate the DTOs against `shared-schemas/*` (D-06). **Consult the official Retrofit,
OkHttp, kotlinx.serialization, and networknt/json-schema-validator docs.** Build/test with
`GRADLE_USER_HOME=/tmp/plantapp-gradle-home` and avoid concurrent `./gradlew` runs.

### Baseline precondition (STOP if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect 678a488baa899703fc75407201f75cc9a8623062
git status --short                         # expect empty
```

### Scope — `android/network/` only
- **DTOs** (`@Serializable`, kotlinx.serialization, **camelCase** matching the API +
  `shared-schemas/*`):
  - `AddPlantRequest` { profileId, containerId, gardenSpaceId, growthStage,
    lastWateredAt?, nickname?, cultivar?, placement? }
  - `GardenSpaceDto` / `CreateGardenSpaceRequest`, `ContainerDto` / `CreateContainerRequest`
    (fields per `garden-space.schema.json` / `container.schema.json`; optional fields
    nullable + omitted when absent — use `encodeDefaults=false`).
  - `PlantInstanceDto` (per `plant-instance.schema.json`), `CareTaskDto` (+ nested
    `SourceInputsDto`) (per `care-task.schema.json`), `AddPlantResponse { plant:
    PlantInstanceDto, task: CareTaskDto }`.
- **Retrofit API** `PlantAppApi`: `POST /garden-spaces`, `POST /containers`, `POST /plants`,
  `GET /plants`, `GET /plants/{id}`, `GET /plants/{id}/tasks`, `DELETE /plants/{id}`.
- **Client factory**: Retrofit + OkHttp + the kotlinx.serialization converter (D-02), a
  configurable base URL, and a bearer-token auth header (OkHttp interceptor or `@Header`).
  A logging interceptor is fine (no PII/bodies in production logging).
- Keep it a clean module API (`:domain`/`:data`/`:feature-inventory` will consume it in a3).

### Tests — `android/network/src/test/` (JVM unit; no emulator)
- kotlinx.serialization **round-trip** for each DTO (encode→decode equality).
- **D-06 schema validation:** serialize a representative `CareTaskDto`, `PlantInstanceDto`,
  `GardenSpaceDto`, `ContainerDto` to JSON and validate each against the matching
  `shared-schemas/*.schema.json` using **networknt/json-schema-validator** (2020-12).
  Resolve the schema files from the repo (`shared-schemas/` is at the repo root — read via
  a relative path from the module, or copy into `src/test/resources/`). Use fixtures whose
  values satisfy the schemas (uuids where `format: uuid`, ISO date-times, `engineVersion`
  `^d+.d+.d+$`, `inputsHash` length ≥ 8, etc.).
- Add the needed **test** deps to `android/gradle/libs.versions.toml` (networknt
  json-schema-validator; a JSON lib for it if required; kotlin-test/junit). No new
  *production* deps beyond the catalog's Retrofit/OkHttp/kotlinx stack.

### Forbidden
- No CameraX, Firebase/FCM, WorkManager, any AI/LLM SDK, Ktor, or a `:care-engine` Android
  module (Slice 1 exclusions; D-02/D-09/D-11/D-12). No Compose/UI code (that's a3).
- Don't touch `backend/**`, `shared-schemas/**`, `supabase/**`, or other Android modules'
  source (only `:network` + the version catalog).

### Verify (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest --no-daemon
```
Red-first: write the DTO/serialization/schema-validation tests first (compile/red — DTOs
don't exist), then implement DTOs + API → green. Confirm `:app:assembleDebug` still
succeeds. If networknt can't load a 2020-12 schema or a DTO can't be made schema-valid,
STOP and report (real finding).

### Commits
1. `test(android-network): add Slice 1 DTO + schema-validation tests` (RED)
2. `feat(android-network): add Slice 1 Retrofit DTOs + API client` (GREEN)
Push after each.

### Final report
1. Commit hashes + titles; final `origin/master` SHA.
2. `:network:testDebugUnitTest` RED→GREEN counts; confirm `:app:assembleDebug` still OK.
3. `git show --stat` per commit; the DTO/API files + catalog deps added; confirm no
   forbidden deps, no Compose, no `backend/**` changes.
4. How the schema files were resolved in tests (relative path vs test resources).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after a2 lands
Verify `:network` tests green (incl. schema validation) + skeleton still assembles. Then
**a3**: `:domain` models/use-cases + `:data` repository (maps DTO↔domain; DataStore for
base URL/token) and `:feature-inventory` Compose screens (add-plant form, list, detail
showing the water task with rationale/engineVersion/dueAt) + Hilt + navigation + Compose
UI tests #21–#24 (Robolectric-first). Decompose a3 (data/domain → screens → tests).
Vision-check a3 for real (UX/product surface).
