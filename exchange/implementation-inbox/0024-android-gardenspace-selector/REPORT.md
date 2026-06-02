# DONE — handoff 0024-android-gardenspace-selector (3b-ui-b, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** the add-plant **Garden space id** text field is replaced by a
**select-or-create** control (dropdown of `getGardenSpaces()` + inline create via
`createGardenSpace`). `:feature-inventory` tests green; `:app:assembleDebug` SUCCESSFUL.
Final `origin/master` = `5ce6f29cc14a0fb1946dece9b4ff9432e29f2b68`.

## Baseline + unblock
- HEAD at start = `20f4e354486f79d93e21bdbacbec24ff9d4ae7c3` == origin/master; clean.
- SDK resolves (Drive mounted).

## The selector + inline create (+ wiring)
- **Tags:** anchor `FIELD_GARDEN_SPACE_SELECTOR`; the menu's last entry
  `GARDEN_SPACE_CREATE_ITEM` ("➕ Create new garden space"); inline-create fields
  `FIELD_NEW_GARDEN_SPACE_NAME` / `FIELD_NEW_GARDEN_SPACE_KIND`; create button
  `GARDEN_SPACE_CREATE_BUTTON`. `FIELD_GARDEN_SPACE_ID` removed.
- **Selector:** `ExposedDropdownMenuBox` (mirrors the profile dropdown). Anchor shows the
  selected space's `name`; the menu lists each `gardenSpaces` entry by `name` (selecting
  sets `selectedGardenSpace`), then the create item that reveals the inline form.
- **Inline create:** name + kind fields + a "Create garden space" button that calls
  `onCreateGardenSpace(name.trim(), kind.trim())` when both are non-blank.
- **Auto-select:** `LaunchedEffect(gardenSpaces) { if (selectedGardenSpace == null)
  gardenSpaces.lastOrNull()?.let { selectedGardenSpace = it } }` — a freshly created space
  (appended by the VM) becomes the selection.
- **Submit mapping:** `gardenSpaceId = selectedGardenSpace?.id ?: ""`. `AddPlantForm`
  unchanged. Container/growth/last-watered fields + the container-required validation are
  unchanged (container becomes a selector in 3b-ui-c).
- **`AddPlantViewModel`:** loads `gardenSpaces` in `init` (alongside profiles) and adds
  `createGardenSpace(name, kind)` (appends the created `GardenSpace` to `_gardenSpaces`;
  errors → existing `_error`).
- **`MainActivity` `Routes.ADD`:** collects `vm.gardenSpaces` and passes
  `gardenSpaces = …, onCreateGardenSpace = vm::createGardenSpace`.

## Tests (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL
```
- `InventoryScreensTest`: **7 tests, 0 failures** (was 5). `#22`/`#24` now select the
  garden space via `FIELD_GARDEN_SPACE_SELECTOR` ("West Balcony"); added
  **`garden-space selector lists existing spaces`** (West Balcony + East Patio present) and
  **`garden-space create path invokes callback`** (open → create item → name+kind → create
  button → spy receives `("North Ledge","window-ledge")`). The profile dropdown test +
  `#21`/`#23` still green.
- One mid-run fix: because the auto-select puts the last space ("East Patio") in the
  anchor, that name matched twice (anchor + menu) — switched the "lists existing spaces"
  assertions to `onAllNodesWithText(...).onFirst().assertIsDisplayed()`.
- `PlantDetailAdvisoriesTest`: 2/2. `:app:assembleDebug`: SUCCESSFUL (APK 11.3 MB).

## Commit
- `5ce6f29` — feat(android-inventory): garden-space select-or-create for add-plant
- `git show --stat HEAD`: 5 files, +144/−11 — only `android/feature-inventory/**` +
  `android/app/**`. `android/local.properties` NOT committed (grep 0).

## Compliance
- No `:network`/`:data`/`:domain`/backend/`shared-schemas`/`supabase` change. No new deps.
  Container field unchanged (3b-ui-c). No camera/photos/GPS/AI. SDK/Drive not touched;
  git-ignored `local.properties` left in place. `AddPlantForm` unchanged.

Final `origin/master` SHA: `5ce6f29cc14a0fb1946dece9b4ff9432e29f2b68`

## Next (3b-ui-c, per planner follow-up)
Container **select-or-create** (dropdown from `getContainers()` + inline create via
`createContainer(name, volumeLiters, material, drainage)`) replacing the last id field;
the container-required validation keys off the selection. Then 3c (magic-link sign-in →
DataStore), 3d (advisory→accept→CareTask).
