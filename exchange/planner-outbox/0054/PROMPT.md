# Implementation prompt 0054 — wizard shows errors + natural confirm copy (Wave 2 / W1 slice 7)

## 1. Scope (exactly one logical change)
Two halves of the same user story — "the wizard talks to you like a person when something
happens":

**A. Surface create/add failures.** `AddPlantViewModel` already collects failures into
`val error: StateFlow<String?>` (`InventoryViewModels.kt:64–65`, set at lines 83/94/105/124) but
nothing renders it — the 0051 root-cause review showed a failed space-create leaves the user at
a silently disabled Add forever. Fix:
- `AddPlantWizard(...)` gains `error: String? = null` parameter.
- When non-null, render at the top of the wizard body (above the tiles/confirm, all steps) a
  Hearth-styled error card: `GlassCard` containing plain copy
  `"Something didn't work. Please try again."` (titleSmall) and the raw `error` message under it
  (`bodySmall`, `onSurfaceVariant`); card `testTag(InventoryTestTags.WIZARD_ERROR)` — add const
  `WIZARD_ERROR = "wizard_error"`.
- `MainActivity.kt` `composable(Routes.ADD)`: `val error by vm.error.collectAsState()` and pass
  it to `AddPlantWizard(error = error, …)`.

**B. Natural confirm copy.** `"Add your $species to the $place?"` produces "…to the Indoors?".
- `LocationPreset` (`WizardModel.kt:8`) gains `val phrase: String`:
  Windowsill → `"on the windowsill"`, Balcony → `"on the balcony"`,
  Backyard → `"in the backyard"`, Indoors → `"indoors"`.
- The wizard stores the picked preset's phrase (new `targetSpacePhrase` var alongside
  `targetSpaceName`, set in the step-2 tile click) and the confirm line
  (`AddPlantWizard.kt:178`) becomes `"Add your $species $phrase?"` with fallback phrase
  `"to its new spot"` when null.

Red-first: wizard test asserting the error card shows for `error = "boom"` (fails before A).

## 2. Forbidden changes
- Do NOT touch `:domain`, `:data`, `:network`, `:design-system`, backend, schemas, supabase,
  gradle/manifest. In `:app` touch ONLY the `composable(Routes.ADD)` block.
- Do NOT change wizard step logic, tile behavior, kinds (0051 mapping stays), Add gating, or
  the list/detail/sign-in screens. Do NOT auto-clear or retry errors (future slice).
- No new dependencies.

## 3. Exact files to touch (6)
- `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/WizardModel.kt`
  (LocationPreset + phrase; presets updated)
- `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/AddPlantWizard.kt`
  (error param + error card; targetSpacePhrase; confirm line)
- `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryTestTags.kt`
  (+ WIZARD_ERROR)
- `android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt` (ADD composable only)
- `android/feature-inventory/src/test/kotlin/dev/plantapp/feature/inventory/AddPlantWizardTest.kt`
  (red-first error-card test + a confirm-copy assertion: drive Basil→Windowsill→any pot and
  assert text `"Add your Basil on the windowsill?"`)
- `android/feature-inventory/src/test/kotlin/dev/plantapp/feature/inventory/AddPlantWizardModelTest.kt`
  (assert each preset's phrase; update constructor usages)

## 4. Baseline precondition (STOP-and-report if different)
- Repo `/home/israel/Documents/Development/PlantApp`, branch `master`.
- Expected HEAD: `1019e19842bf49030a21b7149f2f60c00b736712` (0053).
- Tree clean except untracked `android/.kotlin/` (leave it). Otherwise STOP + BLOCKED report.

## 5. Exact commands
```bash
cd /home/israel/Documents/Development/PlantApp
git rev-parse HEAD && git status --porcelain
# 1) RED: add ONLY the new error-card test, run:
cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
#    -> expect exactly that test to FAIL (no error param/tag yet — it won't compile; if so,
#       comment the test's body assertions are fine: a compile-red on the missing parameter is
#       the expected red. Capture the failing output either way.)
# 2) GREEN: apply §1 A+B fully, re-run suite, then:
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
```

## 6. Expected failure mode
Red step: the new test fails (assertion or compile error on the missing `error` parameter —
both count as the expected red; say which you saw). Green step: full suite passes; any other
failure is a regression: STOP, revert, report.

## 7. Standalone verification
- **Type:** red-first → green + planner device follow-up (kill backend → wizard shows the error
  card instead of a silent dead Add).
- **Commands & what they prove:** §5 red output; §5 green suite run + new total count;
  `grep -c "WIZARD_ERROR" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/AddPlantWizard.kt` → ≥1 (card wired);
  `grep -c "to the \$place" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/AddPlantWizard.kt` → `0` (old copy gone);
  `:app:assembleDebug` BUILD SUCCESSFUL.
- **Report:** outputs verbatim.

## 8. Commit title (exact)
```
feat(wizard): surface create/add errors in the wizard and use natural confirm copy
```

## 9. Push requirement
Commit and push to `origin master` (fast-forward expected). One change → one commit → one push.

## 10. Final-report requirements
Report to `exchange/implementation-inbox/0054/`: `git show --stat HEAD` (exactly the 6 files),
red+green evidence, new test count, commit hash, push confirmation (new `origin/master`), scope
confirmation (ADD composable only in :app; no step-logic changes).
