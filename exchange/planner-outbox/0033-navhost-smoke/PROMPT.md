# Next Implementation Prompt — backlog (2): Robolectric **NavHost smoke** (gated end-to-end journey)

**Backlog item (2) automated e2e smoke.** The owner chose a **fast, deterministic JVM/Robolectric
NavHost smoke** (not a real emulator run; the human "add my real plants on my phone" acceptance
stays with the owner). This test drives a real `NavController`/`NavHost` over the **actual
screens + ViewModels**, with the repositories replaced by **fakes** — no Hilt-test infra, no
emulator, no backend. It exercises the gated journey end-to-end: sign-in → list → add-plant (via
selectors) → detail → accept advisory.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`d1bda811a2a27978a5b4a5b7354c5c49d13620d7` == `origin/master`, clean. `:feature-inventory` already
has Robolectric + Compose UI test (`createComposeRule`, `@Config(sdk=[34])`) + `kotlinx.coroutines.test`.
Screens: `SignInScreen(codeSent, error, onRequestCode, onVerify)`, `PlantListScreen(state,
onAddClick, onPlantClick)`, `AddPlantScreen(profiles, gardenSpaces, onCreateGardenSpace, containers,
onCreateContainer, onSubmit, onCancel)`, `PlantDetailScreen(state, onAccept, onBack)`. ViewModels
(`SignInViewModel`, `PlantListViewModel`, `AddPlantViewModel`, `PlantDetailViewModel`) each take an
`InventoryRepository` and/or `AuthRepository` via constructor (plain classes — `hiltViewModel()` is
only used in `:app` `MainActivity`, whose 4-route graph `Routes` LIST/ADD/DETAIL/SIGN_IN is
compile-checked by `:app:assembleDebug`). `:feature-inventory` does **not** yet depend on
navigation-compose. The production `PlantAppApiFactory`/Hilt graph is out of scope here.

Single logical change (the NavHost smoke + its test deps/fakes) → one commit. Red→green.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add a
Robolectric NavHost smoke test in `:feature-inventory`. **Consult the Compose Navigation testing +
`Dispatchers.setMain` docs.** Red-first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect d1bda811a2a27978a5b4a5b7354c5c49d13620d7 == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`android/feature-inventory/build.gradle.kts`** — add `testImplementation(libs.compose.navigation)`
   (the same `compose.navigation` alias `:app` uses) so the test can build a `NavHost`. No other
   dependency. (If a `compose.navigation` alias isn't resolvable from this module's test config,
   STOP and report rather than inventing a coordinate.)
2. **Test-only fakes** in `:feature-inventory/src/test/.../` (new file `NavSmokeFakes.kt`):
   - `class FakeInventoryRepository : InventoryRepository` returning canned data: one `PlantProfile`
     (`solanum-lycopersicum`/"Tomato"), one `GardenSpace`, one `Container`; `getPlants()` returns
     one `Plant`; `getPlantTasks` returns one `CareTask` (`water`); `getAdvisories` returns one
     `container-size` `Advisory`; `addPlant` returns an `AddPlantResult`; `acceptAdvisory` records
     the `(plantId, kind)` and returns a `repot` `CareTask`; create methods return the canned
     space/container. (Track flags so the test can assert calls.)
   - `class FakeAuthRepository : AuthRepository` with `var requested`/`verified` flags;
     `requestOtp`/`verifyOtp` just record and succeed.
