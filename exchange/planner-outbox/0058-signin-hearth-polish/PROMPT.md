# Implementation prompt 0058 — Hearth sign-in screen polish (W1 remainder)

You are the implementation Claude for PlantApp. Apply exactly ONE logical change:
re-skin the email-OTP sign-in screen to the Garden Hearth design language with
beginner-first copy, a busy state, and friendly (non-technical) error messages.

## 1. Scope — one logical change

Sign-in screen polish only:

- **`SignInScreen.kt`** — Hearth re-skin: content inside a `GlassCard`, Fraunces
  headline, plain-language helper copy, proper keyboard types, button
  enabled/disabled + busy states, friendlier labels. All five existing test tags
  keep their exact names and stay attached to the same logical elements.
- **`SignInUiState`** — add `val busy: Boolean = false`.
- **`SignInViewModel`** — set `busy` true while a request is in flight; replace
  raw `e.message` leakage with fixed friendly copy.
- **`MainActivity.kt`** — pass `busy = state.busy` through to the screen.
- **`SignInScreenTest.kt`** — red-first test additions (see §7).

## 2. Forbidden changes — do NOT touch

- `android/design-system/**` (no token/component changes — consume `GlassCard` as-is).
- `PlantListScreen.kt`, `PlantDetailScreen.kt`, `addplant/**`, `PlaceholderScreens.kt`.
- Any other ViewModel's error handling (PlantListViewModel etc. still use
  `e.message` — out of scope, tracked separately).
- `InventoryTestTags.kt` — tag names are frozen.
- `NavSmokeTest.kt`, `NavSmokeFakes.kt` and every other existing test file.
- Backend (`backend/**`), schemas (`shared-schemas/**`), migrations (`supabase/**`).
- No new dependencies, no version bumps, no `gradle.properties` changes.
- Do NOT `git add` the untracked `android/.kotlin/` tooling dir if present.

## 3. Exact files to touch (repo-relative, all existing)

1. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/SignInScreen.kt`
2. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryUiState.kt`
3. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryViewModels.kt`
4. `android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt`
5. `android/feature-inventory/src/test/kotlin/dev/plantapp/feature/inventory/SignInScreenTest.kt`

## 4. Baseline precondition — STOP if it doesn't hold

```bash
git -C /home/israel/Documents/Development/PlantApp rev-parse HEAD   # must be 4b3910cabf30167b0e30d37eecf98a6ed14430cd
git -C /home/israel/Documents/Development/PlantApp status --short   # must be clean (untracked android/.kotlin/ is OK — leave it)
git -C /home/israel/Documents/Development/PlantApp branch --show-current  # must be master
```

If HEAD differs, the branch isn't master, or there are tracked modifications:
**STOP and write a BLOCKED report** — do not apply this prompt to a moved tree.

## 5. Exact changes

### 5a. `InventoryUiState.kt` — add `busy`

Old:
```kotlin
/** UI state for the email-OTP sign-in screen. */
data class SignInUiState(
    val codeSent: Boolean = false,
    val error: String? = null,
)
```
New:
```kotlin
/** UI state for the email-OTP sign-in screen. */
data class SignInUiState(
    val codeSent: Boolean = false,
    val error: String? = null,
    /** True while a send-code or verify request is in flight (disables the buttons). */
    val busy: Boolean = false,
)
```

### 5b. `InventoryViewModels.kt` — `SignInViewModel` busy + friendly errors

Replace the bodies of `requestCode` and `verify` (currently lines ~143–163;
they `catch (e: Exception)` and surface `e.message`). New behavior:

```kotlin
    fun requestCode(email: String) {
        viewModelScope.launch {
            _state.update { it.copy(busy = true, error = null) }
            try {
                auth.requestOtp(email)
                _state.update { it.copy(codeSent = true, busy = false) }
            } catch (e: Exception) {
                _state.update {
                    it.copy(busy = false, error = "We couldn't send the code. Check the email address and try again.")
                }
            }
        }
    }

    fun verify(email: String, code: String, onSignedIn: () -> Unit) {
        viewModelScope.launch {
            _state.update { it.copy(busy = true, error = null) }
            try {
                auth.verifyOtp(email, code)
                onSignedIn()
            } catch (e: Exception) {
                _state.update {
                    it.copy(busy = false, error = "That code didn't work. Check the digits and try again.")
                }
            }
        }
    }
