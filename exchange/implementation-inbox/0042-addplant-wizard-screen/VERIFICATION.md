# VERIFICATION — handoff 0042-addplant-wizard-screen (beginner wizard H2, red→green)

Gate: `:feature-inventory:testDebugUnitTest :app:assembleDebug`, Drive mounted.

## RED driver
`AddPlantWizardTest` references `addplant.AddPlantWizard` + the new `WIZARD_*` tags + the deleted
`AddPlantScreen` (removed) — won't compile/pass before the wizard exists → compile/behaviour red.

## GREEN
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 56s
```
Per-class (test-results XML):
- `AddPlantWizardTest` — tests="2" failures="0":
  walkTomatoBalconyFiveGallonBucketThenAddSubmitsResolvedForm (asserts onCreateGardenSpace +
  onCreateContainer@19.0L + onSubmit profileId/seedling/null + non-blank container/space ids),
  backThenReselectSameLocationDoesNotCreateDuplicate (createSpaceCalls stays 1).
- `AddPlantWizardModelTest` 3, `InventoryScreensTest` 2 (#21 + #23 kept; 7 old form tests removed),
  `NavSmokeTest` 2, `NotificationPermissionTest` 4, `PlantDetailAdvisoriesTest` 4, `SignInScreenTest` 3.
- `:feature-inventory` total 25 → 20. No failing files.
- `:app:assembleDebug` — **BUILD SUCCESSFUL** (wizard route wiring + drawables compile/merge).

## No-emoji check
`grep -rlP '[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}]'` over `android/feature-inventory/src` +
`android/app/src` → no matches. Icons are custom `<vector>` drawables; summary/labels are plain text.

## Scope / integrity
- `git show --stat HEAD`: 21 files, +516 −474 — only `android/feature-inventory/**` (AddPlantWizard,
  WizardIcons, 11 res/drawable vectors, WizardModel/tags/3 tests; `AddPlantScreen.kt` deleted) +
  `android/app/**` (MainActivity ADD route + import). No `:network`/`:data`/`:domain`/backend/schema
  change. No new dependency.
- `local.properties` not committed (grep 0). No raster images.

## Final repo state
- origin/master = `5f1e7ce102a3ad219cedd38bb75c186752da4b17`; local == origin.
- Working tree clean except git-ignored build output + `android/local.properties`.
