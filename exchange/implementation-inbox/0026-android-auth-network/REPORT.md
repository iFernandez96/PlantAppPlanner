# DONE — handoff 0026-android-auth-network (3c-net, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** `:network` Supabase GoTrue **email-OTP** auth client added (API + DTOs +
factory) with round-trip/lenient-decode tests. `:network` unit tests green.
Final `origin/master` = `a2f5e75ec8d4307155933d7cc04b7045ef97a6b4`.

## Baseline + unblock
- HEAD at start = `8d5187490e9171cf32a62c42a1ff2530bdd2dd0b` == origin/master; clean.
- SDK resolves (Drive mounted).

## What was added (`:network` only)
- `AuthDtos.kt` — GoTrue DTOs with snake_case wire names via `@SerialName`:
  - `OtpRequest(email, @SerialName("create_user") createUser = true)`
  - `VerifyOtpRequest(email, token, type = "email")`
  - `SessionResponse(@SerialName("access_token") accessToken, token_type?, expires_in?,
    refresh_token?)` — extra GoTrue fields (`user`, …) ignored on decode.
- `SupabaseAuthApi.kt` — Retrofit interface:
  - `POST auth/v1/otp` → `requestOtp(OtpRequest): Response<Unit>`
  - `POST auth/v1/verify` → `verifyOtp(VerifyOtpRequest): SessionResponse`
- `SupabaseAuthApiFactory.kt` — `create(authBaseUrl, anonKey)`: Retrofit + OkHttp +
  kotlinx converter; an OkHttp interceptor sets the public **`apikey: <anonKey>`** header on
  every request (GoTrue requires it for unauthenticated otp/verify); `BASIC` logging
  ("request line + status only; no bodies/PII" — emails/OTP codes never logged). Its `Json`
  uses `encodeDefaults = true` so the GoTrue-required defaults (`create_user`, `type`) are
  actually sent. `authBaseUrl`/`anonKey` are caller-supplied (nothing hard-coded).

## Tests (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest
BUILD SUCCESSFUL in 9s
```
- New `AuthDtoTest`: **3 tests, 0 failures** — `otpRequestEncodesSnakeCaseCreateUserAndRoundTrips`
  (asserts the JSON contains `"create_user"`, not `createUser`, + round-trip),
  `verifyOtpRequestEncodesFieldsAndRoundTrips`, and
  `sessionResponseDecodesGoTrueJsonIgnoringUnknownKeys` (decodes a GoTrue body with an
  unknown `user` key → `accessToken == "abc.def.ghi"`). Tests use the production
  `SupabaseAuthApiFactory.json` (encodeDefaults=true) so the `create_user` assertion is
  meaningful.
- All prior `:network` tests (DTOs, schema validation, advisory) still green.

## Commit
- `a2f5e75` — feat(android-network): Supabase GoTrue email-OTP auth client
- `git show --stat HEAD`: 4 files, +134 — only `android/network/**` (3 new main files +
  1 new test). `android/local.properties` NOT committed (grep 0).

## Compliance
- No `:data`/`:domain`/`:feature-inventory`/`:app`/backend/`shared-schemas`/`supabase`
  change. No new dependency. No token persistence / SettingsStore / UI (those are 3c-data /
  3c-ui). No hard-coded anon key or URL (caller supplies). No camera/photos/GPS/AI.
  SDK/Drive not touched; git-ignored `local.properties` left in place.

Final `origin/master` SHA: `a2f5e75ec8d4307155933d7cc04b7045ef97a6b4`

## Next (3c-data, per planner follow-up)
`:domain` `AuthRepository` port (`requestOtp(email)` / `verifyOtp(email, code)` → writes
the returned token via the existing `SettingsStore.setToken`) + `:data` impl over
`SupabaseAuthApi` + auth-config plumbing (Supabase auth URL + public anon key; default to
the local-stack values, configurable; the local demo anon key is safe to commit) +
MockK/fake tests. Then 3c-ui (sign-in screen + `:app` gating).
