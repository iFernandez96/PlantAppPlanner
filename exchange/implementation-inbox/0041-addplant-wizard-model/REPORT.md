# DONE — handoff 0041-addplant-wizard-model (beginner wizard H1, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** the beginner add-plant wizard's data choices are pinned as a pure, unit-tested Kotlin
model — pot sizes (sold-by label → litres for the engine), location presets (label → backend
`kind`), and the category→emoji map, plus the hidden technical defaults. No UI (that's H2). Final
`origin/master` = `12f0dbb4aabc0a774f507a17ed91394f0a48de98`.

## Baseline + unblock
- HEAD at start = `786c12d…` == origin/master; clean. SDK resolves.

## The model — `:feature-inventory/.../addplant/WizardModel.kt` (new, pure Kotlin, no Android)
- `data class PotSizeOption(label, volumeLiters)` + `AddPlantWizardModel.POT_SIZES` — 6, in order:
  4-inch pot → 0.5, 6-inch pot → 1.5, 1-gallon pot → 4.0, 5-gallon bucket → 19.0, Window box → 6.0,
  Raised bed / in-ground → 75.0. (`volumeLiters` is the only technical value the size choice feeds
  the engine: factor = clamp(vol / recommendedMin, .5, 1.5).)
- `data class LocationPreset(label, kind)` + `LOCATION_PRESETS` — Windowsill→`windowsill`,
  Balcony→`balcony`, Backyard→`yard`, Indoors→`indoor`.
- `categoryIcon(category)` — case-insensitive category→emoji (fruit🍅 berry🍓 herb🌿 vegetable🥬
  vine🍇 root🥕 succulent🌵 ornamental🌸), unknown/empty → 🌱. Data-driven via
  `PlantProfile.category`, not per-species.
- Hidden defaults the novice never sets: `DEFAULT_MATERIAL = "plastic"`, `DEFAULT_DRAINAGE = "good"`,
  `DEFAULT_GROWTH_STAGE = "seedling"`.

## Tests — `:feature-inventory/.../AddPlantWizardModelTest.kt` (new, JUnit4, 3)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
BUILD SUCCESSFUL in 27s
```
- `potSizesAreTheSixExpectedOptionsInOrderWithPositiveVolumes` — exact labels + volumes (5-gallon
  bucket → 19.0, Raised bed → 75.0), all > 0.
- `locationPresetsMapLabelsToBackendKinds` — Backyard→yard, Indoors→indoor, etc.
- `categoryIconMapsKnownCategoriesAndFallsBackForUnknown` — all 8 known, case-insensitive, unknown
  & empty → 🌱.
- `:feature-inventory` total **22 → 25** (AddPlantWizardModelTest 3, InventoryScreensTest 9,
  NavSmokeTest 2, NotificationPermissionTest 4, PlantDetailAdvisoriesTest 4, SignInScreenTest 3).
  All green.

## Commit
- `12f0dbb` — feat(android-inventory): pure add-plant wizard model (pot sizes, location presets, category icons)
- `git show --stat HEAD`: 2 files, +103 — only `android/feature-inventory/**` (addplant/WizardModel.kt
  + AddPlantWizardModelTest.kt). `local.properties` NOT committed (grep 0).

## Compliance
- No UI/composable/screen change (H2). No `:network`/`:data`/`:domain`/backend/schema change. No new
  dependency. No `android.*` imports in `WizardModel.kt` (pure, JVM-testable). SDK/Drive untouched.

Final `origin/master` SHA: `12f0dbb4aabc0a774f507a17ed91394f0a48de98`

## Next (per planner follow-up)
H2 (`0042`): the `AddPlantWizard` composable — a 3-step wizard (What are you growing? → Where will
it live? → What's it planted in?) + confirmation, replacing the jargon `AddPlantScreen`: species
tiles (`categoryIcon` + `commonNames.first()` from `getPlantProfiles()`), location preset tiles
(→ `createGardenSpace`), pot-size tiles (→ `createContainer` with `volumeLiters` from `POT_SIZES` +
hidden material/drainage defaults), defaulted `growthStage`, then `addPlant`; big tappable targets,
plain language; `:app` route wiring + Robolectric tests.
