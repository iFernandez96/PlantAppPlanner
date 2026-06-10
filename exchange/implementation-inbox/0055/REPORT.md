# Implementation report — 0055-network-refresh-endpoint

## Status: DONE

## What was done
`:network` only — GoTrue refresh-token endpoint (token-refresh part 1 of 3):
- `SupabaseAuthApi` gains
  `@POST("auth/v1/token?grant_type=refresh_token") suspend fun refreshToken(@Body body:
  RefreshTokenRequest): SessionResponse` (verbatim from the prompt); KDoc updated to mention
  the third endpoint.
- `AuthDtos.kt` gains `RefreshTokenRequest(@SerialName("refresh_token") val refreshToken:
  String)`; `SessionResponse` reused unchanged (already models `refresh_token`).
- `AuthDtoTest.kt` gains a red-first serialization test: `RefreshTokenRequest("r1")` encodes
  exactly to `{"refresh_token":"r1"}` (production `SupabaseAuthApiFactory.json` encoder) and a
  `SessionResponse` with both tokens decodes (`accessToken`/`refreshToken` populated) and
  round-trips.

Nothing wired to the new endpoint (part 2's job). Retrofit factory, interceptors, and all
other modules untouched.

## Red evidence (§5 step 1: only the DTO test added)
Compile-red as expected:
```
> Task :network:compileDebugUnitTestKotlin FAILED
e: file:///…/AuthDtoTest.kt:33:43 Unresolved reference 'RefreshTokenRequest'.
BUILD FAILED in 7s
```

## Green evidence
- `:network:testDebugUnitTest` → BUILD SUCCESSFUL; JUnit XML aggregate
  **tests=18 failures+errors=0** (17 before + 1 new).
- `grep -c "grant_type=refresh_token" …/SupabaseAuthApi.kt` → `1`.
- `:app:assembleDebug` → BUILD SUCCESSFUL.

## Baseline precondition
- HEAD before work: `a0cbc3d93a4db8d2ef47109ea5a4a8943712ee0a` ✓
- Tree clean except untracked `android/.kotlin/` (left alone) ✓

## Commit + push
- New commit: `1a60c3fc945dc30366c5843d0e78c75c07bcac5d`
- Title (exact): `feat(network): GoTrue refresh-token endpoint + DTO`
- Pushed: `a0cbc3d..1a60c3f  master -> master`; new `origin/master` =
  `1a60c3fc945dc30366c5843d0e78c75c07bcac5d`

### git show --stat HEAD
```
 .../src/main/kotlin/dev/plantapp/network/AuthDtos.kt        |  5 +++++
 .../src/main/kotlin/dev/plantapp/network/SupabaseAuthApi.kt |  8 ++++++--
 .../src/test/kotlin/dev/plantapp/network/AuthDtoTest.kt     | 13 +++++++++++++
 3 files changed, 24 insertions(+), 2 deletions(-)
```
Exactly the 3 `:network` files. ✓

## Scope confirmation
- `:network` only; Retrofit factory/interceptors untouched; nothing wired to the endpoint;
  no `:data`/`:domain`/`:feature-inventory`/`:app`/backend/schema/supabase/gradle/manifest
  changes; no new dependencies; `android/.kotlin/` left untracked.
