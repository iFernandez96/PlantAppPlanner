# DONE — handoff 0033-navhost-smoke (backlog 2, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** a fast, deterministic JVM/Robolectric **NavHost smoke** in `:feature-inventory` — a real
`NavController`/`NavHost` over the actual screens + ViewModels, repositories faked (no Hilt, no
emulator, no backend). Exercises the gated journey sign-in → list → detail → accept. Test-only.
Final `origin/master` = `da020e3abdc3bd4ada2d2ec5c4ec39a8f1a53e58`.

## Baseline + unblock
- HEAD at start = `d1bda81…` == origin/master; clean. SDK resolves (Drive mounted).
- `compose.navigation` alias resolvable from the version catalog (same alias `:app` uses).

## What was added (test-only)
1. **`feature-inventory/build.gradle.kts`** — `testImplementation(libs.compose.navigation)` (the
   only new dep; lets the test build a real `NavHost`).
2. **`NavSmokeFakes.kt`** (new test source):
   - `FakeInventoryRepository : InventoryRepository` — canned `PlantProfile` (Tomato),
     `GardenSpace`, `Container`; `getPlants()`→one `Plant` ("Pasi"); `getPlantTasks`→one `water`
     task; `getAdvisories`→one `container-size` `Advisory`; `addPlant`→`AddPlantResult` (records
     `addPlantCalled`); `acceptAdvisory` records `(plantId, kind)` and returns a `repot` task;
     create methods return the canned space/container.
   - `FakeAuthRepository : AuthRepository` — `requestOtp`/`verifyOtp` set `requested`/`verified`
     and succeed.
3. **`NavSmokeTest.kt`** (new, Robolectric `@Config(sdk=[34], qualifiers="w411dp-h2000dp")`):
   - `private @Composable SmokeNavHost(repo, auth)` mirrors `MainActivity`'s 4-route graph
     (`signin`/`plants`/`plants/add`/`plants/{plantId}`), constructing each ViewModel with
     `remember { … }` over the fakes and wiring the same callbacks (verify→navigate plants with
     `popUpTo(signin){inclusive}`, onPlantClick→detail, onAccept→`detailVm.accept`, add submit→
     detail; DETAIL uses `LaunchedEffect(plantId){ loadFor }`). Carries the comment
     "mirrors MainActivity's nav graph — keep route strings/callbacks in sync …".
   - **Dispatcher handling:** `Dispatchers.setMain(UnconfinedTestDispatcher())` in `@Before`,
     `resetMain()` in `@After`. Unconfined runs each `viewModelScope` launch eagerly inline — the
     fakes never suspend, so state settles synchronously even when a navigation creates the next
     screen's ViewModel mid-recomposition; `idle()` is then just `composeRule.waitForIdle()`.
     (Documented why not StandardTestDispatcher — see "verification notes".)

## Tests (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
BUILD SUCCESSFUL in 19s
```
- **`NavSmokeTest`** (new): 2 tests —
  - `signed-out user signs in, sees the plant list` — starts on sign-in; email→Send code→code→
    Verify; asserts `auth.verified` and the `PLANT_LIST` + the seeded plant ("Pasi") show.
  - `accept an advisory from the detail screen` — sign-in → list → tap plant → detail's
    `container-size` Accept button → click → `repo.lastAccept == (plant.id, "container-size")`.
- `:feature-inventory` total **16 → 18** (NavSmokeTest 2, InventoryScreensTest 9,
  PlantDetailAdvisoriesTest 4, SignInScreenTest 3). All green. No compiler warnings (opt-in
  annotated).

## Verification notes
- First run failed (2/2 NavSmokeTest): with `StandardTestDispatcher`, the just-navigated screen's
  ViewModel `init`/`loadFor` launch was scheduled *after* `advanceUntilIdle` ran, so the list/detail
  stayed in Loading during `waitForIdle` (PLANT_LIST/"Pasi" not displayed). Fixed by switching Main
  to `UnconfinedTestDispatcher` (eager inline execution) — not a flaky-hiding sleep; the fakes are
  non-suspending so it's fully deterministic. No production change was needed.

## Commit
- `da020e3` — test(android): Robolectric NavHost smoke for the gated sign-in -> list -> detail -> accept journey
- `git show --stat HEAD`: 3 files, +267 — only `android/feature-inventory/**` (build.gradle test
  dep + `NavSmokeFakes.kt` + `NavSmokeTest.kt`). **No `src/main`** of any module (grep 0).
  `local.properties` NOT committed (grep 0).

## Compliance
- Test-only: no production code changed. No `:app`/backend/schema/supabase change. No emulator, no
  real network, no Hilt-test runner. No camera/photos/GPS/AI. SDK/Drive untouched.

Final `origin/master` SHA: `da020e3abdc3bd4ada2d2ec5c4ec39a8f1a53e58`

## Status / next (per planner follow-up)
Backlog items (1) add-plant selectors + (2) e2e smoke + (3) advisory→accept are now complete; only
**(4) Slice 3** remains: deterministic watering **reminders** — WorkManager **local** notification
path first (schedule from an existing `CareTask.dueAt`, no network), then **STOP and ask the owner
for Firebase/FCM setup** (Firebase project + `google-services.json`) before push work.
