# Implementation report — 0057-signin-fallback

## Status: DONE

## What was done
Token-refresh part 3 of 3 — expired sessions route back to sign-in:

1. **`:domain`** — NEW `SessionExpiredException` (verbatim per the prompt).
2. **`:data`** — `InventoryRepositoryImpl`: private `authed { … }` helper maps
   `retrofit2.HttpException` with `code() == 401` → `SessionExpiredException` (anything else
   rethrown); every public method's existing body wrapped mechanically — no other behavior
   change (deletePlant's `check` included inside the wrapper).
3. **`:feature-inventory`** — `PlantListUiState.SignedOut` data object;
   `PlantListViewModel.refresh()` catch is now a `when`: `SessionExpiredException → SignedOut`,
   else the existing `Error(message)`; `PlantListScreen` renders SignedOut as centered
   `Text("Signing you back in…")` with `testTag("list_signed_out")`.
4. **`:app`** — LIST composable only: a separate `LaunchedEffect(state)` (not merged with the
   `LaunchedEffect(Unit)`) navigates to `Routes.SIGN_IN` with `popUpTo(0) { inclusive = true }`
   when the state is SignedOut. One import added (`PlantListUiState`). Start-destination logic,
   wizard, detail, sign-in, `SessionRefreshManager` untouched.
5. **Test (red-first)** — `PlantListViewModelTest.sessionExpiryMapsToSignedOutNotError`:
   repo fake throws `SessionExpiredException` → state becomes `SignedOut`. Existing
   generic-error test still passes (still maps to `Error`).

**Out-of-scope observation (per §1):** confirmed — the wizard (`AddPlantViewModel`) and detail
(`PlantDetailViewModel`) still surface the raw exception message (now "Session expired") in
their error states rather than routing; the list is the home surface + refresh-on-visit makes
it the catcher. Per-screen handling is a later polish slice.

## Red evidence (§5 step 1: only the VM test case added)
Compile-red as expected:
```
> Task :feature-inventory:compileDebugUnitTestKotlin FAILED
e: …/PlantListViewModelTest.kt:3:28 Unresolved reference 'SessionExpiredException'.
e: …/PlantListViewModelTest.kt:83:58 Unresolved reference 'SessionExpiredException'.
e: …/PlantListViewModelTest.kt:88:48 Unresolved reference 'SignedOut'.
```

## Green evidence
- `:domain:test` → **tests=9 failures+errors=0**
- `:data:testDebugUnitTest` → **tests=18 failures+errors=0**
- `:feature-inventory:testDebugUnitTest` → **tests=34 failures+errors=0** (33 + 1 new)
- `grep -c "SessionExpiredException" …/InventoryRepositoryImpl.kt` → `2` (import + mapper).
- `grep -c "SignedOut" …/MainActivity.kt` → `1` (fallback nav wired).
- `:app:assembleDebug` → BUILD SUCCESSFUL.

## Baseline precondition
- HEAD before work: `738fb9c89d50f71a298cada94386a2672c5d5685` ✓
- Tree clean except untracked `android/.kotlin/` (left alone) ✓

## Commit + push
- New commit: `4b3910cabf30167b0e30d37eecf98a6ed14430cd`
- Title (exact): `feat(ui): route to sign-in when the session can't be refreshed (SessionExpiredException)`
- Pushed: `738fb9c..4b3910c  master -> master`; new `origin/master` =
  `4b3910cabf30167b0e30d37eecf98a6ed14430cd`

### git show --stat HEAD
```
 .../kotlin/dev/plantapp/android/MainActivity.kt    |  7 ++++
 .../data/repository/InventoryRepositoryImpl.kt     | 41 ++++++++++++++++------
 .../dev/plantapp/domain/SessionExpiredException.kt |  5 +++ (new)
 .../plantapp/feature/inventory/InventoryUiState.kt |  2 ++
 .../feature/inventory/InventoryViewModels.kt       |  6 +++-
 .../plantapp/feature/inventory/PlantListScreen.kt  |  5 +++
 .../feature/inventory/PlantListViewModelTest.kt    | 12 +++++++
 7 files changed, 66 insertions(+), 12 deletions(-)
```
Exactly the §3 files. ✓

## Scope confirmation
- `:app` touched only inside `composable(Routes.LIST)` (+1 import); no behavior change to
  other repo methods beyond the 401 mapping; no `:design-system`/`:network`/backend/schema/
  supabase/gradle/manifest changes; no new dependencies; `android/.kotlin/` left untracked.
- Planner device check: expire token on device → app refreshes transparently, or routes to
  sign-in when refresh fails.
