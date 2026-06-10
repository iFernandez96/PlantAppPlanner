# Implementation report — 0052-list-refresh-on-visit

## Status: DONE

## What was done
One behavior ("the list is fresh when you look at it"), two parts per §1:
1. **Quiet refresh** — `PlantListViewModel.refresh()` first line is now
   `if (_state.value !is PlantListUiState.Content) _state.value = PlantListUiState.Loading`
   (spinner only when there's nothing useful on screen; while `Content` is showing, the old
   list stays visible until the new result lands). Everything else in the method — including
   the reminder-sync comment and isolation — unchanged. Error path unchanged.
2. **Refresh on every visit** — in `MainActivity.kt`'s `composable(Routes.LIST)` block,
   `vm.refresh()` added as the first statement of the existing `LaunchedEffect(Unit)` (the
   POST_NOTIFICATIONS one; permission logic kept after it). The effect re-runs each time the
   list re-enters composition, i.e. on every return to the tab/screen, even though
   `restoreState` keeps the ViewModel alive.
3. NEW `PlantListViewModelTest.kt` — plain JUnit + kotlinx-coroutines-test
   (`StandardTestDispatcher` + `Dispatchers.setMain`; a `MutablePlantsRepo` built by interface-
   delegating to the existing `FakeInventoryRepository` with a mutable plant list + switchable
   failure; `reminderSync(repo)` no-op helper reused from `NavSmokeFakes.kt`). Three tests:
   - first load: `Loading` → `Content(1)`.
   - **quiet refresh (the red one):** `Content(1)` → fake now returns 2 plants → `refresh()` →
     state is never `Loading` (old content stays visible) → ends `Content(2)`.
   - refresh after error: `Error` → `refresh()` shows `Loading` → ends `Content`.

   Note on the "never Loading" assertion: the only synchronous state write in `refresh()` is
   the Loading gate (everything after runs inside the launched coroutine), so asserting
   immediately after `refresh()` under `StandardTestDispatcher` observes exactly that write —
   on pre-fix code the test fails there, which the red run confirmed. (`StandardTestDispatcher`
   rather than NavSmokeTest's Unconfined, because catching the intermediate state requires the
   reload to stay queued at assertion time.)

## Red evidence (§5 step 1: only the new test file added)
```
PlantListViewModelTest > refreshOverVisibleContentNeverShowsTheSpinner FAILED
    java.lang.AssertionError at PlantListViewModelTest.kt:59
29 tests completed, 1 failed
```
Exactly the quiet-refresh test; first-load and error tests passed in the red run.

## Green evidence (§5 step 2)
- `:feature-inventory:testDebugUnitTest` → BUILD SUCCESSFUL; JUnit XML aggregate
  **tests=29 failures+errors=0** (26 from 0051 + 3 new).
- `grep -n "vm.refresh()" android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt`
  → 1 match: `162:                vm.refresh()` (inside the LIST composable's LaunchedEffect).
- `:app:assembleDebug` → BUILD SUCCESSFUL.

## Baseline precondition
- HEAD before work: `e72607095ad2d5636a744501a4c002bc18fc09b0` ✓
- Tree clean except untracked `android/.kotlin/` (left alone) ✓

## Commit + push
- New commit: `a22292988b9a32c5aa04433da6e3485a189a9933`
- Title (exact): `fix(ui): refresh My Garden on every visit and reload quietly when content is shown`
- Pushed: `e726070..a222929  master -> master`; new `origin/master` =
  `a22292988b9a32c5aa04433da6e3485a189a9933`

### git show --stat HEAD
```
 .../kotlin/dev/plantapp/android/MainActivity.kt    |  3 +
 .../feature/inventory/InventoryViewModels.kt       |  3 +-
 .../feature/inventory/PlantListViewModelTest.kt    | 96 ++++++++++++++++++++++
 3 files changed, 101 insertions(+), 1 deletion(-)
```
Exactly the 3 files. ✓

## Scope confirmation
- No `:domain`/`:data`/`:network`/`:design-system`/backend/schema/supabase/gradle/manifest
  changes; ReminderSync wiring, reminder launch, nav routes/tabs/restoreState, detail/wizard
  flows all untouched; no new dependencies; `android/.kotlin/` left untracked.
- Device follow-up for the planner: add plant → return to list → plant visible without restart.
