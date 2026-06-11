# Standalone verification — 0059

Type: red-first → green.

## 1. RED (§7 step 1 — new VM test on baseline code)
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest --tests "dev.plantapp.feature.inventory.PlantListViewModelTest"
PlantListViewModelTest > loadErrorShowsFriendlyCopyNotRawExceptionText FAILED
    java.lang.AssertionError at PlantListViewModelTest.kt:93
5 tests completed, 1 failed
```
JUnit XML: `java.lang.AssertionError: raw exception text must not reach the UI`
— the error message was the raw exception string (with the LAN URL) on baseline.

## 2. GREEN (§7 step 4)
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 14s
143 actionable tasks: 17 executed, 126 up-to-date
```
JUnit XML aggregate: **tests=39 failures+errors=0** (actual count from XML; was 36, +3 new:
the VM red test + 2 DisplayText friendlyError tests). App assembles in the same invocation. ✓

## 3. Grep proof
```
$ grep -c "e.message" feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryViewModels.kt
0
```
✓ expected 0 (grep exits 1 on zero matches — pass condition, not an error).
