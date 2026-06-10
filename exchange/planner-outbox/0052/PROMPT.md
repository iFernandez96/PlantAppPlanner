# Implementation prompt 0052 — My Garden refreshes when you return to it (Wave 2 / W1 slice 5)

## 1. Scope (exactly one logical change)
**Bug (found in the 0051 on-device check):** a newly added plant does not appear in My Garden
until the app is force-stopped. `PlantListViewModel` loads only in `init` (`refresh()` at
`InventoryViewModels.kt:30–32`), and with the bottom-nav's `restoreState` the backstack entry —
and thus the ViewModel — survives navigation, so returning to the list never reloads.

Fix, two parts (one behavior: "the list is fresh when you look at it"):
1. **Quiet refresh** — `PlantListViewModel.refresh()` only shows the `Loading` spinner when
   there is no content yet; if current state is `Content`, keep showing it while reloading
   (replace state only when the new result arrives). Error behavior unchanged.
2. **Refresh on every visit** — in `MainActivity.kt`'s `composable(Routes.LIST)` block, the
   existing `LaunchedEffect(Unit) { … }` (the POST_NOTIFICATIONS one, lines ~86–94) gains a
   first line `vm.refresh()` (re-runs each time the list composable re-enters composition,
   i.e. on every return to the tab/screen).

Red-first: new `PlantListViewModelTest` proves the quiet-refresh behavior (fails on current code
because `refresh()` unconditionally sets `Loading`).

## 2. Forbidden changes
- Do NOT touch `:domain`, `:data`, `:network`, `:design-system`, backend, schemas, supabase,
  gradle/manifest. Do NOT change `ReminderSync` wiring, the reminder launch, or any other screen.
- Do NOT alter nav routes, tabs, restoreState behavior, or the detail/wizard flows.
- No new dependencies (`kotlinx-coroutines-test` is already a testImplementation dep).

## 3. Exact files to touch (3)
1. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryViewModels.kt`
   — `PlantListViewModel.refresh()` only:
   ```kotlin
   fun refresh() {
       if (_state.value !is PlantListUiState.Content) _state.value = PlantListUiState.Loading
       viewModelScope.launch {
           _state.value = try {
               val plants = repository.getPlants()
               viewModelScope.launch { runCatching { reminderSync.syncNow() } }
               if (plants.isEmpty()) PlantListUiState.Empty else PlantListUiState.Content(plants)
           } catch (e: Exception) {
               PlantListUiState.Error(e.message ?: "unknown error")
           }
       }
   }
   ```
   (only the first line changes; keep the comment that's currently inside.)
2. `android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt` — inside
   `composable(Routes.LIST)`, add `vm.refresh()` as the first statement of the existing
   `LaunchedEffect(Unit)` block (keep the permission logic after it).
3. NEW `android/feature-inventory/src/test/kotlin/dev/plantapp/feature/inventory/PlantListViewModelTest.kt`
   — plain JUnit + `kotlinx-coroutines-test`, using the `Dispatchers.setMain(UnconfinedTestDispatcher())`
   pattern from `NavSmokeTest.kt` and a small fake `InventoryRepository` (reuse/adapt
   `NavSmokeFakes.kt` if convenient — read it first). Three tests:
   - first load: state goes `Loading` → `Content` (or `Empty`).
   - **quiet refresh (the red one):** drive state to `Content(1 plant)`, make the fake now return
     2 plants, call `refresh()`, assert state NEVER becomes `Loading` (it stays `Content` and
     ends as `Content(2 plants)`). On current code this fails because `refresh()` sets `Loading`.
   - refresh after error: from `Error`, `refresh()` shows `Loading` then result (spinner allowed
     when there's nothing useful on screen).

## 4. Baseline precondition (STOP-and-report if different)
- Repo `/home/israel/Documents/Development/PlantApp`, branch `master`.
- Expected HEAD: `e72607095ad2d5636a744501a4c002bc18fc09b0` (0051).
- Tree clean except untracked `android/.kotlin/` (leave it). Otherwise STOP + BLOCKED report.

## 5. Exact commands
```bash
cd /home/israel/Documents/Development/PlantApp
git rev-parse HEAD && git status --porcelain
# 1) RED: add ONLY PlantListViewModelTest, run:
cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
#    -> expect exactly the quiet-refresh test to FAIL (Loading observed). Capture the line.
# 2) GREEN: apply §3.1 + §3.2, re-run:
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
```

## 6. Expected failure mode
Red step: only the quiet-refresh test fails. (If the first-load or error tests also fail, your
fake/dispatcher setup is wrong — fix the test, not the production code.) Green step: full suite
passes; anything else is a regression: STOP, revert, report.

## 7. Standalone verification
- **Type:** red-first → green (VM behavior) + device follow-up by the planner (add plant →
  return to list → plant visible without restart).
- **Commands & what they prove:** the §5 red output (guards the bug), the §5 green suite run
  (fix + no regression; report the new total test count), `grep -n "vm.refresh()"
  android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt` → 1 match inside the LIST
  composable, `:app:assembleDebug` → BUILD SUCCESSFUL.
- **Report:** all outputs verbatim.

## 8. Commit title (exact)
```
fix(ui): refresh My Garden on every visit and reload quietly when content is shown
```

## 9. Push requirement
Commit and push to `origin master` (fast-forward expected). One change → one commit → one push.

## 10. Final-report requirements
Report to `exchange/implementation-inbox/0052/`: `git show --stat HEAD` (exactly the 3 files),
red+green evidence, new test count, new commit hash, push confirmation (new `origin/master`),
scope confirmation.
