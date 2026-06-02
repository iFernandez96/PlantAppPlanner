# DONE — handoff 0022-android-data-lists (3b-data, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** `:domain` `PlantProfile` model + `:data` repository list methods over the
`0021` `:network` calls. The baseline `:data` compile-red (FakePlantAppApi missing the 3
new `PlantAppApi` overrides) is resolved; `:domain` + `:data` unit tests green.
Final `origin/master` = `3fba7184c52e87861dc222d4c42ecd11b9d36003`.

## Baseline + unblock
- HEAD at start = `ce59e5e416faa64f1da07505372e0aa043960e6a` == origin/master; clean.
- SDK resolves (`~/Android/Sdk/platforms` → android-34/35/36/36.1; Drive mounted).

## Scope (changes)
- `:domain` `model/InventoryModels.kt` — `PlantProfile(id, scientificName, commonNames,
  category)` (selector-facing subset; no care profiles — D-09 keeps care fields backend-side).
- `:domain` `repository/InventoryRepository.kt` — added `getPlantProfiles(): List<PlantProfile>`,
  `getGardenSpaces(): List<GardenSpace>`, `getContainers(): List<Container>`.
- `:data` `mapper/DtoMappers.kt` — `PlantProfileDto.toDomain()` (drops the nested jsonb
  profiles).
- `:data` `repository/InventoryRepositoryImpl.kt` — implemented the three methods over the
  `:network` api (`api.getPlantProfiles()/getGardenSpaces()/getContainers()`, `.map { it.toDomain() }`).
- `:data` test `FakePlantAppApi.kt` — added a valid `plantProfile: PlantProfileDto` canned
  value + the three overrides (`getPlantProfiles`/`getGardenSpaces`/`getContainers`) — this
  is what makes `:data:testDebugUnitTest` compile again.
- `:data` test `InventoryRepositoryImplTest.kt` — added `getPlantProfilesMapsToDomain` and
  `getGardenSpacesAndContainersMapToDomain`.

## Tests (the gate)
Correct task names: `:domain` is a pure-Kotlin (JVM) module → `:domain:test` (not
`:domain:testDebugUnitTest`, which doesn't exist there); `:data` → `:data:testDebugUnitTest`.
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :domain:test :data:testDebugUnitTest
BUILD SUCCESSFUL in 31s
```
- Baseline: `:data:testDebugUnitTest` failed to **compile** (FakePlantAppApi didn't implement
  the 3 new abstract `PlantAppApi` methods from `0021`).
- After: `:domain` `InventoryModelsTest` 2/2; `:data` `InventoryRepositoryImplTest` **7/7**
  (5 prior + 2 new), `InventoryAdvisoriesTest` 1/1 — all 0 failures.

## Commit
- `3fba718` — feat(android-data): PlantProfile domain model + repository list methods
- `git show --stat HEAD`: 6 files, +80 — only `android/domain/**` + `android/data/**`.
- `android/local.properties` NOT committed (git-ignored; grep count 0).

## Compliance
- No `:network` / `:feature-inventory` / `:app` / backend / `shared-schemas` / `supabase`
  change. No new deps. No UI. No on-device care logic (`PlantProfile` carries no care
  profile; `CareTask`/care fields stay backend-only, D-09). Did not mount/repoint the
  SDK/Drive; left git-ignored `local.properties` in place.

Final `origin/master` SHA: `3fba7184c52e87861dc222d4c42ecd11b9d36003`

## Note for the planner (task-name correction)
The prompt's verification command listed `:domain:testDebugUnitTest`, but `:domain` is a
kotlin-jvm module whose test task is `:domain:test`. Ran `:domain:test :data:testDebugUnitTest`
(both green). Worth using `:domain:test` in future `:domain` gates.

## Next (3b-ui, per planner follow-up)
`:feature-inventory` add-plant **selectors**: profile dropdown from `getPlantProfiles()`;
garden-space/container select-or-create from `getGardenSpaces()`/`getContainers()` — replacing
the id text fields, + ViewModel wiring + Compose UI tests (Robolectric).
