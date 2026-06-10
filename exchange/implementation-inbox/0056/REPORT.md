# Implementation report — 0056-token-refresh-store-and-auto-refresh

## Status: DONE

## What was done
### A. `:network` seam (`PlantAppApiFactory.kt` only)
- `fun interface SessionRefresher { fun refreshSession(): String? }` added next to
  `AuthTokenProvider` (KDoc verbatim).
- `create(baseUrl, tokenProvider, sessionRefresher: SessionRefresher? = null)` — default null
  keeps existing callers/tests compiling. When non-null, an OkHttp `authenticator` is
  installed: gives up if `response.priorResponse != null` (one refresh attempt per call);
  otherwise calls `refreshSession()` — null → propagate the 401; token → retry the request
  with `Authorization: Bearer <new token>`.

### B. `:data`
1. `TokenWriter.setSession(accessToken, refreshToken)` added with a default implementation
   (`setToken(accessToken)`) so existing fakes keep compiling.
2. `SettingsStore` — new `refreshTokenKey = stringPreferencesKey("refresh_token")`;
   `setSession` override writes/removes both keys in one edit; `refreshTokenBlocking()` added
   (same pattern as `tokenBlocking()`).
3. `AuthRepositoryImpl.verifyOtp` → `tokenWriter.setSession(session.accessToken,
   session.refreshToken)` (replaces `setToken`); KDoc updated.
4. NEW `SessionRefreshManager` — verbatim per the prompt (`runBlocking`; missing stored token
   or API failure → `setSession(null, null)` + null; success → persist new pair, return new
   access token).
5. `DataModule.providePlantAppApi` gains the `refreshManager` param and passes
   `sessionRefresher = SessionRefresher { refreshManager.refreshSessionBlocking() }`.

### C. Tests
- NEW `SessionRefreshManagerTest` (plain JUnit/kotlin-test, no Robolectric): fake
  `SupabaseAuthApi` + the **real `SettingsStore` over an in-memory `DataStore<Preferences>`**
  (a 9-line `InMemoryDataStore` implementing `data`/`updateData` over a `MutableStateFlow`) —
  the prompt's "minimal constructor-friendly approach"; it exercises the real key logic.
  Three tests: success persists both + returns "a2" (and the API saw "r1"); API failure clears
  the session + returns null; no stored refresh token → API never called (0 calls), session
  cleared, null.
- `AuthRepositoryImplTest` extended: `FakeSupabaseAuthApi` now overrides `refreshToken`
  (throwing stub) and the canned `SessionResponse` includes `refreshToken = "refresh-456"`;
  `FakeTokenWriter` records both; the verify test asserts BOTH tokens persisted.

## Red evidence (§5 step 1: only SessionRefreshManagerTest added)
Compile-red as expected — and it also surfaced that 0055's interface change had silently
broken the (not-then-compiled) `:data` test fake, exactly as §6 anticipated:
```
> Task :data:compileDebugUnitTestKotlin FAILED
e: …/AuthRepositoryImplTest.kt:19:13 Class 'AuthRepositoryImplTest.FakeSupabaseAuthApi' is not abstract and does not implement abstract member 'refreshToken'.
e: …/SessionRefreshManagerTest.kt:6:37 Unresolved reference 'SessionRefreshManager'.
e: …/SessionRefreshManagerTest.kt:60:32 Unresolved reference 'setSession'.
```

## Green evidence
- `:data:testDebugUnitTest` → **tests=18 failures+errors=0** (15 before + 3 new).
- `:network:testDebugUnitTest` → **tests=18 failures+errors=0** (unchanged; factory default
  param kept old tests compiling).
- `:feature-inventory:testDebugUnitTest` → **tests=33 failures+errors=0** (regression canary —
  the `TokenWriter` default implementation kept its fakes compiling, as designed).
- `grep -c "authenticator(" …/PlantAppApiFactory.kt` → `1`.
- `grep -c "setSession" …/AuthRepositoryImpl.kt` → `1`.
- `:app:assembleDebug` → BUILD SUCCESSFUL.

## Baseline precondition
- HEAD before work: `1a60c3fc945dc30366c5843d0e78c75c07bcac5d` ✓
- Tree clean except untracked `android/.kotlin/` (left alone) ✓

## Commit + push
- New commit: `738fb9c89d50f71a298cada94386a2672c5d5685`
- Title (exact): `feat(data): persist refresh token and auto-refresh session on 401`
- Pushed: `1a60c3f..738fb9c  master -> master`; new `origin/master` =
  `738fb9c89d50f71a298cada94386a2672c5d5685`

### git show --stat HEAD
```
 .../main/kotlin/dev/plantapp/data/di/DataModule.kt |  4 +
 .../plantapp/data/repository/AuthRepositoryImpl.kt |  7 +-
 .../data/repository/SessionRefreshManager.kt       | 34 ++++++++ (new)
 .../dev/plantapp/data/settings/SettingsStore.kt    | 18 ++++
 .../dev/plantapp/data/AuthRepositoryImplTest.kt    | 15 +++-
 .../dev/plantapp/data/SessionRefreshManagerTest.kt | 98 ++++++++++++++++++++++ (new)
 .../dev/plantapp/network/PlantAppApiFactory.kt     | 28 ++++++-
 7 files changed, 196 insertions(+), 8 deletions(-)
```
Exactly the §3 files. ✓

## Scope confirmation
- `:network` touched only in `PlantAppApiFactory.kt`; no UI/nav/sign-in-fallback work (part 3);
  no `:domain`/`:feature-inventory`/`:app`/`:design-system`/backend/schema/supabase/gradle/
  manifest changes; no new dependencies; `android/.kotlin/` left untracked.
- Live end-to-end 401→refresh→retry is part 3's planner device check.
