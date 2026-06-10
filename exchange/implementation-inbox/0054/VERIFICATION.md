# Standalone verification — 0054

Type: red-first → green + planner device follow-up (backend down → visible error card).

## 1. RED (error-card test only, before the fix)
Compile-red — the missing parameter/tag is the expected red per §6 ("say which you saw":
compile error, not assertion):
```
e: file:///…/AddPlantWizardTest.kt:122:17 No parameter with name 'error' found.
e: file:///…/AddPlantWizardTest.kt:125:53 Unresolved reference 'WIZARD_ERROR'.
> Task :feature-inventory:compileDebugUnitTestKotlin FAILED
BUILD FAILED in 4s
```

## 2. GREEN (after §1 A+B)
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
BUILD SUCCESSFUL in 40s
91 actionable tasks: 9 executed, 82 up-to-date
```
JUnit XML aggregate: **tests=33 failures+errors=0** (was 30; +error-card, +confirm-copy,
+preset-phrases). ✓

## 3. Greps
```
$ grep -c "WIZARD_ERROR" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/AddPlantWizard.kt
1
$ grep -c 'to the $place' android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/AddPlantWizard.kt
0
```
✓ card wired; old copy gone.

## 4. App compiles end-to-end
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
BUILD SUCCESSFUL in 18s
125 actionable tasks: 10 executed, 115 up-to-date
```
✓
