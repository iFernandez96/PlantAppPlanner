# VERIFICATION — handoff 0032-android-accept-ui (3d-android-ui, red→green)

Gate: `:feature-inventory:testDebugUnitTest :app:assembleDebug`, Drive mounted.

## RED driver
The new tests reference `InventoryTestTags.ADVISORY_ACCEPT_BUTTON_PREFIX` and the `onAccept`
parameter on `PlantDetailScreen` — neither exists before the change → compile-red.

## GREEN
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 27s
```
Per-class (test-results XML):
- `PlantDetailAdvisoriesTest` — tests="4" skipped="0" failures="0" errors="0"
  - `showsAcceptButtonForContainerSizeAndInvokesCallback` — Accept button (tag
    `advisory_accept_container-size`) displayed; click → spy `== "container-size"`.
  - `noAcceptButtonForPollination` — `advisory_accept_pollination` asserts does-not-exist.
  - `showsAdvisoryTitleMessageAndSeverity`, `noAdvisorySectionWhenEmpty` (unchanged).
- `InventoryScreensTest` 9/0/0/0; `SignInScreenTest` 3/0/0/0 (unchanged).
- `:feature-inventory` total 14 → 16. No failing files.
- `:app:assembleDebug` — **BUILD SUCCESSFUL** (the `onAccept = { vm.accept(...) }` route wiring
  type-checks).

## Scope / integrity
- `git show --stat`: 5 files, +77 −5 — only `android/feature-inventory/**` (InventoryTestTags,
  InventoryViewModels, PlantDetailScreen, PlantDetailAdvisoriesTest) + `android/app/**`
  (MainActivity). No `:network`/`:data`/`:domain`/backend/schema/supabase change. No new dependency.
  No on-device care logic (accept calls backend + reload; D-09).
- `local.properties` not committed (grep 0).

## Final repo state
- origin/master = `d1bda811a2a27978a5b4a5b7354c5c49d13620d7`; local == origin.
- Working tree clean except git-ignored `android/local.properties`.
