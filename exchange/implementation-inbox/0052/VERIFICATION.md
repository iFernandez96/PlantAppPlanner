# Standalone verification — 0052

Type: red-first → green (VM behavior); device follow-up by planner (add plant → return →
visible without restart).

## 1. RED (new test file only, before the fix)
```
PlantListViewModelTest > refreshOverVisibleContentNeverShowsTheSpinner FAILED
    java.lang.AssertionError at PlantListViewModelTest.kt:59
29 tests completed, 1 failed
```
(Failing assertion: "refresh over content must not flash the spinner" — Loading was observed.)
Only the quiet-refresh test failed; first-load + error tests passed → fake/dispatcher setup
sound, the test guards exactly the bug.

## 2. GREEN (after §3.1 + §3.2)
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
BUILD SUCCESSFUL in 27s
91 actionable tasks: 7 executed, 84 up-to-date
```
JUnit XML aggregate: **tests=29 failures+errors=0** (was 26). ✓

## 3. Refresh wired into the LIST composable
```
$ grep -n "vm.refresh()" android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt
162:                vm.refresh()
```
✓ 1 match, first statement of the LIST composable's `LaunchedEffect(Unit)`.

## 4. App compiles end-to-end
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
BUILD SUCCESSFUL in 15s
125 actionable tasks: 10 executed, 115 up-to-date
```
✓

## Diff evidence
```
 android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt       | 3 +++
 .../main/kotlin/dev/plantapp/feature/inventory/InventoryViewModels.kt  | 3 ++-
 (+ new PlantListViewModelTest.kt, 96 lines)
```
