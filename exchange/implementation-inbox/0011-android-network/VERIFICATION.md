# VERIFICATION — handoff 0011-android-network (red→green)

Gate: `:network:testDebugUnitTest` goes red→green; `:app:assembleDebug` still succeeds.
All gradlew runs used `GRADLE_USER_HOME=/tmp/plantapp-gradle-home`.

## Commit 1 (`e69f6a0`) — RED
```
$ ./gradlew :network:testDebugUnitTest --no-daemon
e: ... Unresolved reference 'AddPlantResponse'
e: ... Unresolved reference 'AddPlantRequest'
> Task :network:compileDebugUnitTestKotlin FAILED
BUILD FAILED
```
Tests reference DTOs that don't exist yet → compile-red. The new test dependencies
(networknt, jackson, junit, kotlin-test) resolved without error — only the missing
production DTOs failed.

## Commit 2 (`f6c8155`) — GREEN
```
$ ./gradlew :network:testDebugUnitTest --no-daemon
BUILD SUCCESSFUL
# test-results:
#   DtoSerializationTest   tests="6" skipped="0" failures="0" errors="0"
#   SchemaValidationTest   tests="4" skipped="0" failures="0" errors="0"
```
- DtoSerializationTest (6): kotlinx.serialization round-trip equality for GardenSpaceDto,
  ContainerDto, PlantInstanceDto, CareTaskDto, AddPlantResponse, and absent-optional
  omission on AddPlantRequest.
- SchemaValidationTest (4): GardenSpaceDto/ContainerDto/PlantInstanceDto/CareTaskDto each
  serialize and validate against the matching `shared-schemas/*.schema.json` via
  networknt (JSON Schema 2020-12) — **D-06 satisfied**.

```
$ ./gradlew :app:assembleDebug --no-daemon
BUILD SUCCESSFUL in 1m 51s
```
The app still assembles with `:network` now populated.

## Scope / integrity
- Only `:network` source/tests + the version catalog changed. `backend/**`,
  `shared-schemas/**`, `supabase/**`, and other Android modules unchanged
  (`git diff --quiet HEAD`).
- No forbidden deps (no CameraX/FCM/WorkManager/AI/Ktor/`:care-engine`); no Compose/UI.
- No new production deps (existing Retrofit/OkHttp/kotlinx stack); test-only deps added
  to the catalog.

## Final repo state
- origin/master = `f6c8155ac6618e493d46c82d53ea9c8021d83161`; local == origin; clean.
- Backend suites unaffected (not re-run): unit 50/50, integration 21/21, lint clean.
