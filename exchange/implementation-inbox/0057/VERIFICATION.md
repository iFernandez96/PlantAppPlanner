# Standalone verification — 0057

Type: red-first → green; live end-to-end (expire token on device) is the planner's device
check after this lands.

## 1. RED (VM test case only)
```
> Task :feature-inventory:compileDebugUnitTestKotlin FAILED
e: file:///…/PlantListViewModelTest.kt:3:28 Unresolved reference 'SessionExpiredException'.
e: file:///…/PlantListViewModelTest.kt:83:58 Unresolved reference 'SessionExpiredException'.
e: file:///…/PlantListViewModelTest.kt:88:48 Unresolved reference 'SignedOut'.
```

## 2. GREEN (all suites; note :domain task is `:domain:test`)
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :domain:test :data:testDebugUnitTest :feature-inventory:testDebugUnitTest
BUILD SUCCESSFUL in 38s
111 actionable tasks: 25 executed, 86 up-to-date
```
JUnit XML aggregates:
- **domain: tests=9 failures+errors=0**
- **data: tests=18 failures+errors=0**
- **feature-inventory: tests=34 failures+errors=0** (was 33; +sessionExpiryMapsToSignedOutNotError;
  the pre-existing generic-error test still passes)

## 3. Greps
```
$ grep -c "SessionExpiredException" android/data/src/main/kotlin/dev/plantapp/data/repository/InventoryRepositoryImpl.kt
2
$ grep -c "SignedOut" android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt
1
```
✓ mapper wired (≥2); fallback nav wired (1).

## 4. App compiles end-to-end
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
BUILD SUCCESSFUL in 12s
125 actionable tasks: 12 executed, 113 up-to-date
```
✓
