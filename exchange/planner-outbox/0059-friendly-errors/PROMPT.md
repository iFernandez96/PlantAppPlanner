# Implementation prompt 0059 — friendly errors everywhere (W2 opener, PD-13)

You are the implementation Claude for PlantApp. Apply exactly ONE logical change:
stop raw exception text (`e.message` — stack-trace fragments, LAN IPs, HTTP codes)
from reaching ANY screen; every error surface shows fixed plain-language copy.
0058 fixed sign-in; this slice fixes the remaining six sites.

## 1. Scope — one logical change

- **`DisplayText.kt`** — add one helper, `friendlyError(e, fallback)`: names session
  expiry in plain language, otherwise returns the screen-specific fallback. It must
  NEVER return `e.message`.
- **`InventoryViewModels.kt`** — replace all 6 remaining `e.message ?: "…"` sites
  (PlantListViewModel ×1, AddPlantViewModel ×4, PlantDetailViewModel ×1) with
  `DisplayText.friendlyError(e, <friendly fallback>)`.
- **`PlantListScreen.kt` / `PlantDetailScreen.kt`** — drop the technical
  "Couldn't load plants: " / "Couldn't load plant: " prefixes (the message is now
  self-contained friendly copy; prefixing would double it up).
- **Tests** — one red-first ViewModel test + two DisplayText tests (see §7).

