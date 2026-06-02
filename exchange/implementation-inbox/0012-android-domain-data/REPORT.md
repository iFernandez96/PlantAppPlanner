# DONE — handoff 0012-android-domain-data (a3a, two commits red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** `:domain` (pure-Kotlin inventory models + repository port) and `:data`
(repository impl over `:network`, DTO↔domain mappers, DataStore settings, Hilt module)
built; JVM tests green; `:app:assembleDebug` still succeeds. No Compose/UI, no Room, no
care logic on device.
Final `origin/master` = `a99cb755ecdbb76463e394b914a395a2916dcdbf`.

## Baseline precondition — matched
- HEAD = `f6c8155ac6618e493d46c82d53ea9c8021d83161` == origin/master; clean.
- All gradlew runs used `GRADLE_USER_HOME=/tmp/plantapp-gradle-home`; no concurrent runs.

## Commit 1 (RED) — `test(android-data): add Slice 1 repository mapping tests`
- Hash: `0f8c596`
- `:domain` + `:data` build.gradle: added test deps (junit, kotlin-test-junit,
  kotlinx-coroutines-test; `:data` also `testImplementation`/`implementation(libs.retrofit)`
  for `retrofit2.Response`); `:data` `testOptions { unitTests.all { useJUnit() } }`.
  Removed unused Room deps from `:data` (Room deferred per the prompt; not added back).
- Tests: `:data` `FakePlantAppApi` (hand-written fake of the `:network` `PlantAppApi`)
  + `InventoryRepositoryImplTest` (addPlant request+response mapping, getPlants/
  getPlantTasks list mapping, createGardenSpace/createContainer, deletePlant calls API);
  `:domain` `InventoryModelsTest` (model defaults).
- `./gradlew :domain:test :data:testDebugUnitTest` (RED): compile failure — domain models
  (`NewPlant`/`Plant`/`CareTask`/`AddPlantResult`) and `InventoryRepositoryImpl` don't
  exist yet. Intended red.
- `git show --stat`: 5 files, +231. Pushed `f6c8155..0f8c596`.

## Commit 2 (GREEN) — `feat(android-domain-data): add inventory domain models + repository over :network`
- Hash: `a99cb75`
- `:domain` (pure Kotlin, no Android/serialization):
  - `model/InventoryModels.kt` — `GardenSpace`, `Container`, `NewPlant`, `Plant`,
    `CareTask` (opaque backend value), `AddPlantResult`.
  - `repository/InventoryRepository.kt` — the port (suspend ops).
- `:data` (android-library):
  - `mapper/DtoMappers.kt` — `:network` DTO→domain (`toDomain`) + `NewPlant.toRequest()`.
  - `repository/InventoryRepositoryImpl.kt` — implements the port via `PlantAppApi`,
    maps both directions; `deletePlant` checks `response.isSuccessful`.
  - `settings/SettingsStore.kt` — Preferences DataStore for API base URL + auth token
    (suspend setters; blocking reads for the Retrofit client / interceptor). No secrets.
  - `di/DataModule.kt` — Hilt `@Module @InstallIn(SingletonComponent)`: provides
    `DataStore`, `AuthTokenProvider` (reads token from `SettingsStore`), `PlantAppApi`
    (via `:network` `PlantAppApiFactory`, base URL from `SettingsStore` default
    `http://10.0.2.2:54321/` — emulator→host Supabase), and binds
    `InventoryRepository`→`InventoryRepositoryImpl`.
  - Removed the redundant `.gitkeep` placeholders in `:domain`/`:data` main.
- Fixed a missing import in the (commit-1) `InventoryRepositoryImplTest`
  (`dev.plantapp.data.repository.InventoryRepositoryImpl`) — test intent unchanged.
- `./gradlew :domain:test :data:testDebugUnitTest` → **BUILD SUCCESSFUL**: `:domain` 2/2,
  `:data` 5/5 (0 failures). `:app:assembleDebug` → **BUILD SUCCESSFUL** (Hilt/KSP wiring
  through `:data` compiles).
- `git show --stat`: 9 files, +297. Pushed `0f8c596..a99cb75`.

## Repository port + base URL/token flow (for a3b)
Port `InventoryRepository`: `createGardenSpace(name, kind)`, `createContainer(name?,
volumeLiters, material, drainage)`, `addPlant(NewPlant): AddPlantResult`, `getPlants():
List<Plant>`, `getPlantTasks(plantId): List<CareTask>`, `deletePlant(plantId)`.
Auth/base-URL flow: `SettingsStore` (DataStore) holds `api_base_url` + `auth_token`. Hilt
provides an `AuthTokenProvider { settings.tokenBlocking() }` to the `:network` factory
(injected into the OkHttp Authorization header) and builds `PlantAppApi` with
`settings.baseUrlBlocking(DEFAULT_BASE_URL)`. a3b's ViewModels inject
`InventoryRepository`; sign-in (later) calls `settings.setToken(...)`.

## Compliance
- No Compose/UI/ViewModels (a3b). No Room (deferred — removed unused Room deps from
  `:data`). No CameraX/FCM/WorkManager/AI/Ktor/`:care-engine`. No care-scheduling logic on
  device (CareTask is opaque). No new production deps beyond the existing catalog
  (retrofit added to `:data` from the catalog for Response handling).
- `backend/**`, `shared-schemas/**`, `supabase/**`, `:network` source, and
  `:feature-inventory` UNCHANGED (`git diff --quiet HEAD`).

## Commit hashes + titles
1. `0f8c596` — test(android-data): add Slice 1 repository mapping tests
2. `a99cb75` — feat(android-domain-data): add inventory domain models + repository over :network

Final `origin/master` SHA: `a99cb755ecdbb76463e394b914a395a2916dcdbf`

## Next (a3b — closes Slice 1)
`:feature-inventory` Compose screens (add-plant form, list, detail showing the water task:
rationale, engineVersion badge, formatted dueAt) + Hilt ViewModels + navigation wired to
`InventoryRepository`, + Compose UI tests #21–#24 (Robolectric-first). Use
`GRADLE_USER_HOME=/tmp/plantapp-gradle-home`.
