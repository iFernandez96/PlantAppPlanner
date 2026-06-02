# VERIFICATION — handoff 0013-android-inventory-ui (a3b, red→green) — closes Slice 1

Gate: `:feature-inventory:testDebugUnitTest` (#21–#24) goes red→green on the JVM via
Robolectric; `:app:assembleDebug` BUILD SUCCESSFUL. `GRADLE_USER_HOME=/tmp/plantapp-gradle-home`.

## Commit 1 (`da0eee0`) — RED
```
$ ./gradlew :feature-inventory:testDebugUnitTest --no-daemon
e: Unresolved reference 'InventoryTestTags'  (+ screens / UI-state types absent)
BUILD FAILED
```
Compile-red: the screens and state types don't exist yet. Test-only deps (Robolectric,
compose-ui-test) resolved.

## Commit 2 (`a568a4d`) — GREEN
First run after implementing: 4 tests, **2 failed** (#22/#24) — the submit Button was
below the fold in a `verticalScroll` Column, so under Robolectric's default window
`performClick` no-opped (assert `expected:<...> but was:<null>` / "component is not
displayed"). Fixed in the test with a tall window qualifier + `performScrollTo()`.
Re-run:
```
$ ./gradlew :feature-inventory:testDebugUnitTest --no-daemon
BUILD SUCCESSFUL
# InventoryScreensTest tests="4" skipped="0" failures="0" errors="0"
```
- #21 empty state renders.
- #22 filling required fields + submit invokes `onSubmit` with the entered ids.
- #23 detail renders the water task: kind "water", rationale, engineVersion badge
  ("0.1.0"), formatted dueAt.
- #24 submit without a container shows the field-level error and does NOT invoke onSubmit.

```
$ ./gradlew :app:assembleDebug --no-daemon
BUILD SUCCESSFUL in 2m 03s
$ ls app/build/outputs/apk/debug/app-debug.apk   -> 11,335,710 bytes
```
The full app graph (PlantApplication @HiltAndroidApp, MainActivity @AndroidEntryPoint,
NavHost with 3 @HiltViewModel screens injecting InventoryRepository) compiles and packages.

## Scope / integrity
- No CameraX/photos/location/FCM/WorkManager/AI/Ktor/Room/`:care-engine`; no care logic
  on device (CareTask opaque). No new production deps beyond the catalog.
- `backend/**`, `shared-schemas/**`, `supabase/**`, `:network`/`:domain`/`:data` source
  unchanged (`git diff --quiet HEAD`).

## Final repo state
- origin/master = `a568a4d4ac746e3d3e9942263af32d5bf75356b2`; local == origin; clean.
- Slice 1 DOD #1–#24 green: backend unit 50/50 + integration 21/21 + lint clean (as of
  earlier handoffs, unaffected here) and Android `:network` 10 + `:domain` 2 + `:data` 5
  + `:feature-inventory` 4 unit/UI tests, `:app:assembleDebug` OK.
