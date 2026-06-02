# DONE — handoff 0013-android-inventory-ui (a3b — closes Slice 1)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** `:feature-inventory` Compose screens (list/add/detail) + Hilt ViewModels +
`:app` NavHost wired to `InventoryRepository`; the 4 Compose UI tests (#21–#24) pass on
the JVM via Robolectric; `:app:assembleDebug` BUILD SUCCESSFUL (APK produced).
**This completes the Slice 1 DOD (#1–#24).**
Final `origin/master` = `a568a4d4ac746e3d3e9942263af32d5bf75356b2`.

## Baseline precondition — matched
- HEAD = `a99cb755ecdbb76463e394b914a395a2916dcdbf` == origin/master; clean.
- All gradlew runs used `GRADLE_USER_HOME=/tmp/plantapp-gradle-home`; no concurrent runs.

## Commit 1 (RED) — `test(android-inventory): add Slice 1 Compose UI tests (#21–#24)`
- Hash: `da0eee0`
- Catalog: test-only deps — robolectric 4.14.1, androidx.test.ext:junit 1.2.1,
  compose-ui-test-junit4, compose-ui-test-manifest; plus lifecycle-viewmodel-ktx
  (production, for `viewModelScope`).
- `:feature-inventory` build: `testOptions { unitTests { isIncludeAndroidResources =
  true; all { useJUnit() } } }` + test deps; `debugImplementation(compose-ui-test-manifest)`.
- `InventoryScreensTest` (Robolectric + `createComposeRule`): #21 empty state, #22
  add-plant submit, #23 detail shows water task, #24 missing-container validation.
- `./gradlew :feature-inventory:testDebugUnitTest` (RED): compile failure — screens +
  UI-state types + `InventoryTestTags` don't exist. Intended red.
- `git show --stat`: 3 files, +123. Pushed `a99cb75..da0eee0`.

## Commit 2 (GREEN) — `feat(android-inventory): add add-plant/list/detail screens + nav (Slice 1 UI)`
- Hash: `a568a4d`
- `:feature-inventory/src/main`:
  - `InventoryTestTags.kt` — stable semantics tags.
  - `InventoryUiState.kt` — `PlantListUiState` (Loading/Empty/Content/Error),
    `PlantDetailUiState` (Loading/Content/Error), `AddPlantForm`.
  - `PlantListScreen.kt` — list with empty state + FAB; row click → detail.
  - `AddPlantScreen.kt` — id-based form (profile/container/garden-space/growth-stage/
    last-watered); **validates container present** before `onSubmit`, else shows a
    field-level error and does not submit.
  - `PlantDetailScreen.kt` — renders the water `CareTask`: kind, rationale, an
    engineVersion **badge**, and a formatted `dueAt` (java.time, minSdk 26).
  - `InventoryViewModels.kt` — `@HiltViewModel` PlantList/AddPlant/PlantDetail VMs
    injecting `InventoryRepository`, exposing `StateFlow` UI state via coroutines.
- `:design-system` — `Theme.kt` (`PlantAppTheme` M3 wrapper).
- `:app` — `PlantApplication` (`@HiltAndroidApp`), `MainActivity` (`@AndroidEntryPoint`)
  hosting a Compose `NavHost` (list → add → detail) with `hiltViewModel()`; manifest
  registers the Application + launcher activity (framework
  `Theme.Material.Light.NoActionBar`, no extra dep).
- Removed redundant `.gitkeep`s in app/design-system/feature-inventory main.
- Test robustness (in the commit-1 test file): `@Config(qualifiers = "w411dp-h2000dp")`
  + `performScrollTo()` before the submit click, so the full form lays out and the
  submit button is on-screen under Robolectric (the initial run had #22/#24 failing
  because the button was below the fold and `performClick` no-opped).
- `./gradlew :feature-inventory:testDebugUnitTest` → **4 passed (4)**.
  `./gradlew :app:assembleDebug` → **BUILD SUCCESSFUL**; `app-debug.apk` (~11.3 MB).
- `git show --stat`: 14 files, +536/−4. Pushed `da0eee0..a568a4d`.

## How the UI tests run + test-only deps
Robolectric (`@RunWith(RobolectricTestRunner)`, `@Config(sdk=[34], qualifiers=
"w411dp-h2000dp")`) on the JVM — no emulator. `createComposeRule()` drives the
**stateless** screens directly with fixture state + callback spies (no Hilt graph, no
real repo in tests). Test-only deps: robolectric, androidx.test.ext:junit,
compose-ui-test-junit4 (+ compose-ui-test-manifest debug). #22/#24 spy the `onSubmit`
callback to assert the success/validation paths.

## Compliance
- No CameraX/photos/location/FCM/WorkManager/AI/Ktor/Room/`:care-engine`. No
  care-scheduling logic on device — the backend `CareTask` is rendered as-is (opaque).
- No new **production** deps beyond the catalog (lifecycle-viewmodel-ktx is part of the
  existing AndroidX lifecycle stack).
- `backend/**`, `shared-schemas/**`, `supabase/**`, and `:network`/`:domain`/`:data`
  source UNCHANGED (`git diff --quiet HEAD`).

## Commit hashes + titles
1. `da0eee0` — test(android-inventory): add Slice 1 Compose UI tests (#21–#24)
2. `a568a4d` — feat(android-inventory): add add-plant/list/detail screens + nav (Slice 1 UI)

Final `origin/master` SHA: `a568a4d4ac746e3d3e9942263af32d5bf75356b2`

## Deferred / UX shortcuts (for the Slice 1 retro)
- **Add-plant form uses id text fields** (profileId/containerId/gardenSpaceId) rather
  than rich selectors/"create-or-select" pickers — fine for the Slice 1 walking
  skeleton; real dropdowns (profile catalog, owned containers/spaces) are a follow-up.
- **No sign-in UI** — the auth token is read from DataStore (`SettingsStore`); wiring a
  Supabase magic-link sign-in screen + writing the token is a later slice (D-05).
- **No on-device manual run yet** — verified via Robolectric + assembleDebug, not on a
  device/emulator; an owner device run is the recommended Slice 1 acceptance step.
- Detail VM fetches the plant via `getPlants().firstOrNull{}` (no single-plant GET in
  the repo port) — fine at Slice 1 scale.
- ViewModels are wired/compiled but not unit-tested here (tests target the stateless
  screens, per the prompt); VM coverage can be added later.

## Slice 1 status
DOD #1–#24 are green across backend (schema, engine, seed catalog, DB+RLS, add-plant→
CareTask API, isolation, cascade, contract conformance) and Android (network DTOs,
domain/data repository, inventory UI). Per the planner follow-up: STOP and report to the
owner with a consolidated Slice 1 retro and the next-direction decision — do not
auto-start Slice 2.
