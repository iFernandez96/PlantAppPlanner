# DONE — handoff 0011-android-network (a2, two commits red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** `:network` module built — kotlinx.serialization camelCase DTOs + Retrofit
client for the Slice 1 endpoints — with JVM unit tests (round-trip + D-06 schema
validation) green; `:app:assembleDebug` still succeeds.
Final `origin/master` = `f6c8155ac6618e493d46c82d53ea9c8021d83161`.

## Baseline precondition — matched
- HEAD = `678a488baa899703fc75407201f75cc9a8623062` == origin/master; clean.
- Built/tested with `GRADLE_USER_HOME=/tmp/plantapp-gradle-home` (avoids the slow
  external-Drive `~/.gradle`); no concurrent gradlew runs.

## Commit 1 (RED) — `test(android-network): add Slice 1 DTO + schema-validation tests`
- Hash: `e69f6a0`
- Version catalog (`android/gradle/libs.versions.toml`): added test-only entries — junit
  4.13.2, kotlin-test-junit, kotlinx-coroutines-test, networknt json-schema-validator
  1.5.4, jackson-databind 2.18.2.
- `android/network/build.gradle.kts`: `testOptions { unitTests.all { useJUnit() } }` +
  testImplementation(junit, kotlin-test-junit, coroutines-test, networknt, jackson).
- Tests under `android/network/src/test/kotlin/dev/plantapp/network/`:
  `TestSupport.kt` (Json config; `validateAgainstSchema` via networknt 2020-12; schema
  file resolver), `DtoFixtures.kt` (schema-valid fixtures), `DtoSerializationTest.kt`
  (round-trip + absent-optional omission), `SchemaValidationTest.kt` (D-06 validation).
- `:network:testDebugUnitTest` (RED): compile failure — DTO classes unresolved
  (`AddPlantResponse`, `AddPlantRequest`, etc.). The new test deps resolved fine (no
  dependency errors); only the missing DTOs failed. Intended red.
- `git show --stat`: 6 files, +225. Pushed `678a488..e69f6a0`.

## Commit 2 (GREEN) — `feat(android-network): add Slice 1 Retrofit DTOs + API client`
- Hash: `f6c8155`
- `android/network/src/main/kotlin/dev/plantapp/network/`:
  - `Dtos.kt` — `@Serializable` camelCase DTOs: `GardenSpaceDto`, `ContainerDto`,
    `PlantInstanceDto`, `SourceInputsDto`, `CareTaskDto`, request bodies
    `CreateGardenSpaceRequest`/`CreateContainerRequest`/`AddPlantRequest`, and
    `AddPlantResponse { plant, task }`. Optional fields nullable+default null.
  - `PlantAppApi.kt` — Retrofit interface: `POST /garden-spaces`, `POST /containers`,
    `POST /plants`, `GET /plants`, `GET /plants/{id}`, `GET /plants/{id}/tasks`,
    `DELETE /plants/{id}` (suspend; delete returns `Response<Unit>`).
  - `PlantAppApiFactory.kt` — Retrofit + OkHttp + the **Square**
    `converter-kotlinx-serialization` (`Json.asConverterFactory`, package
    `retrofit2.converter.kotlinx.serialization`), configurable `baseUrl`, a
    `fun interface AuthTokenProvider` bearer interceptor, and a BASIC logging
    interceptor (request line + status only — no bodies/PII). `Json { encodeDefaults =
    false; explicitNulls = false; ignoreUnknownKeys = true }`.
  - Removed the now-redundant `src/main/kotlin/.gitkeep`.
- Also fixed one latent test-file compile bug (carried from the red commit): the
  `SchemaValidationTest` KDoc contained `shared-schemas/*.schema.json`, whose `/*`
  opened a Kotlin **nested** block comment and left the KDoc unclosed — reworded to
  "schema under shared-schemas" (minor test-file fix; permitted).
- `:network:testDebugUnitTest` → **BUILD SUCCESSFUL**: DtoSerializationTest 6/6,
  SchemaValidationTest 4/4 (10 tests, 0 failures). All four DTO fixtures validate against
  their shared schema via networknt 2020-12.
- `:app:assembleDebug` → **BUILD SUCCESSFUL** with `:network` now populated.
- `git show --stat`: 5 files (3 new DTO/API sources, the .gitkeep deletion, the 1-line
  test comment fix), +221/−1. Pushed `e69f6a0..f6c8155`.

## How schema files are resolved in tests
`TestSupport.sharedSchemaFile(name)` walks up from `System.getProperty("user.dir")`
until it finds the repo-root `shared-schemas/` directory, then reads
`shared-schemas/<name>.schema.json` directly (no copy into test resources — single
source of truth, no drift).

## Catalog deps added (test-only)
junit 4.13.2, kotlin-test-junit (Kotlin 2.1.0), kotlinx-coroutines-test,
networknt json-schema-validator 1.5.4, jackson-databind 2.18.2. **No new production
deps** — production uses the existing Retrofit 2.11 / OkHttp 4.12 / kotlinx-serialization
1.7.3 stack.

## Compliance
- No forbidden deps: no CameraX, Firebase/FCM, WorkManager, AI/LLM SDK, Ktor, or
  `:care-engine` module. No Compose/UI code (that's a3).
- Only `:network` + the version catalog touched. `backend/**`, `shared-schemas/**`,
  `supabase/**`, and other Android modules' source UNCHANGED (`git diff --quiet HEAD`).

## Commit hashes + titles
1. `e69f6a0` — test(android-network): add Slice 1 DTO + schema-validation tests
2. `f6c8155` — feat(android-network): add Slice 1 Retrofit DTOs + API client

Final `origin/master` SHA: `f6c8155ac6618e493d46c82d53ea9c8021d83161`

## Next (a3, per planner follow-up)
`:domain` models/use-cases + `:data` repository (DTO↔domain, DataStore for base URL/token)
and `:feature-inventory` Compose screens (add-plant form, list, detail showing the water
task) + Hilt + navigation + Compose UI tests #21–#24 (Robolectric-first).

## Note for a3 (build harness)
Use `GRADLE_USER_HOME=/tmp/plantapp-gradle-home` for all gradlew runs and avoid
concurrent invocations (the default `~/.gradle` is a slow external-Drive symlink). There
is a harmless nullable-smartcast **warning** in `TestSupport.kt` (`requireNotNull(dir)`);
left as-is (warning only; build green).
