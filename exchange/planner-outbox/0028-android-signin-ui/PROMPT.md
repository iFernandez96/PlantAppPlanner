# Next Implementation Prompt — backlog (3c-ui): email-OTP **sign-in screen** + `:app` gating

**Backlog item (3) UX follow-ups, step 3c (sign-in), part 3 of 3 (UI).** Add the sign-in screen
(email → "Send code" → enter code → "Verify") over a `SignInViewModel` on the `0027`
`AuthRepository`, and **gate** the app: show sign-in when there is no token, the plant list once
signed in. After this, 3c is complete.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`28f69ea34cc38089a8c3906cc5a9ce9b55cdf47b` == `origin/master`, clean. `:domain` has
`AuthRepository` (`suspend requestOtp(email)`, `suspend verifyOtp(email, code)` — persists the
token on success). `:data` `SettingsStore.tokenBlocking(): String?` returns the current token (or
null). `:feature-inventory` has Compose screens + `@HiltViewModel`s + `InventoryTestTags` +
Robolectric tests (`InventoryScreensTest.kt`, `@Config(sdk=[34])`), and already depends on
`:domain`. `:app` `MainActivity.kt` is `@AndroidEntryPoint` with a `PlantAppNavHost()` (`Routes`:
LIST `"plants"`, ADD `"plants/add"`, DETAIL `"plants/{plantId}"`, `startDestination = LIST`).
Put the sign-in screen/VM in **`:feature-inventory`** (the existing feature module — no new Gradle
module).

Single logical change (sign-in screen + VM + `:app` gating) → one commit. Red→green.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the
email-OTP sign-in screen + gating. Red-first: write the screen test first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect 28f69ea34cc38089a8c3906cc5a9ce9b55cdf47b == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`InventoryTestTags.kt`** — add: `FIELD_SIGNIN_EMAIL = "field_signin_email"`,
   `SIGNIN_SEND_CODE_BUTTON = "signin_send_code_button"`, `FIELD_SIGNIN_CODE =
   "field_signin_code"`, `SIGNIN_VERIFY_BUTTON = "signin_verify_button"`, `SIGNIN_ERROR =
   "signin_error"`.
2. **`feature-inventory/.../SignInScreen.kt`** (new) — a **stateless** composable:
   ```kotlin
   @Composable fun SignInScreen(
       codeSent: Boolean,
       error: String?,
       onRequestCode: (email: String) -> Unit,
       onVerify: (email: String, code: String) -> Unit,
       modifier: Modifier = Modifier,
   )
   ```
   - Always shows an email `OutlinedTextField` (`FIELD_SIGNIN_EMAIL`) + a "Send code" `Button`
     (`SIGNIN_SEND_CODE_BUTTON`) that calls `onRequestCode(email.trim())` when email is non-blank.
   - When `codeSent` is true, also shows a code `OutlinedTextField` (`FIELD_SIGNIN_CODE`) + a
     "Verify" `Button` (`SIGNIN_VERIFY_BUTTON`) calling `onVerify(email.trim(), code.trim())`.
   - When `error != null`, shows a `Text` tagged `SIGNIN_ERROR` with the message.
   - Keep `email`/`code` as local `remember { mutableStateOf("") }` (the screen owns its inputs;
     `codeSent`/`error` are hoisted state).