```

Raw `e.message` must no longer reach `SignInUiState.error` (it leaked exception
text / LAN IPs to a beginner audience). If the compiler warns about the unused
`e` binding, rename it to `_` is NOT valid for catch — leave it as `e` and
ignore the warning (no lint gate is configured for Android).

### 5c. `SignInScreen.kt` — Hearth re-skin

Rewrite the composable. Requirements (keep the same package + name):

- New signature — **add `busy: Boolean = false`** after `error`, keep everything
  else so `NavSmokeTest` (which omits it) still compiles:
  ```kotlin
  fun SignInScreen(
      codeSent: Boolean,
      error: String?,
      busy: Boolean = false,
      onRequestCode: (email: String) -> Unit,
      onVerify: (email: String, code: String) -> Unit,
      modifier: Modifier = Modifier,
  )
  ```
  NOTE: existing callers pass `onRequestCode`/`onVerify` as **named** args
  (MainActivity, SignInScreenTest, NavSmokeTest), so inserting `busy` before
  them is safe.
- Layout: a `Column` (fillMaxSize, 20.dp padding, centered vertically) holding:
  - Headline `Text("Welcome", style = MaterialTheme.typography.headlineLarge)`
    (Fraunces serif comes from the Hearth type scale — do not set fontFamily by hand).
  - Helper copy below it, `bodyLarge`, `onSurfaceVariant` color:
    `"We'll email you a one-time code — no password to remember."`
  - A `GlassCard` (import `dev.plantapp.designsystem.GlassCard`, non-clickable
    overload, default shape/elevations) with inner padding 20.dp and
    `Arrangement.spacedBy(12.dp)` containing the form:
    - Email `OutlinedTextField` — label `"Email"`, `singleLine`,
      `KeyboardOptions(keyboardType = KeyboardType.Email)`, existing tag
      `InventoryTestTags.FIELD_SIGNIN_EMAIL`.
    - Send `Button` — tag `InventoryTestTags.SIGNIN_SEND_CODE_BUTTON`,
      **`enabled = email.isNotBlank() && !busy`**, text:
      `"Sending…"` when `busy && !codeSent`, else `"Send me a code"`
      (when `codeSent`, it re-sends — keep calling `onRequestCode(email.trim())`).
    - When `codeSent`: a `bodyMedium` line
      `"We emailed a code to ${email.trim()}. It can take a minute to arrive."`,
      then the code `OutlinedTextField` — label `"6-digit code"`, `singleLine`,
      `KeyboardOptions(keyboardType = KeyboardType.Number)`, tag
      `InventoryTestTags.FIELD_SIGNIN_CODE` — then the verify `Button` — tag
      `InventoryTestTags.SIGNIN_VERIFY_BUTTON`,
      **`enabled = code.isNotBlank() && !busy`**, text `"Sign in"`.
    - When `error != null`: `Text(error, color = MaterialTheme.colorScheme.error,
      style = MaterialTheme.typography.bodyMedium)` with tag
      `InventoryTestTags.SIGNIN_ERROR` (unchanged).
- Needed imports: `KeyboardOptions` (`androidx.compose.foundation.text`),
  `KeyboardType` (`androidx.compose.ui.text.input`), `fillMaxSize`,
  `Arrangement`, `GlassCard`.
- Keep the screen **stateless** (email/code in `remember { mutableStateOf("") }`,
  everything else hoisted) and update the KDoc.

### 5d. `MainActivity.kt` — pass busy

In the `composable(Routes.SIGN_IN)` block (~line 138), old:
```kotlin
            SignInScreen(
                codeSent = state.codeSent,
                error = state.error,
```
New:
```kotlin
            SignInScreen(
                codeSent = state.codeSent,
                error = state.error,
                busy = state.busy,
```

## 6. Expected failure modes (not regressions)

- Red-first step (§7 step 1): exactly ONE new test fails with an
  `assertIsNotEnabled` assertion error — that is the expected red.
- Gradle configure-time deprecation warnings: pre-existing, ignore.
- Do not run backend tests (`npm test` etc.) — backend is untouched.

## 7. Standalone verification (red → green, objective)

All commands from `/home/israel/Documents/Development/PlantApp/android` with
`GRADLE_USER_HOME=/tmp/plantapp-gradle-home`.

**Step 1 — RED.** Add ONE test to `SignInScreenTest.kt` (compiles against the
CURRENT signature — no `busy` param yet):

```kotlin
    @Test
    fun `send button is disabled while the email is blank`() {
        composeRule.setContent {
            SignInScreen(codeSent = false, error = null, onRequestCode = {}, onVerify = { _, _ -> })
        }
        composeRule.onNodeWithTag(InventoryTestTags.SIGNIN_SEND_CODE_BUTTON).assertIsNotEnabled()
        composeRule.onNodeWithTag(InventoryTestTags.FIELD_SIGNIN_EMAIL).performTextInput("a@b.test")
        composeRule.onNodeWithTag(InventoryTestTags.SIGNIN_SEND_CODE_BUTTON).assertIsEnabled()
    }
```
(imports: `assertIsEnabled`, `assertIsNotEnabled` from `androidx.compose.ui.test`)

Run:
```bash
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest --tests "dev.plantapp.feature.inventory.SignInScreenTest"
```
**Expected: the new test FAILS** (the button is currently always enabled).
Capture the failure line for the report. If it passes, STOP — the baseline
isn't what this prompt assumes.

**Step 2 — implement** §5a–§5d.

**Step 3 — add the busy test** (now that the param exists):
```kotlin
    @Test
    fun `busy disables the send button even with an email entered`() {
        composeRule.setContent {
            SignInScreen(codeSent = false, error = null, busy = true, onRequestCode = {}, onVerify = { _, _ -> })
        }
        composeRule.onNodeWithTag(InventoryTestTags.FIELD_SIGNIN_EMAIL).performTextInput("a@b.test")
        composeRule.onNodeWithTag(InventoryTestTags.SIGNIN_SEND_CODE_BUTTON).assertIsNotEnabled()
    }
```

**Step 4 — GREEN (this is the standalone verification):**
```bash
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Proves: full `:feature-inventory` suite green (existing tests — including
`SignInScreenTest`'s original 3 and `NavSmokeTest` — unbroken; 2 new tests
green) AND the app still assembles. Report the total executed/passed test count
from the Gradle output (do not assume a number).

**Grep proof (include output in the report):**
```bash
sed -n '/class SignInViewModel/,/^}/p' feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryViewModels.kt | grep -c "e.message"
```
**Expected: `0`** — no raw exception text reaches the sign-in UI.

## 8. Commit title (Conventional Commits, exact)

```
feat(ui): Hearth sign-in screen — friendly copy, busy state, no raw errors
```

One commit only (red test + implementation + busy test together; the red
evidence lives in the report).

## 9. Push requirement

`git push origin master` after the commit — expect a fast-forward from
`4b3910c`. Confirm the new `origin/master` SHA in the report.

## 10. Final report requirements

Write the report to `exchange/implementation-inbox/0058-signin-hearth-polish/`
via `scripts/exchange-create-implementation-report.sh`. Include:

1. Scope confirmation (only the 5 listed files changed) + `git show --stat HEAD`.
2. The RED evidence from §7 step 1 (failing assertion output).
3. The GREEN output summary: test totals + `BUILD SUCCESSFUL` for assembleDebug.
4. The grep proof (`0`).
5. New commit hash + push confirmation (new `origin/master`).
6. Any deviation from this prompt, called out explicitly (or "none").
