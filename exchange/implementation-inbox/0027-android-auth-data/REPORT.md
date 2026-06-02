# DONE — handoff 0027-android-auth-data (3c-data, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** `AuthRepository` domain port + `:data` impl over the `0026` `SupabaseAuthApi`,
persisting the access token via `SettingsStore`. DI/config wired. `:domain` + `:data` unit
tests green. Final `origin/master` = `28f69ea34cc38089a8c3906cc5a9ce9b55cdf47b`.

## Baseline + unblock
- HEAD at start = `a2f5e75…` == origin/master; clean. SDK resolves (Drive mounted).

## What was added
1. **`:domain` `repository/AuthRepository.kt`** (new) — pure-Kotlin port:
   `suspend fun requestOtp(email)` / `suspend fun verifyOtp(email, code)` (KDoc: token persisted
   on success).
2. **`:data` `settings/SettingsStore.kt`** — added `interface TokenWriter { suspend fun
   setToken(token: String?) }` and made `SettingsStore : TokenWriter` with `override` on the
   existing `setToken`. No behavior change — just a testable seam.
3. **`:data` `repository/AuthRepositoryImpl.kt`** (new) — `@Inject constructor(api:
   SupabaseAuthApi, tokenWriter: TokenWriter)`:
   - `requestOtp` → `api.requestOtp(OtpRequest(email)); check(r.isSuccessful)`.
   - `verifyOtp` → `val session = api.verifyOtp(VerifyOtpRequest(email, token = code));
     tokenWriter.setToken(session.accessToken)`.
4. **`:data` `di/DataModule.kt`** — auth config + providers:
   - `DEFAULT_AUTH_BASE_URL = "http://10.0.2.2:54321/"` (Supabase gateway; GoTrue at `/auth/v1/`).
   - `DEFAULT_ANON_KEY` = the **public local-dev supabase-demo anon JWT**, read live from the
     running local stack via `npx supabase status -o env` (`ANON_KEY`). Commented "Public
     local-dev anon key … override for a real Supabase project." This is a well-known public JWT,
     not a secret.
   - `@Provides @Singleton provideSupabaseAuthApi() = SupabaseAuthApiFactory.create(authBaseUrl,
     anonKey)`.
   - `RepositoryModule`: `@Binds bindAuthRepository(AuthRepositoryImpl): AuthRepository` and
     `@Binds bindTokenWriter(SettingsStore): TokenWriter`.

## Tests (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :domain:test :data:testDebugUnitTest
BUILD SUCCESSFUL in 12s
```
- New **`AuthRepositoryImplTest`** (hand-written fakes `FakeSupabaseAuthApi`/`FakeTokenWriter`,
  `runTest`): **2 tests, 0 failures** —
  - `requestOtp delegates to the api with the email` — fake api recorded `email == "a@b.test"`.
  - `verifyOtp persists the returned access token` — fake api saw `(email="a@b.test",
    token="123456", type="email")`; `FakeTokenWriter.last == "token-123"`.
- `:data` counts **8 → 10** (AuthRepositoryImplTest 2 + InventoryAdvisoriesTest 1 +
  InventoryRepositoryImplTest 7). `:domain` 2 (InventoryModelsTest) unchanged. All green.

## Commit
- `28f69ea` — feat(android-data): AuthRepository (email-OTP request/verify) persisting the token
- `git show --stat HEAD`: 5 files, +133 −2 — only `android/domain/**` (1 new) +
  `android/data/**` (1 new main, 1 new test, 2 edited). `android/local.properties` NOT committed
  (grep 0).

## Compliance
- No `:network`/`:feature-inventory`/`:app`/backend/`shared-schemas`/`supabase` change. No new
  dependency. No UI / navigation. No camera/photos/GPS/notifications/AI. Only the **public**
  local-dev anon key committed (read from the live local stack). SDK/Drive untouched.

Final `origin/master` SHA: `28f69ea34cc38089a8c3906cc5a9ce9b55cdf47b`

## Next (3c-ui, per planner follow-up)
Sign-in screen (email → "Send code" `requestOtp` → code → "Verify" `verifyOtp`) over a
`SignInViewModel` on `AuthRepository`, + `:app` gating (sign-in when `tokenBlocking()` is null,
else plant list) + Robolectric tests.
