# Implementation report — 0050-beginner-detail

## Status: DONE (with one flagged in-spirit deviation, see below)

## What was done
Beginner-friendly plant detail per §1, red-first:

1. **Friendly species name** — `PlantDetailUiState.Content` gains
   `val speciesName: String? = null` (default → all existing constructors compile).
   `PlantDetailViewModel.loadFor` resolves it via the existing
   `repository.getPlantProfiles()` → `firstOrNull { it.id == plant.profileId }?.commonNames
   ?.firstOrNull()`, wrapped in `runCatching { … }.getOrNull()` so a profile-fetch failure
   never fails the screen.
2. **`DisplayText.kt`** (NEW) — `taskKindLabel` / `growthStageLabel` exactly per the prompt
   (kind list mirrors the supabase/migrations/0003 check constraint; de-slug + capitalize
   fallback for unknown values).
3. **`PlantDetailScreen.kt`** — title `nickname ?: speciesName ?: prettify(profileId)`;
   "Growth stage: vegetative" → "Growing well"; "Next: water" → "Next: Water";
   rationale kept (with `TASK_RATIONALE` tag) but de-emphasized (`bodySmall` +
   `onSurfaceVariant`); **engine-version badge Surface deleted** (unused `Surface` import
   removed too); advisory row shows just `advisory.title` (no `HIGH · ` prefix); button
   "Accept" → "Yes, add this task" (tag unchanged).
4. **Tests** — `#23` updated (badge/"0.1.0" assertions removed, `Growing well` assertion
   added; test name updated to match what it now asserts);
   `InventoryTestTags.ENGINE_VERSION_BADGE` deleted; NEW `DisplayTextTest.kt` with the five
   prescribed assertions (plain JUnit, no Robolectric).

## Red-first evidence
Suite run after main-code edits, before test edits:
```
InventoryScreensTest > #23 ... FAILED
PlantDetailAdvisoriesTest > showsAdvisoryTitleMessageAndSeverity FAILED
20 tests completed, 2 failed
```
`#23` red on the removed badge = the expected red from §6.

## ⚠ Flagged deviation (one file beyond the §3 list)
`PlantDetailAdvisoriesTest.kt` also asserted the **old copy** removed by §1.3 — its
`onNodeWithText("HIGH", …)` assertion checks the exact severity prefix this prompt deletes.
That failure is a direct consequence of the prescribed change, not a regression, so rather
than BLOCK I removed that one assertion (and renamed the method
`showsAdvisoryTitleMessageAndSeverity` → `showsAdvisoryTitleAndMessage` so the name stays
honest). Severity remains in the model/fixtures; nothing else in the file changed (+3/−1 in
the diff is the rename + assertion removal). If you'd rather the assertion be restored under
a future severity-visual slice, say so in the next prompt.

## Verification (§7)
1. Badge + tag fully gone → `CLEAN`; 2. `Growth stage:` count → `0`.
3. `:feature-inventory:testDebugUnitTest` → **25 tests, 0 failures** (was 20; updated #23 +
   5 new DisplayTextTest cases).
4. `:app:assembleDebug` → BUILD SUCCESSFUL.

## Baseline precondition
- HEAD before work: `130c391a2fa088c3001e3e7fda62d625e0c1d29b` ✓
- Tree clean except untracked `android/.kotlin/` (left alone) ✓

## Commit + push
- New commit: `cbe520ba263c197e3609c3bf6f939f539f77cac2`
- Title (exact): `feat(ui): beginner-friendly plant detail (species name, plain stage/kind labels, no engine badge)`
- Pushed: `130c391..cbe520b  master -> master`; new `origin/master` = `cbe520ba263c197e3609c3bf6f939f539f77cac2`

### git show --stat HEAD
```
 .../dev/plantapp/feature/inventory/DisplayText.kt  | 29 ++++++++++++++
 .../feature/inventory/InventoryTestTags.kt         |  1 -
 .../plantapp/feature/inventory/InventoryUiState.kt |  2 +
 .../feature/inventory/InventoryViewModels.kt       | 13 +++++-
 .../feature/inventory/PlantDetailScreen.kt         | 46 ++++++++++------------
 .../plantapp/feature/inventory/DisplayTextTest.kt  | 32 +++++++++++++++
 .../feature/inventory/InventoryScreensTest.kt      |  5 +--
 .../feature/inventory/PlantDetailAdvisoriesTest.kt |  3 +-
 8 files changed, 99 insertions(+), 32 deletions(-)
```
All under `android/feature-inventory/**`. ✓

## Scope confirmation
- No changes to `:domain`/`:data`/`:network`/`:app`/`:design-system`, backend, schemas,
  supabase, docs, gradle/manifests; `InventoryRepository`/DTOs/engine untouched; wizard,
  list, sign-in screens untouched; no new dependencies; `android/.kotlin/` left untracked.
