# Standalone verification — 0053

Type: red-first → green + planner device follow-up (friendly names + icons, 104dp rows).

## 1. RED (new test + state-field-only, before any rendering change)
```
InventoryScreensTest > list rows show the friendly species name, never the profile slug FAILED
    java.lang.AssertionError at InventoryScreensTest.kt:60
30 tests completed, 1 failed
```
Only the new test failed — it guards the slug leak. (The §1.1 `speciesNames` field had to be
added for the test to compile; it has a default and changed no rendering, so the red is a true
behavioral red, not a compile error.)

## 2. GREEN (after §1.2–1.3)
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
BUILD SUCCESSFUL in 24s
91 actionable tasks: 10 executed, 81 up-to-date
```
JUnit XML aggregate: **tests=30 failures+errors=0** (was 29). ✓

## 3. Greps
```
$ grep -c "prettify" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/PlantDetailScreen.kt
0
$ grep -c "speciesIconRes" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/PlantListScreen.kt
1
```
✓ helper unified; icon wired.

## 4. App compiles end-to-end
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
BUILD SUCCESSFUL in 7s
125 actionable tasks: 8 executed, 117 up-to-date
```
✓
