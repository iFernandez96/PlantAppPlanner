# Next Implementation Prompt — backlog (3b-data): `:domain` PlantProfile + `:data` repository list methods

**Backlog item (3) UX follow-ups, step 3b — part 2 of 3 (data/domain layer).** Expose the three
`:network` list calls landed in `0021` (`getPlantProfiles`/`getGardenSpaces`/`getContainers`) to
the app through the `:domain` `InventoryRepository` port + `:data` implementation, and add a
`PlantProfile` domain model for the profile dropdown. This is the layer the add-plant selectors
(3b-ui, next handoff) consume. **No `:feature-inventory`, no UI, no `:app`** — those are 3b-ui.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`ce59e5e416faa64f1da07505372e0aa043960e6a` == `origin/master`, clean. `:network` has
`PlantProfileDto` + `getPlantProfiles()/getGardenSpaces()/getContainers()` (from `0021`).
`:domain` has `InventoryRepository` + models (`GardenSpace`, `Container`, `Plant`, `CareTask`,
`Advisory`, …) but **no `PlantProfile`** and **no list methods for profiles/spaces/containers**.
`:data` has `InventoryRepositoryImpl` + `DtoMappers` + a hand-written `FakePlantAppApi` test
double.

**Expected RED at baseline (this is the red-first state to fix):** `0021` added three abstract
methods to `PlantAppApi`, but the test double `FakePlantAppApi : PlantAppApi`
(`android/data/src/test/.../FakePlantAppApi.kt`) was not updated, so it no longer satisfies the
interface — **`:data:testDebugUnitTest` currently fails to compile**. This handoff turns it green
by implementing the data/domain layer and updating the fake.

Single logical change (the data/domain layer for the list endpoints) → one commit. Red→green.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the
`:domain`/`:data` layer for the three list endpoints. The Drive is mounted (SDK resolves).

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect ce59e5e416faa64f1da07505372e0aa043960e6a == origin/master
git status --short                          # expect empty (the git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`android/domain/src/main/kotlin/dev/plantapp/domain/model/InventoryModels.kt`** — add a
   lean, selector-facing model (no nested care profiles; the dropdown only needs identity +
   label + grouping):
   ```kotlin
   /** Catalog entry for the add-plant profile selector. Subset of plant-profile.schema.json;
    *  the deterministic care fields stay backend-side (D-09). */
   data class PlantProfile(
       val id: String,
       val scientificName: String,
       val commonNames: List<String>,
       val category: String,
   )
   ```
2. **`android/domain/src/main/kotlin/dev/plantapp/domain/repository/InventoryRepository.kt`** —
   add three read methods:
   ```kotlin
   suspend fun getPlantProfiles(): List<PlantProfile>
   suspend fun getGardenSpaces(): List<GardenSpace>
   suspend fun getContainers(): List<Container>
   ```
   (import `dev.plantapp.domain.model.PlantProfile`).
3. **`android/data/src/main/kotlin/dev/plantapp/data/mapper/DtoMappers.kt`** — add
   `fun PlantProfileDto.toDomain(): PlantProfile = PlantProfile(id = id, scientificName =
   scientificName, commonNames = commonNames, category = category)` (drops the nested jsonb
   profiles — Android doesn't need them). Import `PlantProfileDto` + `PlantProfile`.
4. **`android/data/src/main/kotlin/dev/plantapp/data/repository/InventoryRepositoryImpl.kt`** —
   implement the three methods over the api, mirroring the existing `getPlants()` style:
   ```kotlin
   override suspend fun getPlantProfiles(): List<PlantProfile> = api.getPlantProfiles().map { it.toDomain() }
   override suspend fun getGardenSpaces(): List<GardenSpace> = api.getGardenSpaces().map { it.toDomain() }
   override suspend fun getContainers(): List<Container> = api.getContainers().map { it.toDomain() }
   ```

### Tests
- **`android/data/src/test/kotlin/dev/plantapp/data/FakePlantAppApi.kt`** — add a
  `plantProfile: PlantProfileDto` canned value (a valid `PlantProfileDto`; reuse the
  `0021` fixture shape — id `"solanum-lycopersicum"`, the five nested `*Profile` `JsonObject`s,
  `version = 1`), and implement the three new overrides:
  `override suspend fun getPlantProfiles() = listOf(plantProfile)`,
  `override suspend fun getGardenSpaces() = listOf(gardenSpace)`,
  `override suspend fun getContainers() = listOf(container)`. This is what makes
  `:data:testDebugUnitTest` compile again.
- **`InventoryRepositoryImplTest.kt`** — add a test asserting the three list methods map to
  domain: `getPlantProfiles()` returns one `PlantProfile` with `id == "solanum-lycopersicum"`
  and non-empty `commonNames`; `getGardenSpaces()`/`getContainers()` return the fake's row mapped
  to domain (`id`/`kind`/`volumeLiters` as appropriate).

### Forbidden
- No change to `:network` (already landed), `:feature-inventory`, `:app`, or any backend/
  `shared-schemas`/`supabase` file. No UI. No new dependency. No on-device care logic — keep
  `CareTask`/care fields backend-only (D-09); `PlantProfile` carries no care profile. No
  camera/photos/GPS/notifications/AI. Don't mount/repoint the SDK/Drive; don't commit
  `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :domain:testDebugUnitTest :data:testDebugUnitTest
```
Red→green: at baseline `:data:testDebugUnitTest` fails to compile (`FakePlantAppApi` doesn't
implement the 3 new `PlantAppApi` methods). After this change both modules' unit tests pass —
the new repository-list mapping test green, all prior `:domain`/`:data` tests still green. Report
the counts + the new test name.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/domain/ android/data/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-data): PlantProfile domain model + repository list methods"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The `PlantProfile` model, the 3 interface methods, the mapper, the impl methods, and the
   `FakePlantAppApi` update.
2. `:domain`/`:data` test results (counts before→after; the prior `:data` compile-red → green;
   new test green).
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/domain/**` + `android/data/**` files changed (not `local.properties`).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `android/domain/**`+`android/data/**`; `:data` compile-red resolved;
both module tests green). Then **3b-ui**: `:feature-inventory` add-plant **selectors** — profile
dropdown sourced from `getPlantProfiles()`; garden-space/container **select-or-create** sourced
from `getGardenSpaces()`/`getContainers()` — replacing the raw id text fields, + ViewModel wiring
+ Compose UI tests (Robolectric). Then 3c (magic-link sign-in → DataStore token), 3d
(advisory→accept→CareTask, routed through the engine). Then (2) emulator e2e smoke; then (4)
Slice 3 (WorkManager local first; STOP for owner Firebase/FCM setup). Vision-check each
product-surface step.
