# Next Implementation Prompt — backlog (3c-net): `:network` Supabase GoTrue email-OTP auth client

**Backlog item (3) UX follow-ups, step 3c (sign-in), part 1 of 3 (network).** The owner chose the
**email OTP code** flow: enter email → Supabase emails a 6-digit code → enter code → token. This
step adds the `:network` client for it only — a `SupabaseAuthApi` over GoTrue `/auth/v1/otp` +
`/auth/v1/verify`, its request/response DTOs, and a factory that injects the public `apikey`
(anon) header against the Supabase auth base URL. **No `:data`, no UI, no token writing, no
`:app`** — those are 3c-data and 3c-ui. Dependency-free (Retrofit/OkHttp/kotlinx already present;
D-02).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`8d5187490e9171cf32a62c42a1ff2530bdd2dd0b` == `origin/master`, clean. `:network` has `Dtos.kt`,
`PlantAppApi.kt`, `PlantAppApiFactory.kt` (the factory pattern + `BASIC` logging "no bodies/PII"
comment to mirror), and round-trip tests (`DtoSerializationTest.kt`, `TestSupport.json` with
`encodeDefaults=false`/`explicitNulls=false`/`ignoreUnknownKeys=true`). There is **no** auth API
or auth DTO yet. GoTrue fields are snake_case → use `@SerialName` (not used elsewhere yet).

Single logical change (the `:network` GoTrue OTP auth client) → one commit. Red→green.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the
`:network` Supabase GoTrue email-OTP auth client. **Consult the Supabase GoTrue REST docs**
(`/auth/v1/otp`, `/auth/v1/verify`) and kotlinx-serialization `@SerialName`. Red-first: write the
DTO round-trip tests first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect 8d5187490e9171cf32a62c42a1ff2530bdd2dd0b == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope — `:network` only
1. **New `android/network/src/main/kotlin/dev/plantapp/network/AuthDtos.kt`** — GoTrue email-OTP
   DTOs (snake_case wire names via `@SerialName`; nullable optionals `= null`):
   ```kotlin
   @Serializable data class OtpRequest(
       val email: String,
       @SerialName("create_user") val createUser: Boolean = true,
   )
   @Serializable data class VerifyOtpRequest(
       val email: String,
       val token: String,
       val type: String = "email",
   )
   @Serializable data class SessionResponse(
       @SerialName("access_token") val accessToken: String,
       @SerialName("token_type") val tokenType: String? = null,
       @SerialName("expires_in") val expiresIn: Long? = null,
       @SerialName("refresh_token") val refreshToken: String? = null,
   )
   ```
   (the module `Json` has `ignoreUnknownKeys = true`, so GoTrue's extra `user`/etc. fields are
   ignored on decode.)
2. **New `android/network/src/main/kotlin/dev/plantapp/network/SupabaseAuthApi.kt`** — Retrofit
   interface:
   ```kotlin
   interface SupabaseAuthApi {
       @POST("auth/v1/otp")    suspend fun requestOtp(@Body body: OtpRequest): retrofit2.Response<Unit>
       @POST("auth/v1/verify") suspend fun verifyOtp(@Body body: VerifyOtpRequest): SessionResponse
   }
   ```
3. **New `android/network/src/main/kotlin/dev/plantapp/network/SupabaseAuthApiFactory.kt`** —
   mirror `PlantAppApiFactory`: `fun create(authBaseUrl: String, anonKey: String): SupabaseAuthApi`.
   Add an OkHttp interceptor that sets the header **`apikey: <anonKey>`** on every request (GoTrue
   requires the anon apikey for unauthenticated otp/verify). Reuse the kotlinx converter. Logging
   interceptor at **`Level.BASIC`** with the same "request line + status only; no bodies/PII"
   comment — emails and OTP codes must never be logged. (`authBaseUrl` is the Supabase project URL,
   e.g. the local stack `http://127.0.0.1:54321/`; supplied by the caller — do not hard-code it.)

### Tests — `android/network/src/test/.../AuthDtoTest.kt` (new)
Mirror `DtoSerializationTest` using `TestSupport.json`:
- `OtpRequest` encodes `email` + **`create_user`** (assert the JSON contains `"create_user"`, not
  `createUser`); round-trips.
- `VerifyOtpRequest` encodes `email`/`token`/`type` and round-trips.
- `SessionResponse` **decodes** from a GoTrue-style JSON string
  `{"access_token":"abc.def.ghi","token_type":"bearer","expires_in":3600,"refresh_token":"r",
  "user":{"id":"x"}}` → `accessToken == "abc.def.ghi"` (and the unknown `user` key is ignored).

### Forbidden
- No change to `:data`, `:domain`, `:feature-inventory`, `:app`, backend, `shared-schemas`,
  `supabase`. No new dependency. No token persistence / SettingsStore / UI (those are 3c-data /
  3c-ui). No hard-coded anon key or URL in the factory (caller supplies them). No
  camera/photos/GPS/notifications/AI. Don't mount/repoint the SDK/Drive; don't commit
  `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest
```
Red→green: the new `AuthDtoTest` fails before the DTOs exist; after, `:network` unit tests pass
(new auth tests green, all prior `:network` tests still green). Report the count + new test names.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/network/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-network): Supabase GoTrue email-OTP auth client"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. `SupabaseAuthApi` (the two endpoints), the three DTOs (with the `@SerialName` snake_case
   names), and `SupabaseAuthApiFactory` (apikey header, BASIC logging, caller-supplied
   URL/anon-key).
2. `:network:testDebugUnitTest` (count before→after; new auth tests green; prior green).
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/network/**` changed (not `local.properties`).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `android/network/**`; auth API/DTOs/factory; `:network` tests green).
Then **3c-data**: `:domain` `AuthRepository` port (`requestOtp(email)` / `verifyOtp(email, code)`
→ writes the returned token via the existing `SettingsStore.setToken`) + `:data` impl over
`SupabaseAuthApi` + auth-config plumbing (Supabase auth URL + **public** anon key; default to the
well-known local-stack values, configurable; safe to commit the local demo key) + MockK/fake
tests. Then **3c-ui**: a sign-in screen (email → request code → enter code → verify) + VM + `:app`
gating (show sign-in when no token). Then 3d (advisory→accept→CareTask). Then (2) emulator e2e
smoke; then (4) Slice 3 (WorkManager local first; STOP for owner Firebase/FCM setup). Vision-check
each product-surface step.
