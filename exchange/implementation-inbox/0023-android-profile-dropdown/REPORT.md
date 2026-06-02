# DONE — handoff 0023-android-profile-dropdown (3b-ui-a, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** the add-plant **Profile id** text field is replaced by a **catalog dropdown**
(`ExposedDropdownMenuBox`) sourced from `getPlantProfiles()`. `:feature-inventory`
Robolectric tests green; `:app:assembleDebug` compiles.
Final `origin/master` = `20f4e354486f79d93e21bdbacbec24ff9d4ae7c3`.

## Baseline + unblock
- HEAD at start = `3fba7184c52e87861dc222d4c42ecd11b9d36003` == origin/master; clean.
- SDK resolves (Drive mounted; `~/Android/Sdk/platforms` → android-34/35/36/36.1).

## The dropdown (and wiring)
- **Anchor tag:** `FIELD_PROFILE_SELECTOR` (`field_profile_selector`) on a read-only
  `OutlinedTextField` inside a Material3 `ExposedDropdownMenuBox`
  (`menuAnchor(MenuAnchorType.PrimaryNotEditable)`), placeholder "Select a profile",
  with the scientific name as supporting text once chosen. `FIELD_PROFILE_ID` removed.
- **Label rule:** `commonNames.firstOrNull() ?: scientificName` (e.g. "Tomato").
- **Selection → profileId:** the menu lists each `profiles` entry by label; selecting one
  stores that `PlantProfile`; on submit, `AddPlantForm.profileId = selectedProfile.id`
  (e.g. "Tomato" → `solanum-lycopersicum`). `AddPlantForm` is unchanged.
- Container/garden-space/growth-stage/last-watered fields and the container-required
  validation are unchanged (those become selectors in 3b-ui-b).
- **`AddPlantViewModel`** now loads the catalog in `init` (`repository.getPlantProfiles()`)
  into `profiles: StateFlow<List<PlantProfile>>` (errors → existing `_error`); `submit()`
  unchanged.
- **`MainActivity`** `Routes.ADD`: `val profiles by vm.profiles.collectAsState()` →
  `AddPlantScreen(profiles = profiles, …)`.

## Tests (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 1m 28s
```
- `InventoryScreensTest`: **5 tests, 0 failures** (was 4). `#22` and `#24` now drive the
  dropdown (open `FIELD_PROFILE_SELECTOR` → click "Tomato") instead of typing an id; new
  test **`add-plant profile dropdown lists catalog profiles`** asserts both "Tomato" and
  "Basil" are listed. `#21`/`#23` still green.
- `PlantDetailAdvisoriesTest`: 2/2 (unchanged).
- `:app:assembleDebug`: BUILD SUCCESSFUL (route wiring + VM type-check).

## Commit
- `20f4e35` — feat(android-inventory): profile dropdown selector for add-plant
- `git show --stat HEAD`: 5 files, +86/−10 — only `android/feature-inventory/**` +
  `android/app/**` (MainActivity, AddPlantScreen, InventoryTestTags, InventoryViewModels,
  InventoryScreensTest). `android/local.properties` NOT committed (grep 0).

## Compliance
- No `:network`/`:data`/`:domain`/backend/`shared-schemas`/`supabase` change. No new deps
  (Material3 already present). Only the profile field changed (garden-space/container/
  growth untouched — 3b-ui-b). No camera/photos/GPS/AI. SDK/Drive not touched; git-ignored
  `local.properties` left in place.

Final `origin/master` SHA: `20f4e354486f79d93e21bdbacbec24ff9d4ae7c3`

## Next (3b-ui-b, per planner follow-up)
Garden-space + container **select-or-create** selectors (dropdowns from
`getGardenSpaces()`/`getContainers()` + inline create via the existing
`createGardenSpace`/`createContainer` repo methods) replacing those two id fields, + tests.
Then 3c (magic-link sign-in → DataStore), 3d (advisory→accept→CareTask).
