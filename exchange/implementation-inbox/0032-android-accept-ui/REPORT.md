# DONE — handoff 0032-android-accept-ui (3d-android-ui, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** plant-detail **"Accept"** action per acceptable advisory → `PlantDetailViewModel.accept`
→ `repository.acceptAdvisory` → reload tasks/advisories. `:feature-inventory` Robolectric tests
green; `:app:assembleDebug` OK. **Backlog item (3) UX follow-ups is now COMPLETE.** Final
`origin/master` = `d1bda811a2a27978a5b4a5b7354c5c49d13620d7`.

## Baseline + unblock
- HEAD at start = `bfdd946…` == origin/master; clean. SDK resolves (Drive mounted).

## What was added
1. **`InventoryTestTags.kt`** — `ADVISORY_ACCEPT_BUTTON_PREFIX = "advisory_accept_"` (per-kind tag).
2. **`PlantDetailScreen.kt`** — new param `onAccept: (kind: String) -> Unit = {}` (after `state`,
   before `modifier`/`onBack`), threaded `AdvisoriesSection` → `AdvisoryRow`. In `AdvisoryRow`,
   when `advisory.kind ∈ {container-size, support}` (a private `ACCEPTABLE_ADVISORY_KINDS` set),
   render a Material3 `Button` "Accept" tagged `ADVISORY_ACCEPT_BUTTON_PREFIX + advisory.kind`
   calling `onAccept(advisory.kind)`. Other kinds (e.g. `pollination`) render **no** button
   (commented: backend 400s them). Existing severity styling/text unchanged.
3. **`InventoryViewModels.kt`** — `PlantDetailViewModel.accept(plantId, kind)`:
   `viewModelScope.launch { try { repository.acceptAdvisory(plantId, kind); loadFor(plantId) }
   catch (_: Exception) { loadFor(plantId) } }` (reloads on both paths; no crash).
4. **`:app` `MainActivity.kt`** — `Routes.DETAIL` composable now passes
   `onAccept = { kind -> vm.accept(plantId, kind) }` to `PlantDetailScreen`. No other route change.

## Tests (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 27s
```
- **`PlantDetailAdvisoriesTest`** +2 (now 4):
  - `showsAcceptButtonForContainerSizeAndInvokesCallback` — the button tagged
    `advisory_accept_container-size` is displayed; `performClick()` → spy got `"container-size"`.
  - `noAcceptButtonForPollination` — `advisory_accept_pollination` `assertDoesNotExist()`.
  - (existing `showsAdvisoryTitleMessageAndSeverity`, `noAdvisorySectionWhenEmpty` still green.)
- `:feature-inventory` total **14 → 16** (PlantDetailAdvisoriesTest 4, InventoryScreensTest 9,
  SignInScreenTest 3). All green.
- **`:app:assembleDebug` BUILD SUCCESSFUL** (the `vm.accept` route wiring type-checks through
  Hilt/KSP).

## Commit
- `d1bda81` — feat(android-inventory): accept-advisory action on the plant detail screen
- `git show --stat HEAD`: 5 files, +77 −5 — only `android/feature-inventory/**` (InventoryTestTags,
  InventoryViewModels, PlantDetailScreen, PlantDetailAdvisoriesTest) + `android/app/**`
  (MainActivity). `local.properties` NOT committed (grep 0).

## Compliance
- No `:network`/`:data`/`:domain`/backend/`shared-schemas`/`supabase` change. No new dependency.
  No on-device care logic — `accept` only calls the backend then reloads; the task is server-
  computed (D-09). No camera/photos/GPS/notifications/AI. SDK/Drive untouched.

Final `origin/master` SHA: `d1bda811a2a27978a5b4a5b7354c5c49d13620d7`

## Backlog (3) UX follow-ups — COMPLETE
Add-plant fully selector-driven · email-OTP sign-in + gating · advisory → accept → CareTask
end-to-end (engine → API → :network/:data → detail-screen Accept).

## Next (per planner follow-up)
(2) Automated emulator e2e smoke — planner will ground instrumented-test setup (androidTest vs
Robolectric, emulator/AVD availability) and likely surface an owner decision. Then (4) Slice 3
(deterministic watering reminders; WorkManager local path first, then STOP for owner Firebase/FCM
setup).