NOT in scope: routing wizard/detail to sign-in on session expiry (the list screen
already routes; other screens now at least SAY "Your session ended. Please sign in
again." — full routing is a later slice).

## 2. Forbidden changes — do NOT touch

- `SignInScreen.kt` / `SignInViewModel` (done in 0058) — and do not change
  `SignInUiState`.
- `android/design-system/**`, `addplant/**` (the wizard consumes `_error` via its
  existing error card — no wizard file changes needed), `MainActivity.kt`,
  `PlaceholderScreens.kt`, `InventoryTestTags.kt`.
- The `accept()` advisory catch (it intentionally swallows + reloads; no message).
- The `SessionExpiredException -> SignedOut` branch in PlantListViewModel — keep it
  FIRST in the `when`; `friendlyError` only handles the `else` branch.
- Backend (`backend/**`), schemas (`shared-schemas/**`), migrations (`supabase/**`).
- No new dependencies. Do NOT `git add` the untracked `android/.kotlin/`.

## 3. Exact files to touch (repo-relative, all existing)

1. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/DisplayText.kt`
2. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryViewModels.kt`
3. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/PlantListScreen.kt`
4. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/PlantDetailScreen.kt`
5. `android/feature-inventory/src/test/kotlin/dev/plantapp/feature/inventory/PlantListViewModelTest.kt`
6. `android/feature-inventory/src/test/kotlin/dev/plantapp/feature/inventory/DisplayTextTest.kt`

## 4. Baseline precondition — STOP if it doesn't hold

```bash
git -C /home/israel/Documents/Development/PlantApp rev-parse HEAD   # must be 4517f4482bf169a21bba22964188ef69210f42bd
git -C /home/israel/Documents/Development/PlantApp status --short   # clean (untracked android/.kotlin/ OK — leave it)
git -C /home/israel/Documents/Development/PlantApp branch --show-current  # master
```

If HEAD differs, branch isn't master, or tracked files are modified: **STOP and
write a BLOCKED report.**

## 5. Exact changes

### 5a. `DisplayText.kt` — add the helper (inside `object DisplayText`)

```kotlin
    /** Screen-safe error copy. Names session expiry; otherwise uses the screen's fallback.
     *  NEVER surfaces e.message — raw exception text (HTTP codes, LAN IPs) is not for users. */
    fun friendlyError(e: Throwable, fallback: String): String = when (e) {
        is SessionExpiredException -> "Your session ended. Please sign in again."
        else -> fallback
    }
```

Add the import: `import dev.plantapp.domain.SessionExpiredException` (the module
already depends on `:domain`; `InventoryViewModels.kt` imports it today).

### 5b. `InventoryViewModels.kt` — six replacements (exact old → new)

1. Line ~56 (PlantListViewModel, keep the `when` + SignedOut branch above it):
   - old: `else -> PlantListUiState.Error(e.message ?: "unknown error")`
   - new: `else -> PlantListUiState.Error(DisplayText.friendlyError(e, "We couldn't load your plants. Check your connection and try again."))`
2. Line ~87 (AddPlantViewModel init):
   - old: `_error.value = e.message ?: "Could not load add-plant options"`
   - new: `_error.value = DisplayText.friendlyError(e, "We couldn't load the plant choices. Check your connection and try again.")`
3. Line ~98 (createGardenSpace):
   - old: `_error.value = e.message ?: "Could not create garden space"`
   - new: `_error.value = DisplayText.friendlyError(e, "We couldn't save your space. Please try again.")`
4. Line ~109 (createContainer):
   - old: `_error.value = e.message ?: "Could not create container"`
   - new: `_error.value = DisplayText.friendlyError(e, "We couldn't save your pot. Please try again.")`
5. Line ~128 (submit):
   - old: `_error.value = e.message ?: "Could not add plant"`
   - new: `_error.value = DisplayText.friendlyError(e, "We couldn't add your plant. Please try again.")`
6. Line ~205 (PlantDetailViewModel loadFor):
   - old: `PlantDetailUiState.Error(e.message ?: "unknown error")`
   - new: `PlantDetailUiState.Error(DisplayText.friendlyError(e, "We couldn't load this plant. Check your connection and try again."))`

Keep the existing `PlantDetailUiState.Error("Plant not found")` (already friendly).

### 5c. `PlantListScreen.kt` (~line 73)

- old: `Text(text = "Couldn't load plants: ${state.message}")`
- new: `Text(text = state.message)`

### 5d. `PlantDetailScreen.kt` (~line 57)

- old: `Text("Couldn't load plant: ${state.message}")`
- new: `Text(state.message)`

## 6. Expected failure modes (not regressions)

- §7 step 1: exactly ONE new test fails with an assertion error mentioning the raw
  URL string — that is the expected red.
- Gradle configure-time deprecation warnings: pre-existing, ignore.
- Backend untouched — do not run `npm test`.

## 7. Standalone verification (red → green, objective)

All commands from `/home/israel/Documents/Development/PlantApp/android` with
`GRADLE_USER_HOME=/tmp/plantapp-gradle-home`.

**Step 1 — RED.** Add to `PlantListViewModelTest.kt` (compiles on baseline — uses
the existing `MutablePlantsRepo` + `reminderSync` helpers):

```kotlin
    @Test
    fun loadErrorShowsFriendlyCopyNotRawExceptionText() = runTest(dispatcher) {
        val repo = MutablePlantsRepo().apply { failure = RuntimeException("HTTP 500 http://10.0.0.179:3000/plants") }
        val vm = PlantListViewModel(repo, reminderSync(repo))
        advanceUntilIdle()
        val state = vm.state.value
        assertTrue("error state expected", state is PlantListUiState.Error)
        val message = (state as PlantListUiState.Error).message
        assertFalse("raw exception text must not reach the UI", message.contains("10.0.0.179"))
        assertEquals("We couldn't load your plants. Check your connection and try again.", message)
    }
```

Run:
```bash
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest --tests "dev.plantapp.feature.inventory.PlantListViewModelTest"
```
**Expected: the new test FAILS** (today the message IS the raw exception text).
Capture the failure for the report. If it passes, STOP — baseline mismatch.

**Step 2 — implement** §5a–§5d.

**Step 3 — add the DisplayText tests** to `DisplayTextTest.kt`:

```kotlin
    @Test
    fun friendlyErrorUsesTheFallbackAndNeverTheExceptionMessage() {
        val msg = DisplayText.friendlyError(RuntimeException("raw http://10.0.0.179"), "Friendly fallback.")
        assertEquals("Friendly fallback.", msg)
    }

    @Test
    fun friendlyErrorNamesSessionExpiry() {
        val msg = DisplayText.friendlyError(SessionExpiredException(), "Friendly fallback.")
        assertEquals("Your session ended. Please sign in again.", msg)
    }
```
(import `dev.plantapp.domain.SessionExpiredException`; match the file's existing
assert style.)

**Step 4 — GREEN (the standalone verification):**
```bash
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Proves the full `:feature-inventory` suite green (3 new tests included; expect 39
total — report the actual count from the JUnit XML, do not assume) and the app
assembles.

**Grep proof (include output):**
```bash
grep -c "e.message" feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryViewModels.kt
```
**Expected: `0`** (grep exits 1 on zero matches — that is the pass condition, not
an error).

## 8. Commit title (Conventional Commits, exact)

```
feat(ui): friendly plain-language errors everywhere — no raw exception text
```

One commit (red test + implementation + DisplayText tests; red evidence in the report).

## 9. Push requirement

`git push origin master` — expect fast-forward from `4517f44`. Confirm the new
`origin/master` SHA in the report.

## 10. Final report requirements

Write the report to `exchange/implementation-inbox/0059-friendly-errors/` via
`scripts/exchange-create-implementation-report.sh`. Include:

1. Scope confirmation (only the 6 listed files) + `git show --stat HEAD`.
2. RED evidence from §7 step 1.
3. GREEN totals + `BUILD SUCCESSFUL` for assembleDebug.
4. The grep proof (`0`).
5. New commit hash + push confirmation (new `origin/master`).
6. Deviations (or "none").
