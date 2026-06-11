# Implementation report — 0058-signin-hearth-polish

## Status: DONE

## 1. Scope confirmation + git show --stat HEAD
Only the 5 listed files changed:
```
 .../kotlin/dev/plantapp/android/MainActivity.kt    |   1 +
 .../plantapp/feature/inventory/InventoryUiState.kt |   2 +
 .../feature/inventory/InventoryViewModels.kt       |  13 ++-
 .../dev/plantapp/feature/inventory/SignInScreen.kt | 106 +++++++++++++--------
 .../plantapp/feature/inventory/SignInScreenTest.kt |  21 ++++
 5 files changed, 101 insertions(+), 42 deletions(-)
```
- `SignInScreen.kt` — Hearth re-skin per §5c: `fillMaxSize` + 20.dp Column, vertically
  centered; "Welcome" `headlineLarge` (Fraunces via the type scale, no manual fontFamily);
  helper copy in `bodyLarge`/`onSurfaceVariant`; form inside a non-clickable `GlassCard`
  (20.dp inner padding, 12.dp spacing); email field with `KeyboardType.Email`; send button
  `enabled = email.isNotBlank() && !busy`, text "Sending…"/"Send me a code" (re-send still
  calls `onRequestCode(email.trim())` when codeSent); codeSent → "We emailed a code to …"
  line, "6-digit code" field with `KeyboardType.Number`, "Sign in" button
  `enabled = code.isNotBlank() && !busy`; error text in `colorScheme.error`/`bodyMedium`.
  All five test tags keep their exact names on the same logical elements. Stateless
  (email/code in `remember`); KDoc updated. New `busy: Boolean = false` param inserted after
  `error` — existing callers use named args, so nothing else changed.
- `InventoryUiState.kt` — `SignInUiState.busy: Boolean = false` (verbatim §5a).
- `InventoryViewModels.kt` — `SignInViewModel.requestCode`/`verify` per §5b: busy true while
  in flight, fixed friendly error copy; raw `e.message` no longer reaches the state.
- `MainActivity.kt` — SIGN_IN composable passes `busy = state.busy` (1 line).
- `SignInScreenTest.kt` — the §7 red test + the §7 step-3 busy test (+2 imports).
Untracked `android/.kotlin/` left alone; no design-system/backend/schema/migration changes;
no new dependencies.

## 2. RED evidence (§7 step 1 — test added against the OLD signature)
```
SignInScreenTest > send button is disabled while the email is blank FAILED
    java.lang.AssertionError at SignInScreenTest.kt:66
4 tests completed, 1 failed
```
(The `assertIsNotEnabled` assertion — the button was unconditionally enabled on baseline.)
Exactly one failure, as the prompt predicted.

## 3. GREEN output
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 1m 8s
143 actionable tasks: 20 executed, 123 up-to-date
```
JUnit XML aggregate: **feature-inventory: tests=36 failures+errors=0**
(34 from 0057 + 2 new SignInScreenTest cases; SignInScreenTest's original 3 and
NavSmokeTest all still pass). `:app:assembleDebug` BUILD SUCCESSFUL (same invocation).

## 4. Grep proof
```
$ sed -n '/class SignInViewModel/,/^}/p' feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryViewModels.kt | grep -c "e.message"
0
```
✓ no raw exception text reaches the sign-in UI.

## 5. Commit + push
- New commit: `4517f4482bf169a21bba22964188ef69210f42bd`
- Title (exact): `feat(ui): Hearth sign-in screen — friendly copy, busy state, no raw errors`
- One commit (red test + implementation + busy test together, per §8).
- Pushed: `4b3910c..4517f44  master -> master` (fast-forward);
  new `origin/master` = `4517f4482bf169a21bba22964188ef69210f42bd`.

## 6. Deviations
None.
