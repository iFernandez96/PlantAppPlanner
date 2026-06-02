# DONE — handoff 0028-android-signin-ui (3c-ui, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** email-OTP **sign-in screen** + `SignInViewModel` over the `0027` `AuthRepository`, and
`:app` **gating** (no token → sign-in; token → plant list). `:feature-inventory` Robolectric tests
green; `:app:assembleDebug` OK. **3c (sign-in) is now complete.** Final `origin/master` =
`e76ff8d9ce916bda6a7754cc400a2e7211000678`.

## Baseline + unblock
- HEAD at start = `28f69ea…` == origin/master; clean. SDK resolves (Drive mounted).

## What was added
1. **`InventoryTestTags.kt`** — `FIELD_SIGNIN_EMAIL`, `SIGNIN_SEND_CODE_BUTTON`,
   `FIELD_SIGNIN_CODE`, `SIGNIN_VERIFY_BUTTON`, `SIGNIN_ERROR`.
2. **`SignInScreen.kt`** (new) — stateless composable
   `SignInScreen(codeSent, error, onRequestCode, onVerify, modifier)`:
   - Always: email `OutlinedTextField` (`FIELD_SIGNIN_EMAIL`) + "Send code" `Button`
     (`SIGNIN_SEND_CODE_BUTTON`) → `onRequestCode(email.trim())` when email non-blank.
   - When `codeSent`: code field (`FIELD_SIGNIN_CODE`) + "Verify" `Button`
     (`SIGNIN_VERIFY_BUTTON`) → `onVerify(email.trim(), code.trim())`.
   - When `error != null`: a `Text` (`SIGNIN_ERROR`) in the error color.
   - `email`/`code` are the screen's own `remember { mutableStateOf("") }`; `codeSent`/`error`
     are hoisted.
3. **`InventoryUiState.kt`** — `data class SignInUiState(codeSent = false, error = null)`.
4. **`InventoryViewModels.kt`** — `@HiltViewModel class SignInViewModel @Inject constructor(auth:
   AuthRepository)`: `StateFlow<SignInUiState>`; `requestCode(email)` → `auth.requestOtp` then
   `codeSent = true` (error captured on failure); `verify(email, code, onSignedIn)` →
   `auth.verifyOtp` then `onSignedIn()` (error captured on failure).
5. **`:app` `MainActivity.kt`** — `@Inject lateinit var settings: SettingsStore`;
   `startDestination = if (settings.tokenBlocking() != null) LIST else SIGN_IN`; added
   `Routes.SIGN_IN = "signin"` + a `composable(SIGN_IN)` wiring `SignInViewModel` →
   `SignInScreen`, where verify navigates to `LIST` with `popUpTo(SIGN_IN) { inclusive = true }`.
   LIST/ADD/DETAIL unchanged.

## Tests (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 26s
```
- New **`SignInScreenTest`** (Robolectric, `@Config(sdk=[34], qualifiers="w411dp-h2000dp")`):
  **3 tests, 0 failures** —
  - `enter email and tap send invokes onRequestCode` — captured `"a@b.test"`.
  - `with codeSent, enter code and tap verify invokes onVerify` — captured `("a@b.test","123456")`.
  - `error is shown` — `SIGNIN_ERROR` + the message displayed.
- `:feature-inventory` total **11 → 14** (SignInScreenTest 3 + InventoryScreensTest 9 +
  PlantDetailAdvisoriesTest 2). All green.
- **`:app:assembleDebug` BUILD SUCCESSFUL** (gate + route + `SettingsStore` injection type-check
  through Hilt/KSP).

## Commit
- `e76ff8d` — feat(android-inventory): email-OTP sign-in screen + app gating
- `git show --stat HEAD`: 6 files, +223 −3 — only `android/feature-inventory/**` (2 main edits,
  1 new main, 1 new test) + `android/app/**` (MainActivity). `local.properties` NOT committed
  (grep 0).

## Compliance
- No `:network`/`:data`/`:domain`/backend/`shared-schemas`/`supabase` change. No new Gradle
  module, no new dependency. Email-OTP only (no password/social UI). No
  camera/photos/GPS/notifications/AI. SDK/Drive untouched.

Final `origin/master` SHA: `e76ff8d9ce916bda6a7754cc400a2e7211000678`

## Next (3d, per planner follow-up)
Advisory → **accept** → CareTask: a backend endpoint creating a CareTask from an advisory on
explicit user acceptance, **routed through the care engine (not auto-created)**, + an Android
"accept" action. Likely decomposed (backend half + Android half).
