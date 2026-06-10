# Implementation report — 0054-wizard-errors-confirm-copy

## Status: DONE

## What was done
**A. Failures surfaced.** `AddPlantWizard(...)` gains `error: String? = null`. When non-null, a
Hearth `GlassCard` renders at the top of the wizard body (above tiles/confirm, all steps):
plain copy `"Something didn't work. Please try again."` (`titleSmall`) + the raw message
(`bodySmall`, `onSurfaceVariant`); card tagged `WIZARD_ERROR` (`"wizard_error"` const added to
`InventoryTestTags`). `MainActivity.kt`'s `composable(Routes.ADD)` block now collects
`vm.error` and passes it (`val error by vm.error.collectAsState()` → `AddPlantWizard(error =
error, …)`). No auto-clear/retry (future slice).

**B. Natural confirm copy.** `LocationPreset` gains `val phrase: String` — "on the windowsill"
/ "on the balcony" / "in the backyard" / "indoors". The wizard stores the picked preset's
phrase in a new `targetSpacePhrase` var (set in the step-2 tile click alongside name/kind) and
the confirm line is now `"Add your $species $phrase?"` with fallback `"to its new spot"`.
Kinds (0051 mapping), labels, step logic, tile behavior, Add gating all unchanged.

**Tests.** Red-first error-card test (`error = "boom"` → card + both texts displayed);
confirm-copy test driving Basil → Windowsill → 6-inch pot asserting
`"Add your Basil on the windowsill?"`; model test asserting all four phrases.

## Red evidence (§5 step 1: only the error-card test added)
Compile-red (as §6 anticipated — the parameter/tag don't exist on baseline):
```
e: …/AddPlantWizardTest.kt:122:17 No parameter with name 'error' found.
e: …/AddPlantWizardTest.kt:125:53 Unresolved reference 'WIZARD_ERROR'.
> Task :feature-inventory:compileDebugUnitTestKotlin FAILED
```

## Green evidence
- `:feature-inventory:testDebugUnitTest` → BUILD SUCCESSFUL; JUnit XML aggregate
  **tests=33 failures+errors=0** (30 from 0053 + error-card + confirm-copy + phrases tests).
- `grep -c "WIZARD_ERROR" …/AddPlantWizard.kt` → `1` (card wired).
- `grep -c 'to the $place' …/AddPlantWizard.kt` → `0` (old copy gone).
- `:app:assembleDebug` → BUILD SUCCESSFUL.

## Baseline precondition
- HEAD before work: `1019e19842bf49030a21b7149f2f60c00b736712` ✓
- Tree clean except untracked `android/.kotlin/` (left alone) ✓

## Commit + push
- New commit: `a0cbc3d93a4db8d2ef47109ea5a4a8943712ee0a`
- Title (exact): `feat(wizard): surface create/add errors in the wizard and use natural confirm copy`
- Pushed: `1019e19..a0cbc3d  master -> master`; new `origin/master` =
  `a0cbc3d93a4db8d2ef47109ea5a4a8943712ee0a`

### git show --stat HEAD
```
 .../kotlin/dev/plantapp/android/MainActivity.kt    |  2 ++
 .../feature/inventory/InventoryTestTags.kt         |  1 +
 .../feature/inventory/addplant/AddPlantWizard.kt   | 27 +++++++++++++++--
 .../feature/inventory/addplant/WizardModel.kt      | 13 +++++----
 .../feature/inventory/AddPlantWizardModelTest.kt   | 14 +++++++++
 .../feature/inventory/AddPlantWizardTest.kt        | 34 ++++++++++++++++++++++
 6 files changed, 83 insertions(+), 8 deletions(-)
```
Exactly the 6 files. ✓

## Scope confirmation
- `:app` touched only inside `composable(Routes.ADD)` (2 lines: collect + pass).
- No `:domain`/`:data`/`:network`/`:design-system`/backend/schema/supabase/gradle/manifest
  changes; step logic, tiles, kinds, Add gating, list/detail/sign-in untouched; no auto-clear
  or retry added; no new dependencies; `android/.kotlin/` left untracked.
- Planner device follow-up: kill backend → wizard shows the error card instead of a silent
  dead Add.
