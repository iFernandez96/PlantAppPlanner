# VERIFICATION — handoff 0033-navhost-smoke (backlog 2, red→green)

Gate: `:feature-inventory:testDebugUnitTest`, Drive mounted. Test-only addition.

## RED driver
`NavSmokeTest` builds a `NavHost` (needs the new `compose.navigation` test dep) and references
`FakeInventoryRepository`/`FakeAuthRepository` — none exist before the change → compile-red. After
the deps/fakes exist, the journey assertions are the behavioural red→green.

## GREEN
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
BUILD SUCCESSFUL in 19s   (no compiler warnings)
```
Per-class (test-results XML):
- `NavSmokeTest` — tests="2" skipped="0" failures="0" errors="0"
  - `signed-out user signs in, sees the plant list`
  - `accept an advisory from the detail screen`
- `InventoryScreensTest` 9, `PlantDetailAdvisoriesTest` 4, `SignInScreenTest` 3 (unchanged).
- `:feature-inventory` total 16 → 18. No failing files.

## Determinism note
First run failed both NavSmokeTest cases under `StandardTestDispatcher` (newly-navigated screen's
ViewModel coroutine scheduled past `advanceUntilIdle`; screens stuck in Loading). Switched Main to
`UnconfinedTestDispatcher`: launches run eagerly inline and the fakes never suspend, so the journey
is fully deterministic with `composeRule.waitForIdle()` alone — no sleeps, no production change.
Re-ran: green and stable.

## Scope / integrity
- `git show --stat`: 3 files, +267 — only `android/feature-inventory/**`: build.gradle (one test
  dep) + `NavSmokeFakes.kt` + `NavSmokeTest.kt`. **No `src/main`** of any module (grep 0). No
  `:app`/backend/schema/supabase change. No new production dependency. No emulator / real network /
  Hilt-test runner.
- `local.properties` not committed (grep 0).

## Final repo state
- origin/master = `da020e3abdc3bd4ada2d2ec5c4ec39a8f1a53e58`; local == origin.
- Working tree clean except git-ignored `android/local.properties`.
