# Standalone verification — 0056

Type: red-first → green (manager behavior); live 401→refresh→retry is part 3's device check.

## 1. RED (SessionRefreshManagerTest only)
```
> Task :data:compileDebugUnitTestKotlin FAILED
e: file:///…/AuthRepositoryImplTest.kt:19:13 Class 'AuthRepositoryImplTest.FakeSupabaseAuthApi' is not abstract and does not implement abstract member 'refreshToken'.
e: file:///…/SessionRefreshManagerTest.kt:6:37 Unresolved reference 'SessionRefreshManager'.
e: file:///…/SessionRefreshManagerTest.kt:60:32 Unresolved reference 'setSession'.
```
(The AuthRepositoryImplTest error is the 0055 interface addition surfacing in `:data`'s test
fake — anticipated by §1C/§6 and fixed in green.)

## 2. GREEN (all three module suites)
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :data:testDebugUnitTest :network:testDebugUnitTest :feature-inventory:testDebugUnitTest
BUILD SUCCESSFUL in 42s
114 actionable tasks: 22 executed, 92 up-to-date
```
JUnit XML aggregates:
- **data: tests=18 failures+errors=0** (15 → 18; +3 SessionRefreshManagerTest)
- **network: tests=18 failures+errors=0** (unchanged)
- **feature-inventory: tests=33 failures+errors=0** (canary green — TokenWriter default kept
  fakes compiling)

## 3. Greps
```
$ grep -c "authenticator(" android/network/src/main/kotlin/dev/plantapp/network/PlantAppApiFactory.kt
1
$ grep -c "setSession" android/data/src/main/kotlin/dev/plantapp/data/repository/AuthRepositoryImpl.kt
1
```
✓

## 4. App compiles end-to-end
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
BUILD SUCCESSFUL in 14s
125 actionable tasks: 11 executed, 114 up-to-date
```
✓
