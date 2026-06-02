# VERIFICATION — handoff 0012-android-domain-data (red→green)

Gate: `:domain:test` + `:data:testDebugUnitTest` go red→green; `:app:assembleDebug`
still succeeds. All gradlew runs used `GRADLE_USER_HOME=/tmp/plantapp-gradle-home`.

## Commit 1 (`0f8c596`) — RED
```
$ ./gradlew :domain:test :data:testDebugUnitTest --no-daemon
e: ... Cannot infer type for this parameter   (domain models absent)
e: ... Unresolved reference 'InventoryRepositoryImpl'
> Task :data:compileDebugUnitTestKotlin FAILED
BUILD FAILED
```
Tests reference domain models + `InventoryRepositoryImpl` that don't exist yet →
compile-red. Test dependencies (junit, kotlin-test, coroutines-test, retrofit) resolved
fine.

## Commit 2 (`a99cb75`) — GREEN
```
$ ./gradlew :domain:test :data:testDebugUnitTest --no-daemon
BUILD SUCCESSFUL
# :domain InventoryModelsTest      tests="2" failures="0" errors="0"
# :data   InventoryRepositoryImplTest tests="5" failures="0" errors="0"
```
`:data` tests prove the mapping contract against a fake `PlantAppApi`:
- `addPlant` maps `NewPlant`→`AddPlantRequest` and `AddPlantResponse`→`AddPlantResult`
  (plant + one `water` CareTask with engineVersion `0.1.0`, inputsHash, dueAt, priority
  `normal`, status `pending`, non-empty rationale).
- `getPlants`/`getPlantTasks` map lists; `createGardenSpace`/`createContainer` map to
  domain; `deletePlant` calls the API.

```
$ ./gradlew :app:assembleDebug --no-daemon
BUILD SUCCESSFUL in 1m 29s
```
Hilt/KSP wiring through the new `:data` `DataModule` compiles into the app graph.

## Scope / integrity
- No Compose/UI/ViewModels; no Room (unused Room deps removed from `:data`); no care
  logic on device (CareTask opaque). No CameraX/FCM/WorkManager/AI/Ktor/`:care-engine`.
- `backend/**`, `shared-schemas/**`, `supabase/**`, `:network` source, and
  `:feature-inventory` unchanged (`git diff --quiet HEAD`).
- No new production deps beyond the existing catalog.

## Final repo state
- origin/master = `a99cb755ecdbb76463e394b914a395a2916dcdbf`; local == origin; clean.
- Backend suites unaffected (not re-run): unit 50/50, integration 21/21, lint clean.