3. **`feature-inventory/.../InventoryViewModels.kt`** — add a `@HiltViewModel class
   SignInViewModel @Inject constructor(private val auth: AuthRepository) : ViewModel()`:
   - `data class SignInUiState(val codeSent: Boolean = false, val error: String? = null)` exposed
     as `StateFlow<SignInUiState>` (define the data class in `InventoryUiState.kt`).
   - `fun requestCode(email: String)` → `viewModelScope.launch { try { auth.requestOtp(email);
     _state.update { it.copy(codeSent = true, error = null) } } catch (e: Exception) { _state.update
     { it.copy(error = e.message ?: "Could not send code") } } }`.
   - `fun verify(email: String, code: String, onSignedIn: () -> Unit)` → launch { try {
     auth.verifyOtp(email, code); onSignedIn() } catch (e) { _state.update { it.copy(error = e.message
     ?: "Invalid code") } } }`.
   (import `dev.plantapp.domain.repository.AuthRepository`.)
4. **`:app` `MainActivity.kt`** — gate + route:
   - `@AndroidEntryPoint MainActivity` already exists; inject `SettingsStore`
     (`@Inject lateinit var settings: SettingsStore`) — `:app` already depends on `:data`.
   - Add `Routes.SIGN_IN = "signin"`. Set `startDestination = if (settings.tokenBlocking() != null)
     Routes.LIST else Routes.SIGN_IN`.
   - Add a `composable(Routes.SIGN_IN)`: `val vm: SignInViewModel = hiltViewModel(); val state by
     vm.state.collectAsState(); SignInScreen(codeSent = state.codeSent, error = state.error,
     onRequestCode = vm::requestCode, onVerify = { email, code -> vm.verify(email, code) {
     nav.navigate(Routes.LIST) { popUpTo(Routes.SIGN_IN) { inclusive = true } } } })`.
   - Leave LIST/ADD/DETAIL unchanged.

### Tests — `feature-inventory/src/test/.../SignInScreenTest.kt` (new, Robolectric)
Mirror `InventoryScreensTest` (`@RunWith(RobolectricTestRunner::class) @Config(sdk=[34])`,
`createComposeRule`), drive the stateless screen with spies:
- `enter email and tap send invokes onRequestCode`: render `SignInScreen(codeSent=false,
  error=null, onRequestCode={captured=it}, onVerify={_,_->})`; type into `FIELD_SIGNIN_EMAIL`;
  click `SIGNIN_SEND_CODE_BUTTON`; assert `captured == "a@b.test"`.
- `with codeSent, enter code and tap verify invokes onVerify`: render with `codeSent=true`; type
  email + code; click `SIGNIN_VERIFY_BUTTON`; assert the spy got `("a@b.test","123456")`.
- `error is shown`: render with `error="Invalid code"`; assert `SIGNIN_ERROR` displays the text.

### Forbidden
- No change to `:network`, `:data` (beyond none), `:domain`, backend, `shared-schemas`,
  `supabase`. No new Gradle module, no new dependency. No camera/photos/GPS/notifications/AI. No
  password/social-login UI (email-OTP only). Don't mount/repoint the SDK/Drive; don't commit
  `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Red→green: the new `SignInScreenTest` fails before the screen exists; after, `:feature-inventory`
Robolectric tests pass (new sign-in tests green; all prior inventory tests still green) and
`:app:assembleDebug` compiles (gate + route + `SettingsStore` injection type-check). Report counts
+ new test names + assemble result.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/feature-inventory/ android/app/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-inventory): email-OTP sign-in screen + app gating"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. `SignInScreen` (tags + the codeSent/error hoisted state), `SignInViewModel`
   (requestCode/verify), and the `MainActivity` gate (token → start destination) + route + verify
   navigation.
2. `:feature-inventory:testDebugUnitTest` (count before→after; new tests green; prior green) +
   `:app:assembleDebug` result.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/feature-inventory/**` + `android/app/**` changed (not `local.properties`).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `feature-inventory/**`+`app/**`; screen + VM + gate; tests green; assemble
OK). **3c (sign-in) is then COMPLETE.** Then **3d**: advisory → **accept** → CareTask — a backend
endpoint that creates a CareTask from an advisory on explicit user acceptance, **routed through the
care engine (not auto-created)**, + an Android "accept" action; planner will ground it against the
advisories engine/API + the care-engine task path first (this has a backend half and an Android
half — likely decomposed). Then (2) emulator e2e smoke; then (4) Slice 3 (WorkManager local first;
STOP for owner Firebase/FCM setup). Vision-check each product-surface step.
