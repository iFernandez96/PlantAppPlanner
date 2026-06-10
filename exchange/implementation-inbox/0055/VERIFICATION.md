# Standalone verification — 0055

Type: red-first → green (serialization tests are the objective evidence; live refresh is
proven in parts 2/3 + a planner device check).

## 1. RED (DTO test only, before the DTO exists)
```
> Task :network:compileDebugUnitTestKotlin FAILED
e: file:///home/israel/Documents/Development/PlantApp/android/network/src/test/kotlin/dev/plantapp/network/AuthDtoTest.kt:33:43 Unresolved reference 'RefreshTokenRequest'.
BUILD FAILED in 7s
```

## 2. GREEN
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest
BUILD SUCCESSFUL in 5s
17 actionable tasks: 6 executed, 11 up-to-date
```
JUnit XML aggregate: **tests=18 failures+errors=0** (was 17). ✓

## 3. Endpoint present
```
$ grep -c "grant_type=refresh_token" android/network/src/main/kotlin/dev/plantapp/network/SupabaseAuthApi.kt
1
```
✓

## 4. App compiles end-to-end
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
BUILD SUCCESSFUL in 11s
125 actionable tasks: 15 executed, 4 from cache, 106 up-to-date
```
✓
