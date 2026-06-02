# VERIFICATION — handoff 0031-android-accept-netdata (3d-android net+data, red→green)

Gate: `:network:testDebugUnitTest :domain:test :data:testDebugUnitTest`, Drive mounted.

## RED driver
`AcceptAdvisoryDtoTest` references `AcceptAdvisoryRequest` (absent) and `InventoryRepositoryImplTest`
calls `repo.acceptAdvisory(...)` (absent on the port). Also adding `acceptAdvisory` to `PlantAppApi`
makes `FakePlantAppApi` an incomplete implementation → `:data` test source won't compile until the
override is added. → compile-red across `:network` and `:data`.

## GREEN
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest :domain:test :data:testDebugUnitTest
BUILD SUCCESSFUL in 19s
```
Per-class (test-results XML):
- `AcceptAdvisoryDtoTest` — tests="1" failures="0" (new).
- `:network` total 16 → 17 (AdvisoryDtoTest 2, AuthDtoTest 3, DtoSerializationTest 6,
  SchemaValidationTest 5, AcceptAdvisoryDtoTest 1).
- `InventoryRepositoryImplTest` — tests="8" failures="0" (was 7; +acceptAdvisoryMapsTheReturnedCareTask).
- `:data` total 10 → 11 (AuthRepositoryImplTest 2, InventoryAdvisoriesTest 1,
  InventoryRepositoryImplTest 8).
- `:domain` compiles against the new port; `InventoryModelsTest` 2/2 unchanged.
- All prior tests green.

## Scope / integrity
- `git show --stat`: 7 files, +48 — only `android/network/**` (Dtos, PlantAppApi, +AcceptAdvisoryDtoTest)
  + `android/domain/**` (InventoryRepository) + `android/data/**` (InventoryRepositoryImpl,
  FakePlantAppApi, InventoryRepositoryImplTest). No `:feature-inventory`/`:app`/backend/schema/
  supabase change. No new dependency. No on-device care logic (client calls backend; D-09).
- `local.properties` not committed (grep 0).

## Final repo state
- origin/master = `bfdd946108ffb31b45f66e80177e9aff9734e949`; local == origin.
- Working tree clean except git-ignored `android/local.properties`.
