# Next Implementation Prompt — backlog (3c-data): `AuthRepository` (request/verify OTP → persist token)

**Backlog item (3) UX follow-ups, step 3c (sign-in), part 2 of 3 (data/domain).** Wire the
`0026` `:network` `SupabaseAuthApi` to a domain port + `:data` implementation that, on successful
OTP verification, **persists the returned token via the existing `SettingsStore.setToken`** (which
the OkHttp `AuthTokenProvider` interceptor already reads). Add the auth-config (Supabase auth URL +
**public** anon key) to DI. **No UI, no `:app` navigation** — the sign-in screen + gating is 3c-ui.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`a2f5e75ec8d4307155933d7cc04b7045ef97a6b4` == `origin/master`, clean. `:network` has
`SupabaseAuthApi` (`requestOtp(OtpRequest): Response<Unit>`, `verifyOtp(VerifyOtpRequest):
SessionResponse`) + `SupabaseAuthApiFactory.create(authBaseUrl, anonKey)`. `:data` has
`SettingsStore` (`suspend setToken(token: String?)`, `baseUrlBlocking`, `tokenBlocking`),
`InventoryRepositoryImpl`, `DataModule` (Hilt; `DEFAULT_BASE_URL = "http://10.0.2.2:54321/"`,
provides `PlantAppApi`/`AuthTokenProvider`) and `RepositoryModule`. `:data` tests use hand-written
fakes (`FakePlantAppApi`) + `kotlinx.coroutines.test`. `:domain` has `InventoryRepository` +
models. There is **no** `AuthRepository` yet.

Single logical change (the auth domain port + `:data` impl + DI/config) → one commit. Red→green.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the auth
domain port + `:data` implementation over `SupabaseAuthApi`, persisting the token via
`SettingsStore`. Red-first: write the repository test first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect a2f5e75ec8d4307155933d7cc04b7045ef97a6b4 == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`android/domain/.../repository/AuthRepository.kt`** (new) — pure-Kotlin port:
   ```kotlin
   interface AuthRepository {
       /** Ask Supabase to email a one-time code to [email]. */
       suspend fun requestOtp(email: String)
       /** Verify [code] for [email]; on success the access token is persisted. */
       suspend fun verifyOtp(email: String, code: String)
   }
   ```
2. **`android/data/.../settings/SettingsStore.kt`** — extract a tiny seam so the repo's token
   write is testable without a real DataStore: add `interface TokenWriter { suspend fun
   setToken(token: String?) }` (in `:data`) and make `SettingsStore : TokenWriter` (it already has
   `suspend fun setToken(token: String?)` — just add the interface + `override`). No behavior
   change.
3. **`android/data/.../repository/AuthRepositoryImpl.kt`** (new) —
   `class AuthRepositoryImpl @Inject constructor(private val api: SupabaseAuthApi, private val
   tokenWriter: TokenWriter) : AuthRepository`:
   - `requestOtp(email)` → `val r = api.requestOtp(OtpRequest(email = email)); check(r.isSuccessful)
     { "requestOtp failed: HTTP ${r.code()}" }`.
   - `verifyOtp(email, code)` → `val session = api.verifyOtp(VerifyOtpRequest(email = email, token =
     code)); tokenWriter.setToken(session.accessToken)`.
4. **`android/data/.../di/DataModule.kt`** — add auth config + providers:
   - `private const val DEFAULT_AUTH_BASE_URL = "http://10.0.2.2:54321/"` (Supabase gateway;
     GoTrue lives at `/auth/v1/`).
   - `private const val DEFAULT_ANON_KEY = "<local-stack anon key>"` — **the public local-dev
     Supabase anon key**. Obtain the exact value from the running local stack:
     `cd /home/israel/Documents/Development/PlantApp/backend && npm_config_cache=/tmp/plantapp-npx-cache npx supabase status -o env`
     and copy `ANON_KEY` (it is a public, well-known local JWT — safe to commit). Add a comment:
     "Public local-dev anon key; override for a real Supabase project." If the stack is not up,
     STOP and report rather than inventing a key.
   - `@Provides @Singleton fun provideSupabaseAuthApi(): SupabaseAuthApi =
     SupabaseAuthApiFactory.create(authBaseUrl = DEFAULT_AUTH_BASE_URL, anonKey = DEFAULT_ANON_KEY)`.
   - In `RepositoryModule`: `@Binds @Singleton abstract fun bindAuthRepository(impl:
     AuthRepositoryImpl): AuthRepository`, and `@Binds @Singleton abstract fun bindTokenWriter(impl:
     SettingsStore): TokenWriter`.

### Tests — `android/data/src/test/.../AuthRepositoryImplTest.kt` (new)
Hand-written fakes (mirror `FakePlantAppApi`), `runTest`:
- A `FakeSupabaseAuthApi : SupabaseAuthApi` recording the last `OtpRequest`/`VerifyOtpRequest`,
  returning `Response.success(Unit)` for otp and a canned `SessionResponse(accessToken =
  "token-123")` for verify.
- A `FakeTokenWriter : TokenWriter` capturing the last token.
- `requestOtp delegates to the api with the email` → assert the fake recorded the email.
- `verifyOtp persists the returned access token` → call `verifyOtp("a@b.test","123456")`; assert
  the fake api saw `(email="a@b.test", token="123456", type="email")` and `FakeTokenWriter.last ==
  "token-123"`.

### Forbidden
- No change to `:network` (landed), `:feature-inventory`, `:app`, backend, `shared-schemas`,
  `supabase`. No new dependency. No UI / navigation. No camera/photos/GPS/notifications/AI. Don't
  commit a **non-public** secret — only the public local-dev anon key (and only if read from the
  local stack). Don't mount/repoint the SDK/Drive; don't commit `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :domain:test :data:testDebugUnitTest
```
Red→green: the new `AuthRepositoryImplTest` fails before the port/impl exist; after, `:domain`
(JVM module → `:domain:test`) compiles with the new port and `:data` unit tests pass (new auth
test green; prior `:data` tests still green). Report counts + the new test name.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/domain/ android/data/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-data): AuthRepository (email-OTP request/verify) persisting the token"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The `AuthRepository` port, `AuthRepositoryImpl` (request delegates; verify persists token), the
   `TokenWriter` seam, and the DI/config additions (auth URL + that the committed anon key is the
   public local-dev key, overridable).
2. `:domain:test` + `:data:testDebugUnitTest` (counts before→after; new test green; prior green).
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/domain/**` + `android/data/**` changed (not `local.properties`); confirm no non-public
   secret committed.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `domain/**`+`data/**`; port + impl + DI; token-persist test green; only
the public local anon key committed). Then **3c-ui**: a sign-in screen — email field → "Send code"
(`requestOtp`) → code field → "Verify" (`verifyOtp`) — wired to a `SignInViewModel` over
`AuthRepository`, with `:app` **gating** (show sign-in when `SettingsStore.tokenBlocking()` is
null, else the plant list) + Robolectric tests. Then 3d (advisory→accept→CareTask). Then (2)
emulator e2e smoke; then (4) Slice 3 (WorkManager local first; STOP for owner Firebase/FCM setup).
Vision-check each product-surface step.
