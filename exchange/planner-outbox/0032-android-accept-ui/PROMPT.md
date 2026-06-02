# Next Implementation Prompt — backlog (3d-android-ui): detail-screen **Accept** action (final 3d step)

**Backlog item (3) UX follow-ups, step 3d, final part (UI).** Add an **"Accept"** action to each
acceptable advisory on the plant detail screen: tapping it calls `repository.acceptAdvisory`
(landed `0031`) and reloads the plant's tasks/advisories so the new CareTask appears. **After this
lands, backlog item (3) UX follow-ups is COMPLETE.**

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`bfdd946108ffb31b45f66e80177e9aff9734e949` == `origin/master`, clean. `PlantDetailScreen` is a
**stateless** composable `PlantDetailScreen(state: PlantDetailUiState, modifier, onBack)`; its
private `AdvisoriesSection`/`AdvisoryRow` render each `Advisory` (`kind`/`severity`/`title`/
`message`) severity-styled. `PlantDetailViewModel.loadFor(plantId)` loads plant + task + advisories
into `PlantDetailUiState.Content`. `InventoryRepository.acceptAdvisory(plantId, kind): CareTask`
exists. `:app` `MainActivity.kt` `Routes.DETAIL` wires `PlantDetailViewModel` → `PlantDetailScreen`
(`LaunchedEffect(plantId){ vm.loadFor(plantId) }`). Detail UI tests: `PlantDetailAdvisoriesTest.kt`
(Robolectric), driving the stateless screen directly. Acceptable advisory kinds are
`container-size`/`support` (the backend 400s `pollination`).

Single logical change (the accept action: button + VM method + route wiring) → one commit.
Red→green.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the
per-advisory Accept action. Red-first: write the screen test first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect bfdd946108ffb31b45f66e80177e9aff9734e949 == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`InventoryTestTags.kt`** — add `const val ADVISORY_ACCEPT_BUTTON_PREFIX =
   "advisory_accept_"` (per-kind tag so multiple advisories are addressable).
2. **`PlantDetailScreen.kt`** — add a parameter `onAccept: (kind: String) -> Unit = {}` (after
   `state`, before `modifier`/`onBack`); thread it through `AdvisoriesSection` → `AdvisoryRow`. In
   `AdvisoryRow`, when `advisory.kind` is an **acceptable kind** (`"container-size"` or `"support"`),
   render a Material3 `Button` labelled "Accept" tagged
   `Modifier.testTag(InventoryTestTags.ADVISORY_ACCEPT_BUTTON_PREFIX + advisory.kind)` whose
   `onClick` calls `onAccept(advisory.kind)`. For other kinds (e.g. `"pollination"`) render **no**
   Accept button (it isn't a single actionable task). Keep the existing severity styling/text.
3. **`InventoryViewModels.kt`** — `PlantDetailViewModel`: add
   ```kotlin
   fun accept(plantId: String, kind: String) {
       viewModelScope.launch {
           try {
               repository.acceptAdvisory(plantId, kind)
               loadFor(plantId)            // reload so the new task + refreshed advisories show
           } catch (_: Exception) {
               loadFor(plantId)            // reload to keep state consistent; no crash
           }
       }
   }
   ```
4. **`:app` `MainActivity.kt`** — in the `Routes.DETAIL` composable, pass
   `onAccept = { kind -> vm.accept(plantId, kind) }` to `PlantDetailScreen` (alongside the existing
   `state`/`onBack`). No other route change.

### Tests — `PlantDetailAdvisoriesTest.kt`
Mirror the existing detail tests (drive the stateless screen with a `Content` state + a spy):
- **accept button shown for container-size + invokes callback**: build a `PlantDetailUiState.Content`
  whose `advisories` includes a `container-size` advisory; render `PlantDetailScreen(state = …,
  onAccept = { acceptedKind = it })`; assert the node tagged
  `ADVISORY_ACCEPT_BUTTON_PREFIX + "container-size"` is displayed; `performClick()`; assert
  `acceptedKind == "container-size"`.
- **no accept button for pollination**: a `Content` state whose only advisory is `pollination` →
  assert `onNodeWithTag(ADVISORY_ACCEPT_BUTTON_PREFIX + "pollination").assertDoesNotExist()`.
- (Keep the existing advisory-display test(s) green.)

### Forbidden
- No change to `:network`/`:data`/`:domain`/backend/`shared-schemas`/`supabase`. No new
  dependency. No on-device care logic — `accept` just calls the backend and reloads; the task is
  server-computed (D-09). No camera/photos/GPS/notifications/AI. Don't mount/repoint the SDK/Drive;
  don't commit `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Red→green: the new accept tests fail before the button/param exist; after, `:feature-inventory`
Robolectric tests pass (new accept tests green; all prior tests green) and `:app:assembleDebug`
compiles (the `vm.accept` route wiring type-checks). Report counts + new test names + assemble
result.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/feature-inventory/ android/app/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-inventory): accept-advisory action on the plant detail screen"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The Accept button (per-kind tag; shown only for container-size/support), the
   `PlantDetailViewModel.accept` (calls `acceptAdvisory` then reloads), and the `MainActivity`
   wiring.
2. `:feature-inventory:testDebugUnitTest` (count before→after; new tests green; prior green) +
   `:app:assembleDebug` result.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/feature-inventory/**` + `android/app/**` changed (not `local.properties`).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `feature-inventory/**`+`app/**`; Accept button + VM method + route wiring;
tests green; assemble OK). **Backlog item (3) UX follow-ups is then COMPLETE** — add-plant fully
selector-driven, email-OTP sign-in + gating, advisory→accept→CareTask end-to-end. Then **(2)
automated emulator e2e smoke** (instrumented test booting the app against the backend; the human
"add my real plants on my device" acceptance stays with the owner) — planner will ground the
instrumented-test setup (androidTest vs Robolectric, emulator availability) and **likely surface an
owner decision** (emulator/AVD availability, or whether to keep e2e at the Robolectric level). Then
**(4) Slice 3** (deterministic watering reminders; WorkManager local path first, then **STOP and
ask the owner for Firebase/FCM setup**). Vision-check each product-surface step.
