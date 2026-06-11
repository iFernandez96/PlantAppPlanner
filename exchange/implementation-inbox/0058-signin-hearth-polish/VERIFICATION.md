# Standalone verification — 0058

Type: red-first → green (objective Compose-semantics evidence).

## 1. RED (§7 step 1 — new test against the old signature)
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest --tests "dev.plantapp.feature.inventory.SignInScreenTest"
SignInScreenTest > send button is disabled while the email is blank FAILED
    java.lang.AssertionError at SignInScreenTest.kt:66
4 tests completed, 1 failed
```
Exactly the one expected failure (assertIsNotEnabled — button was always enabled).

## 2. GREEN (§7 step 4)
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 1m 8s
143 actionable tasks: 20 executed, 123 up-to-date
```
JUnit XML aggregate: **tests=36 failures+errors=0** (was 34; +`send button is disabled
while the email is blank` and +`busy disables the send button even with an email entered`).
App assembles in the same invocation. ✓

## 3. Grep proof
```
$ sed -n '/class SignInViewModel/,/^}/p' feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryViewModels.kt | grep -c "e.message"
0
```
✓ (expected 0; grep exit 1 = zero matches, not an error)
