# DONE — handoff 0025-android-container-selector (3b-ui-c, red→green) — 3b selectors COMPLETE

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** the add-plant **Container id** field is replaced by a **select-or-create**
control; the container-required validation now keys off the selection. The add-plant form
is **fully selector-driven (no raw-id fields)**. `:feature-inventory` tests green;
`:app:assembleDebug` SUCCESSFUL.
Final `origin/master` = `8d5187490e9171cf32a62c42a1ff2530bdd2dd0b`.

## Baseline + unblock
- HEAD at start = `5ce6f29cc14a0fb1946dece9b4ff9432e29f2b68` == origin/master; clean.
- SDK resolves (Drive mounted).

## The selector + inline create (+ validation move + wiring)
- **Tags:** anchor `FIELD_CONTAINER_SELECTOR`; menu's last entry `CONTAINER_CREATE_ITEM`
  ("➕ Create new container"); inline-create fields `FIELD_NEW_CONTAINER_NAME` /
  `_VOLUME` / `_MATERIAL` / `_DRAINAGE`; `CONTAINER_CREATE_BUTTON`. `FIELD_CONTAINER_ID`
  removed; `CONTAINER_ERROR` re-used for the no-selection error.
- **Selector:** `ExposedDropdownMenuBox` (mirrors garden-space). Anchor label =
  `container.name ?: "Container <id-prefix>"`; menu lists containers by that label, then
  the create item revealing the inline form.
- **Inline create:** name (optional), volume (parsed `toDoubleOrNull()`), material,
  drainage + a "Create container" button that calls `onCreateContainer(name.ifBlank{null},
  volume, material, drainage)` when volume parses > 0 and material/drainage are non-blank.
- **Validation moved onto selection:** submit with `selectedContainer == null` →
  `containerError = true`, no submit; else `containerId = selectedContainer.id`. Auto-select
  the newest created container via `LaunchedEffect(containers)`. `AddPlantForm` unchanged.
- **`AddPlantViewModel`:** loads `containers` in `init` (with profiles + gardenSpaces) and
  adds `createContainer(name, volumeLiters, material, drainage)` (appends result; errors →
  `_error`).
- **`MainActivity` `Routes.ADD`:** collects `vm.containers`, passes `containers = …,
  onCreateContainer = vm::createContainer`.

## Tests (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 26s
```
- `InventoryScreensTest`: **9 tests, 0 failures** (was 7). `#22` now selects the container
  ("Blue barrel") → `submitted.containerId == "…002"`. `#24` renders with
  `containers = emptyList()` (nothing auto-selected) → submit shows `CONTAINER_ERROR`,
  nothing submitted. Added **`container selector lists existing containers`** ("Blue barrel"
  + "Terracotta") and **`container create path invokes callback`** (create item → fill
  name/volume/material/drainage → button → spy got `["Green pot", 12.0, "plastic", "good"]`).
  Profile/garden-space tests + `#21`/`#23` still green.
- `PlantDetailAdvisoriesTest`: 2/2. `:app:assembleDebug`: SUCCESSFUL.

## Commit
- `8d51874` — feat(android-inventory): container select-or-create for add-plant
- `git show --stat HEAD`: 5 files, +171/−19 — only `android/feature-inventory/**` +
  `android/app/**`. `android/local.properties` NOT committed (grep 0).

## Compliance
- No `:network`/`:data`/`:domain`/backend/`shared-schemas`/`supabase` change. No new deps.
  No camera/photos/GPS/AI. SDK/Drive not touched; git-ignored `local.properties` left in
  place. `AddPlantForm` unchanged.

Final `origin/master` SHA: `8d5187490e9171cf32a62c42a1ff2530bdd2dd0b`

## 3b status
**3b (Android add-plant selectors) is COMPLETE** — profile (0023), garden-space (0024),
and container (0025) are all `ExposedDropdownMenuBox` selectors (garden-space + container
with inline select-or-create); the form has no raw-id fields and validation keys off the
container selection.

## Next (3c, per planner follow-up)
A Supabase magic-link **sign-in** screen writing the token to DataStore (replacing the
manual-token-in-DataStore assumption), grounded against the existing
`SettingsStore`/`PlantAppApiFactory` auth interceptor. Then 3d (advisory→accept→CareTask).
