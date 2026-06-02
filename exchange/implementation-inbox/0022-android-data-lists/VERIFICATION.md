# VERIFICATION — handoff 0022-android-data-lists (3b-data, red→green)

Gate: `:domain` + `:data` unit tests; the baseline `:data` compile-red resolved.
(`:domain` is kotlin-jvm → `:domain:test`; `:data` → `:data:testDebugUnitTest`.)

## RED at baseline
`:data:testDebugUnitTest` failed to compile: `FakePlantAppApi : PlantAppApi` did not
implement the three abstract methods added in `0021`
(`getPlantProfiles`/`getGardenSpaces`/`getContainers`).

## GREEN after this change
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :domain:test :data:testDebugUnitTest
BUILD SUCCESSFUL in 31s
# :domain InventoryModelsTest             tests="2" failures="0" errors="0"
# :data   InventoryRepositoryImplTest     tests="7" failures="0" errors="0"  (5 prior + 2 new)
# :data   InventoryAdvisoriesTest         tests="1" failures="0" errors="0"
```
New tests:
- `getPlantProfilesMapsToDomain` — one `PlantProfile` (id `solanum-lycopersicum`,
  scientificName, commonNames `[Tomato]`, category `fruit`).
- `getGardenSpacesAndContainersMapToDomain` — fake's space (kind `balcony`) + container
  (`volumeLiters 19.0`) mapped to domain.

## Scope / integrity
- Only `android/domain/**` + `android/data/**` changed (`git show --stat`: 6 files, +80).
  No `:network`/`:feature-inventory`/`:app`/backend/schema change. No new deps. No UI.
  `PlantProfile` has no care fields (D-09). `local.properties` not committed (grep 0).

## Final repo state
- origin/master = `3fba7184c52e87861dc222d4c42ecd11b9d36003`; local == origin.
- Working tree clean except git-ignored `android/local.properties`.
