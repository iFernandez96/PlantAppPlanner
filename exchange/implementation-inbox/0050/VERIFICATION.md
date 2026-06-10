# Standalone verification — 0050

Type: green (behavioral copy change covered by updated + new unit tests), with red-first
evidence captured before the test edits.

## Red-first (after main-code edits, before test edits)
```
InventoryScreensTest > #23 detail shows the water task with rationale, engineVersion badge, and dueAt FAILED
PlantDetailAdvisoriesTest > showsAdvisoryTitleMessageAndSeverity FAILED
20 tests completed, 2 failed
```
(#23 = the expected red from §6; the advisories failure is the same prescribed copy change —
see REPORT.md deviation note.)

## 1. Badge + tag fully gone
```
$ grep -c "ENGINE_VERSION_BADGE\|engine v" .../PlantDetailScreen.kt .../InventoryTestTags.kt | grep -v :0 || echo CLEAN
CLEAN
```
✓

## 2. Jargon label gone
```
$ grep -c "Growth stage:" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/PlantDetailScreen.kt
0
```
✓

## 3. Tests green, count increased
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
BUILD SUCCESSFUL in 21s
91 actionable tasks: 9 executed, 82 up-to-date
```
JUnit XML aggregate: **tests=25 failures+errors=0** (up from 20: #23 updated, +5 new
DisplayTextTest cases). ✓

## 4. App compiles end-to-end
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
BUILD SUCCESSFUL in 6s
125 actionable tasks: 8 executed, 117 up-to-date
```
✓

## Diff evidence
```
 .../dev/plantapp/feature/inventory/DisplayText.kt  | 29 ++++++++++++++  (new)
 .../feature/inventory/InventoryTestTags.kt         |  1 -
 .../plantapp/feature/inventory/InventoryUiState.kt |  2 +
 .../feature/inventory/InventoryViewModels.kt       | 13 +++++-
 .../feature/inventory/PlantDetailScreen.kt         | 46 ++++++++++------------
 .../plantapp/feature/inventory/DisplayTextTest.kt  | 32 +++++++++++++++ (new)
 .../feature/inventory/InventoryScreensTest.kt      |  5 +--
 .../feature/inventory/PlantDetailAdvisoriesTest.kt |  3 +-  (deviation: old-copy assertion)
```
