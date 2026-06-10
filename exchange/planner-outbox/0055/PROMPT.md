# Implementation prompt 0055 — token refresh, part 1 of 3: GoTrue refresh endpoint (:network)

## 1. Scope (exactly one logical change)
**Bug context (found on-device):** the app persists only the access token (1h expiry); after it
expires every call 401s forever with no way back to sign-in. Fix is decomposed network → data →
app (like the original sign-in 0026–0028). **This slice: `:network` only** — add the GoTrue
refresh-token endpoint.

- `SupabaseAuthApi` gains:
  ```kotlin
  @POST("auth/v1/token?grant_type=refresh_token")
  suspend fun refreshToken(@Body body: RefreshTokenRequest): SessionResponse
  ```
- `AuthDtos.kt` gains:
  ```kotlin
  @Serializable
  data class RefreshTokenRequest(
      @SerialName("refresh_token") val refreshToken: String,
  )
  ```
  (GoTrue's `POST /auth/v1/token?grant_type=refresh_token` takes `{"refresh_token": "..."}` and
  returns the same session shape as verify — reuse `SessionResponse`, which already models
  `refresh_token`. Consult the Supabase GoTrue docs if unsure.)
- Update the `SupabaseAuthApi` KDoc to mention the third endpoint.
- **Test (red-first)** in the existing `AuthDtoTest.kt` style: serialization test asserting
  `RefreshTokenRequest("r1")` encodes to `{"refresh_token":"r1"}` and a `SessionResponse`
  decode with both tokens round-trips (`accessToken`/`refreshToken` populated).

## 2. Forbidden changes
- `:network` ONLY — within it, only `SupabaseAuthApi.kt`, `AuthDtos.kt`, and the auth DTO test
  file. Do NOT touch the Retrofit factory, interceptors, `:data`, `:domain`,
  `:feature-inventory`, `:app`, backend, schemas, supabase, gradle/manifest.
- Do NOT wire anything to the new endpoint (that's part 2). No new dependencies.

## 3. Exact files to touch (3)
- `android/network/src/main/kotlin/dev/plantapp/network/SupabaseAuthApi.kt`
- `android/network/src/main/kotlin/dev/plantapp/network/AuthDtos.kt`
- `android/network/src/test/kotlin/dev/plantapp/network/AuthDtoTest.kt`

## 4. Baseline precondition (STOP-and-report if different)
- Repo `/home/israel/Documents/Development/PlantApp`, branch `master`.
- Expected HEAD: `a0cbc3d93a4db8d2ef47109ea5a4a8943712ee0a` (0054).
- Tree clean except untracked `android/.kotlin/` (leave it). Otherwise STOP + BLOCKED report.

## 5. Exact commands
```bash
cd /home/israel/Documents/Development/PlantApp
git rev-parse HEAD && git status --porcelain
# 1) RED: add ONLY the new DTO test (references RefreshTokenRequest) → compile-red:
cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest
#    -> expect compile failure on the missing DTO. Capture it.
# 2) GREEN: add the DTO + endpoint + KDoc, re-run:
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
```

## 6. Expected failure mode
Red: compile error on `RefreshTokenRequest` (expected). Green: `:network` suite passes (report
count; currently 10+); `:app:assembleDebug` succeeds. Anything else = regression: STOP, revert,
report.

## 7. Standalone verification
- **Type:** red-first → green (serialization tests are the objective evidence; live refresh is
  proven in part 2/3 + a planner device check).
- **Commands & what they prove:** §5 red output; §5 green run + count;
  `grep -c "grant_type=refresh_token" android/network/src/main/kotlin/dev/plantapp/network/SupabaseAuthApi.kt` → `1`;
  `:app:assembleDebug` BUILD SUCCESSFUL.
- **Report:** outputs verbatim.

## 8. Commit title (exact)
```
feat(network): GoTrue refresh-token endpoint + DTO
```

## 9. Push requirement
Commit and push to `origin master` (fast-forward expected). One change → one commit → one push.

## 10. Final-report requirements
Report to `exchange/implementation-inbox/0055/`: `git show --stat HEAD` (exactly the 3
`:network` files), red+green evidence, test count, commit hash, push confirmation (new
`origin/master`), scope confirmation (nothing wired yet).
