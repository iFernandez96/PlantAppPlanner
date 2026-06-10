# Implementation prompt 0057 — token refresh, part 3 of 3: sign-in fallback when the session is gone

## 1. Scope (exactly one logical change)
Close the expired-session story: after 0056, a failed refresh clears the stored session — but
in-session the user still sees raw 401 errors until they relaunch. This slice routes them back
to sign-in.

1. **`:domain`** — NEW `domain/src/main/kotlin/dev/plantapp/domain/SessionExpiredException.kt`:
   ```kotlin
   package dev.plantapp.domain

   /** Thrown by the data layer when the API rejects the session (401 after any refresh
    *  attempt). The UI should route to sign-in. */
   class SessionExpiredException : Exception("Session expired")
   ```
2. **`:data`** — `InventoryRepositoryImpl.kt`: map Retrofit's `HttpException` with
   `code() == 401` to `SessionExpiredException` on every API call. Use one private helper, e.g.
   ```kotlin
   private suspend fun <T> authed(block: suspend () -> T): T = try { block() } catch (e: retrofit2.HttpException) {
       if (e.code() == 401) throw SessionExpiredException() else throw e
   }
   ```
   and wrap each public method's api call in it (read the file first; keep each method's
   existing body inside `authed { … }` — mechanical, no behavior change otherwise).
3. **`:feature-inventory`** —
   - `PlantListUiState` gains `data object SignedOut : PlantListUiState`.
   - `PlantListViewModel.refresh()` catch block: `is SessionExpiredException ->
     PlantListUiState.SignedOut` before the generic `Exception -> Error(...)` (use a `when` on
     the caught exception).
   - `PlantListScreen`: render `SignedOut` as a centered plain `Text("Signing you back in…")`
     (it's visible only for the moment before navigation) — `testTag("list_signed_out")`.
4. **`:app`** — `MainActivity.kt` `composable(Routes.LIST)` block: after the state is collected,
   ```kotlin
   LaunchedEffect(state) {
       if (state is PlantListUiState.SignedOut) {
           nav.navigate(Routes.SIGN_IN) { popUpTo(0) { inclusive = true } }
       }
   }
   ```
   (separate `LaunchedEffect(state)`, do not merge with the `LaunchedEffect(Unit)`).
5. **Tests (red-first)** — `PlantListViewModelTest`: repo fake throws
   `SessionExpiredException` → state becomes `SignedOut` (compile-red first: `SignedOut`
   doesn't exist). Existing error-path test must still pass (generic exceptions still map to
   `Error`).

Out of scope (note in your report if you see it): wizard/detail also surface raw 401s — the
list is the home surface and refresh-on-visit makes it the catcher; per-screen handling can be
a later polish slice.

## 2. Forbidden changes
- Do NOT touch `:design-system`, `:network`, backend, schemas, supabase, gradle/manifest.
- In `:app` touch ONLY the `composable(Routes.LIST)` block. Do NOT change start-destination
  logic, the wizard, detail, sign-in screens, or `SessionRefreshManager`.
- No new dependencies (`retrofit2.HttpException` is already on `:data`'s classpath).

## 3. Exact files to touch (7)
- `android/domain/src/main/kotlin/dev/plantapp/domain/SessionExpiredException.kt` (NEW)
- `android/data/src/main/kotlin/dev/plantapp/data/repository/InventoryRepositoryImpl.kt`
- `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryUiState.kt`
- `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryViewModels.kt`
- `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/PlantListScreen.kt`
- `android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt`
- `android/feature-inventory/src/test/kotlin/dev/plantapp/feature/inventory/PlantListViewModelTest.kt`

## 4. Baseline precondition (STOP-and-report if different)
- Repo `/home/israel/Documents/Development/PlantApp`, branch `master`.
- Expected HEAD: `738fb9c89d50f71a298cada94386a2672c5d5685` (0056).
- Tree clean except untracked `android/.kotlin/` (leave it). Otherwise STOP + BLOCKED report.

## 5. Exact commands
```bash
cd /home/israel/Documents/Development/PlantApp
git rev-parse HEAD && git status --porcelain
# 1) RED: add ONLY the new VM test case → compile-red on SignedOut:
cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
# 2) GREEN: apply §1.1–1.4, re-run:
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :domain:test :data:testDebugUnitTest :feature-inventory:testDebugUnitTest
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
```
(Note: the `:domain` test task is `:domain:test`, not testDebugUnitTest — it's a JVM module.)

## 6. Expected failure mode
Red: compile error on missing `SignedOut`/`SessionExpiredException` (expected). Green: all
suites pass (report counts); assemble succeeds. Anything else = regression: STOP, revert, report.

## 7. Standalone verification
- **Type:** red-first → green; the live end-to-end (expire token on device → app refreshes or
  routes to sign-in) is the planner's device check right after this lands.
- **Commands & what they prove:** §5 red output; §5 green runs + counts;
  `grep -c "SessionExpiredException" android/data/src/main/kotlin/dev/plantapp/data/repository/InventoryRepositoryImpl.kt` → ≥2 (mapper wired);
  `grep -c "SignedOut" android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt` → `1`
  (fallback nav wired); `:app:assembleDebug` BUILD SUCCESSFUL.
- **Report:** outputs verbatim.

## 8. Commit title (exact)
```
feat(ui): route to sign-in when the session can't be refreshed (SessionExpiredException)
```

## 9. Push requirement
Commit and push to `origin master` (fast-forward expected). One change → one commit → one push.

## 10. Final-report requirements
Report to `exchange/implementation-inbox/0057/`: `git show --stat HEAD` (exactly the §3 files),
red+green evidence, per-module counts, commit hash, push confirmation (new `origin/master`),
scope confirmation (LIST composable only in :app; no behavior change to other repo methods
beyond the 401 mapping).
