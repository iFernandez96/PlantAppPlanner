# Implementation report — 0059-friendly-errors

## Status: DONE

## 1. Scope confirmation + git show --stat HEAD
Only the 6 listed files changed:
```
 .../kotlin/dev/plantapp/feature/inventory/DisplayText.kt    |  9 +++++++++
 .../dev/plantapp/feature/inventory/InventoryViewModels.kt   | 12 ++++++------
 .../dev/plantapp/feature/inventory/PlantDetailScreen.kt     |  2 +-
 .../dev/plantapp/feature/inventory/PlantListScreen.kt       |  2 +-
 .../dev/plantapp/feature/inventory/DisplayTextTest.kt       | 13 +++++++++++++
 .../plantapp/feature/inventory/PlantListViewModelTest.kt    | 12 ++++++++++++
 6 files changed, 42 insertions(+), 8 deletions(-)
```
- `DisplayText.kt` — `friendlyError(e, fallback)` added verbatim (§5a) +
  `SessionExpiredException` import. Never returns `e.message`.
- `InventoryViewModels.kt` — all 6 `e.message ?: "…"` sites replaced with the exact §5b
  fallbacks (PlantListViewModel ×1 — the `SessionExpiredException -> SignedOut` branch kept
  FIRST in the `when`, untouched; AddPlantViewModel ×4; PlantDetailViewModel ×1).
  `PlantDetailUiState.Error("Plant not found")` and the advisory `accept()` swallow-and-reload
  catch left as-is. SignInViewModel untouched (0058).
- `PlantListScreen.kt` / `PlantDetailScreen.kt` — technical "Couldn't load plant(s): " prefixes
  dropped; the friendly message renders alone.
- Tests — red-first `loadErrorShowsFriendlyCopyNotRawExceptionText` in
  `PlantListViewModelTest`; `friendlyErrorUsesTheFallbackAndNeverTheExceptionMessage` +
  `friendlyErrorNamesSessionExpiry` in `DisplayTextTest`.
Untracked `android/.kotlin/` left alone; no design-system/wizard/MainActivity/backend/schema/
migration changes; no new dependencies.

## 2. RED evidence (§7 step 1 — test added on baseline code)
```
PlantListViewModelTest > loadErrorShowsFriendlyCopyNotRawExceptionText FAILED
    java.lang.AssertionError at PlantListViewModelTest.kt:93
5 tests completed, 1 failed
```
JUnit XML failure message (verbatim):
```
java.lang.AssertionError: raw exception text must not reach the UI
```
(The state message contained the raw `HTTP 500 http://10.0.0.179:3000/plants` string.)
Exactly one failure, as predicted.

## 3. GREEN output
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 14s
143 actionable tasks: 17 executed, 126 up-to-date
```
JUnit XML aggregate: **feature-inventory: tests=39 failures+errors=0** (36 from 0058 + 3 new —
matches the prompt's expected 39). `:app:assembleDebug` BUILD SUCCESSFUL (same invocation).

## 4. Grep proof
```
$ grep -c "e.message" feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryViewModels.kt
0
```
✓ (grep exit 1 = zero matches = the pass condition).

## 5. Commit + push
- New commit: `1a5dede5fb9823ae2640b2932bf3691f46fc9db7`
- Title (exact): `feat(ui): friendly plain-language errors everywhere — no raw exception text`
- One commit (red test + implementation + DisplayText tests, per §8).
- Pushed: `4517f44..1a5dede  master -> master` (fast-forward);
  new `origin/master` = `1a5dede5fb9823ae2640b2932bf3691f46fc9db7`.

## 6. Deviations
None.