3. **`NavSmokeTest.kt`** (new, Robolectric `@RunWith(RobolectricTestRunner::class) @Config(sdk=[34],
   qualifiers="w411dp-h2000dp")`):
   - Set the Main dispatcher for the ViewModels' `viewModelScope`:
     `@Before fun setUp() { Dispatchers.setMain(StandardTestDispatcher()) }` /
     `@After { Dispatchers.resetMain() }` (import `kotlinx.coroutines.test.*`). Advance with
     `composeRule.waitForIdle()` (and `runCurrent()`/`advanceUntilIdle()` as needed).
   - A private `@Composable fun SmokeNavHost(repo: FakeInventoryRepository, auth: FakeAuthRepository)`
     that mirrors the `:app` graph: `rememberNavController()` + `NavHost(startDestination =
     "signin")` with composables for `"signin"`, `"plants"`, `"plants/add"`, `"plants/{plantId}"`,
     constructing each ViewModel with `remember { … }` over the fakes (e.g. `remember {
     SignInViewModel(auth) }`), collecting their state with `collectAsState()`, and wiring the same
     callbacks `MainActivity` uses. **Add a comment** `// mirrors MainActivity's nav graph — keep
     route strings/callbacks in sync if MainActivity changes` (the test mirrors, not imports, the
     `:app` graph since `:feature-inventory` can't depend on `:app`). (`onVerify` → `vm.verify(...) { nav.navigate("plants"){ popUpTo(
     "signin"){inclusive=true} } }`, `onAddClick` → navigate add, `onPlantClick` → navigate detail
     with the id, `onAccept` → `detailVm.accept(plantId, kind)`, the add `onSubmit` →
     `addVm.submit(form){ id -> nav.navigate("plants/$id"){ popUpTo("plants") } }`). For DETAIL, call
     `LaunchedEffect(plantId){ detailVm.loadFor(plantId) }` like production.
   - **Test `signed-out user signs in, sees the plant list`**: render `SmokeNavHost`; the sign-in
     email field is shown; type email → `SIGNIN_SEND_CODE_BUTTON`; type code → `SIGNIN_VERIFY_BUTTON`;
     `waitForIdle()`; assert the list screen shows the seeded plant (e.g. its nickname/profile text
     or `PLANT_LIST` tag) and `auth.verified` is true.
   - **Test `accept an advisory from the detail screen`**: drive sign-in → list → tap the plant
     (`onPlantClick`) → on detail, the `container-size` advisory shows an Accept button
     (`ADVISORY_ACCEPT_BUTTON_PREFIX + "container-size"`); click it; `waitForIdle()`; assert
     `repo.lastAccept == (plantId, "container-size")` (the reload re-queries advisories/tasks).
   - (Optional third: add-plant via selectors → detail; include if it stays deterministic.)

### Forbidden
- No change to production code (`src/main` of any module) — this is a **test-only** addition
  (build.gradle test dep + test sources). If a screen/VM genuinely can't be driven without a tiny
  testable seam, STOP and report rather than refactoring production here. No `:app`/backend/schema
  change. No emulator, no real network, no Hilt-test runner. No camera/photos/GPS/AI. Don't
  mount/repoint the SDK/Drive; don't commit `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
```
Red→green: the new `NavSmokeTest` fails before the NavHost/fakes exist; after, `:feature-inventory`
unit tests pass (the smoke tests green; all prior tests still green). Report the count + new test
names. (If the NavHost flow proves non-deterministic under Robolectric despite
`Dispatchers.setMain` + `waitForIdle`, STOP and report what's flaky rather than adding sleeps.)

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/feature-inventory/
git -C /home/israel/Documents/Development/PlantApp commit -m "test(android): Robolectric NavHost smoke for the gated sign-in -> list -> detail -> accept journey"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The smoke test (the mirrored NavHost graph, the fakes, the journey asserted) + the dispatcher
   handling.
2. `:feature-inventory:testDebugUnitTest` count before→after + new test names (all green).
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/feature-inventory/**` changed (build.gradle test dep + test sources; no `src/main`, not
   `local.properties`).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `feature-inventory/**`, test-only; smoke green; prior tests green). **That
completes backlog items (1)+(2)+(3) — only (4) Slice 3 remains.** Then **(4) Slice 3**: deterministic
watering **reminders**. Plan: WorkManager **local** notification path first (schedule a reminder
from an existing CareTask's `dueAt`; no network) — then **STOP and ask the owner for Firebase/FCM
setup** (a Firebase project + `google-services.json`) before any push-notification work. Planner
will ground the reminder design against the care-engine `CareTask.dueAt` + decide the first
red-first slice. Vision-check each step.
