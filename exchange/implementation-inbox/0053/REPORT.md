# Implementation report — 0053-hearth-list-rows

## Status: DONE

## What was done
Hearth list rows + last slug leak killed, per §1:

1. **Friendly names in state** — `PlantListUiState.Content` gains
   `val speciesNames: Map<String, String> = emptyMap()`. `PlantListViewModel.refresh()` also
   fetches `repository.getPlantProfiles()` via `runCatching { … }.getOrDefault(emptyList())`
   and builds the profileId → first-common-name map; a profile failure never breaks the list.
2. **Shared fallback helper** — `DisplayText.speciesFallbackName(profileId)` added (de-slug +
   capitalize); `PlantDetailScreen`'s private `prettify` deleted and the title now uses the
   shared helper (same output).
3. **PlantRow re-skin** — clickable `GlassCard(onClick = { onPlantClick(plant.id) })` (inner
   `Modifier.clickable` text dropped); content: `Row` with 16.dp padding,
   `Image(painterResource(WizardIcons.speciesIconRes(profileId)))` at 64.dp, `heightIn(min =
   104.dp)`, icon + texts vertically centered; primary text `nickname ?: speciesNames[id] ?:
   speciesFallbackName(id)` in `titleMedium`; secondary species name in `bodyMedium` +
   `onSurfaceVariant`, shown only when it differs from the primary. Each card tagged
   `PLANT_ROW_PREFIX + plant.id` (`"plant_row_"` const added to `InventoryTestTags`).
   `PlantRow` gains the `speciesNames` parameter; `items(...)` passes it from state.
4. **Test** — new red-first `InventoryScreensTest` test: list with a nickname-less plant +
   `speciesNames = {"solanum-lycopersicum": "Tomato"}` shows "Tomato" and never the slug.
   All existing tests untouched and passing (the `Content` default param + nickname-first
   ordering preserve them; NavSmokeTest's `onNodeWithText("Pasi").performClick()` still works
   through the card's onClick).

## Red-first note
The new test references `Content.speciesNames`, which does not exist on baseline — adding only
the test would have produced a compile error, not a meaningful red. So the red run was done with
the test **plus the §1.1 state field only** (default `emptyMap()`, zero rendering change): the
test then fails on rendering exactly as intended.

## Red evidence
```
InventoryScreensTest > list rows show the friendly species name, never the profile slug FAILED
    java.lang.AssertionError at InventoryScreensTest.kt:60
30 tests completed, 1 failed
```
(Line 60 = `onNodeWithText("Tomato").assertIsDisplayed()` — slug was rendered instead.)
Only the new test failed.

## Green evidence
- `:feature-inventory:testDebugUnitTest` → BUILD SUCCESSFUL; JUnit XML aggregate
  **tests=30 failures+errors=0** (29 from 0052 + 1 new).
- `grep -c "prettify" …/PlantDetailScreen.kt` → `0` (helper unified).
- `grep -c "speciesIconRes" …/PlantListScreen.kt` → `1` (icon wired).
- `:app:assembleDebug` → BUILD SUCCESSFUL.

## Baseline precondition
- HEAD before work: `a22292988b9a32c5aa04433da6e3485a189a9933` ✓
- Tree clean except untracked `android/.kotlin/` (left alone) ✓

## Commit + push
- New commit: `1019e19842bf49030a21b7149f2f60c00b736712`
- Title (exact): `feat(ui): Hearth plant-list rows — species icon + friendly names, no slugs`
- Pushed: `a222929..1019e19  master -> master`; new `origin/master` =
  `1019e19842bf49030a21b7149f2f60c00b736712`

### git show --stat HEAD
```
 .../dev/plantapp/feature/inventory/DisplayText.kt  |  5 ++
 .../feature/inventory/InventoryTestTags.kt         |  1 +
 .../plantapp/feature/inventory/InventoryUiState.kt |  6 ++-
 .../feature/inventory/InventoryViewModels.kt       | 11 ++++-
 .../feature/inventory/PlantDetailScreen.kt         |  6 +--
 .../plantapp/feature/inventory/PlantListScreen.kt  | 57 +++++++++++++++++-----
 .../feature/inventory/InventoryScreensTest.kt      | 14 ++++++
 7 files changed, 81 insertions(+), 19 deletions(-)
```
All under `android/feature-inventory/**` (the §3 list = these 7 paths). ✓

## Scope confirmation
- No `:domain`/`:data`/`:network`/`:app`/`:design-system`/backend/schema/supabase/gradle/
  manifest changes; FAB, top bar, empty/error states, wizard/sign-in untouched; detail changed
  only by the prettify→speciesFallbackName swap; no new dependencies; `android/.kotlin/` left
  untracked.
- Planner device follow-up: list shows "Tomato"/"Strawberry" with icons, 104dp Hearth rows.
