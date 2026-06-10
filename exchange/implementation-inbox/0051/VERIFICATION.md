# Standalone verification — 0051

Type: red-first → green (the new constraint test is the standalone proof).

## 1. RED (new test only, before the fix)
```
AddPlantWizardModelTest > location preset kinds are accepted by the garden_spaces DB constraint FAILED
    java.lang.IllegalStateException at AddPlantWizardModelTest.kt:47
26 tests completed, 1 failed
```
JUnit XML failure message (verbatim):
```
java.lang.IllegalStateException: preset 'Windowsill' sends invalid kind 'windowsill'
```
Proves the test really guards the bug; no other failure in the red run.

## 2. GREEN (after the fix)
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
BUILD SUCCESSFUL in 20s
91 actionable tasks: 9 executed, 82 up-to-date
```
JUnit XML aggregate: **tests=26 failures+errors=0**. ✓

## 3. Greps
```
$ grep -c "window-ledge\|indoor-room" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/WizardModel.kt
2
$ grep -c "\"yard\"\|\"windowsill\"\|\"indoor\"" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/WizardModel.kt android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/WizardIcons.kt
android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/WizardModel.kt:0
android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/WizardIcons.kt:0
```
✓ new kinds present (2), old kinds gone (0 in both files).

## 4. App compiles end-to-end
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
BUILD SUCCESSFUL in 3s
125 actionable tasks: 5 executed, 4 from cache, 116 up-to-date
```
✓
