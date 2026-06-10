# Implementation prompt 0056 — token refresh, part 2 of 3: store + auto-refresh (:data, :network seam)

## 1. Scope (exactly one logical change)
Wire the 0055 refresh endpoint so an expired access token refreshes transparently: persist the
refresh token at sign-in, and on a 401 from the app API refresh the session once and retry.
(Part 3 adds the user-facing sign-in fallback when refresh itself fails.)

### A. `:network` seam — `PlantAppApiFactory.kt` only
- Add next to `AuthTokenProvider`:
  ```kotlin
  /** Refreshes the session on a 401; returns the NEW access token, or null if refresh failed. */
  fun interface SessionRefresher {
      fun refreshSession(): String?
  }
  ```
- `create(baseUrl, tokenProvider, sessionRefresher: SessionRefresher? = null)` (default null
  keeps existing callers/tests compiling). When non-null, add an OkHttp
  `authenticator(Authenticator { _, response -> ... })` that:
  - gives up (returns null) if the response chain already contains a prior 401 retry
    (`response.priorResponse != null`),
  - otherwise calls `sessionRefresher.refreshSession()`; on null → give up (propagate the 401);
    on a token → retry the request with `Authorization: Bearer <new token>`.

### B. `:data` — storage + refresh manager
1. `TokenWriter` (in `SettingsStore.kt`) gains a default-implemented method (fakes keep
   compiling):
   ```kotlin
   suspend fun setSession(accessToken: String?, refreshToken: String?) { setToken(accessToken) }
   ```
2. `SettingsStore`: new `refreshTokenKey = stringPreferencesKey("refresh_token")`; override
   `setSession` to write/remove both keys; add `fun refreshTokenBlocking(): String?` (same
   pattern as `tokenBlocking()`).
3. `AuthRepositoryImpl.verifyOtp`: `tokenWriter.setSession(session.accessToken,
   session.refreshToken)` (replaces `setToken`).
4. NEW `data/src/main/kotlin/dev/plantapp/data/repository/SessionRefreshManager.kt`:
   ```kotlin
   /** Exchanges the stored refresh token for a fresh session (blocking — called from OkHttp's
    *  authenticator thread). Success: persists the new token pair, returns the new access
    *  token. Failure or no stored refresh token: clears the session (next launch lands on
    *  sign-in) and returns null. */
   @Singleton
   class SessionRefreshManager @Inject constructor(
       private val authApi: SupabaseAuthApi,
       private val settings: SettingsStore,
   ) {
       fun refreshSessionBlocking(): String? = runBlocking {
           val stored = settings.refreshTokenBlocking() ?: run { settings.setSession(null, null); return@runBlocking null }
           try {
               val s = authApi.refreshToken(RefreshTokenRequest(stored))
               settings.setSession(s.accessToken, s.refreshToken)
               s.accessToken
           } catch (e: Exception) {
               settings.setSession(null, null)
               null
           }
       }
   }
   ```
5. `DataModule.providePlantAppApi` gains a `refreshManager: SessionRefreshManager` param and
   passes `sessionRefresher = SessionRefresher { refreshManager.refreshSessionBlocking() }`.

### C. Tests (red-first)
NEW `data/src/test/.../SessionRefreshManagerTest.kt` (plain JUnit + a fake `SupabaseAuthApi`
and an in-memory `SettingsStore` seam — if `SettingsStore` is hard to fake directly, introduce
the minimal constructor-friendly approach used by existing data tests; read
`InventoryRepositoryImplTest.kt`/`FakePlantAppApi.kt` first and follow the local style):
- success: stored refresh `"r1"` → api returns access `"a2"`/refresh `"r2"` → both persisted,
  returns `"a2"`.
- api failure: throws → session cleared (both null), returns null.
- no stored refresh token: api NEVER called, session cleared, returns null.
`AuthRepositoryImplTest` exists — extend it: its local `FakeSupabaseAuthApi` must now also
override `refreshToken` (0055 added it to the interface; a simple `TODO()`/throw stub or canned
response is fine) and its canned `SessionResponse` should include a `refreshToken`; assert
`verifyOtp` persists BOTH tokens.

## 2. Forbidden changes
- Do NOT touch `:domain`, `:feature-inventory`, `:app`, `:design-system`, backend, schemas,
  supabase, gradle/manifest. In `:network` touch ONLY `PlantAppApiFactory.kt`.
- Do NOT add sign-in-fallback UI/navigation (part 3). No new dependencies.

## 3. Exact files to touch
- `android/network/src/main/kotlin/dev/plantapp/network/PlantAppApiFactory.kt`
- `android/data/src/main/kotlin/dev/plantapp/data/settings/SettingsStore.kt`
- `android/data/src/main/kotlin/dev/plantapp/data/repository/AuthRepositoryImpl.kt`
- `android/data/src/main/kotlin/dev/plantapp/data/repository/SessionRefreshManager.kt` (NEW)
- `android/data/src/main/kotlin/dev/plantapp/data/di/DataModule.kt`
- `android/data/src/test/kotlin/dev/plantapp/data/SessionRefreshManagerTest.kt` (NEW; + the
  existing auth-repo test if present)

## 4. Baseline precondition (STOP-and-report if different)
- Repo `/home/israel/Documents/Development/PlantApp`, branch `master`.
- Expected HEAD: `1a60c3fc945dc30366c5843d0e78c75c07bcac5d` (0055).
- Tree clean except untracked `android/.kotlin/` (leave it). Otherwise STOP + BLOCKED report.

## 5. Exact commands
```bash
cd /home/israel/Documents/Development/PlantApp
git rev-parse HEAD && git status --porcelain
# 1) RED: add ONLY SessionRefreshManagerTest → compile-red on the missing class:
cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :data:testDebugUnitTest
# 2) GREEN: apply §1 A+B (+ test fixes), re-run:
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :data:testDebugUnitTest :network:testDebugUnitTest :feature-inventory:testDebugUnitTest
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
```

## 6. Expected failure mode
Red: compile error on missing `SessionRefreshManager` (expected). Green: all three module
suites pass (report counts); assemble succeeds. Anything else = regression: STOP, revert,
report. (Note: `:feature-inventory` is in the green run only as a regression canary — its
fakes implement `TokenWriter`? If a fake breaks because it implements `TokenWriter` without
the new method, the DEFAULT implementation should prevent that; if it doesn't compile, that is
a sign the default was omitted — fix the interface, not the fakes.)

## 7. Standalone verification
- **Type:** red-first → green (manager behavior). Live end-to-end 401→refresh→retry is part 3's
  device check (planner will expire a token on-device).
- **Commands & what they prove:** §5 red output; §5 green runs + counts;
  `grep -c "authenticator(" android/network/src/main/kotlin/dev/plantapp/network/PlantAppApiFactory.kt` → `1`;
  `grep -c "setSession" android/data/src/main/kotlin/dev/plantapp/data/repository/AuthRepositoryImpl.kt` → `1`;
  `:app:assembleDebug` BUILD SUCCESSFUL.
- **Report:** outputs verbatim.

## 8. Commit title (exact)
```
feat(data): persist refresh token and auto-refresh session on 401
```

## 9. Push requirement
Commit and push to `origin master` (fast-forward expected). One change → one commit → one push.

## 10. Final-report requirements
Report to `exchange/implementation-inbox/0056/`: `git show --stat HEAD` (only the §3 files),
red+green evidence, per-module test counts, commit hash, push confirmation (new
`origin/master`), scope confirmation (no UI/nav changes; factory default param keeps old
callers).
