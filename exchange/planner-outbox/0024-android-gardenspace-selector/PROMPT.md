# Next Implementation Prompt — backlog (3b-ui-b): add-plant **garden-space select-or-create**

**Backlog item (3) UX follow-ups, step 3b-ui, sub-step b.** Replace the raw **Garden space id**
text field with a **select-or-create** control: a dropdown of the caller's existing garden
spaces (`getGardenSpaces()`, landed `0022`) plus an inline "create new" path using the existing
`createGardenSpace(name, kind)` repo method. Profile is already a dropdown (`0023`). Container id
and growth stage stay as-is — **container** becomes its own select-or-create in the next handoff
(3b-ui-c).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`20f4e354486f79d93e21bdbacbec24ff9d4ae7c3` == `origin/master`, clean. `AddPlantScreen` is a
stateless composable `AddPlantScreen(profiles, onSubmit, modifier, onCancel)`; the profile field
is an `ExposedDropdownMenuBox` (pattern to mirror). `AddPlantViewModel` loads `profiles` in
`init` and exposes `submit()`. `:domain` has `GardenSpace(id, name, kind)`,
`InventoryRepository.getGardenSpaces()` and `createGardenSpace(name, kind): GardenSpace`. The
screen is hosted by `:app` `MainActivity.kt` `Routes.ADD`. UI tests are Robolectric
(`InventoryScreensTest.kt`), driving the stateless screen with fixture lists + callback spies.

Single logical change (the garden-space select-or-create selector + VM load/create + route
wiring) → one commit. Red→green (the existing `#22`/`#24` tests type into
`FIELD_GARDEN_SPACE_ID` — they must move to the selector; that is the red-first driver).

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Replace the
garden-space **id text field** with a **select-or-create** control. Mirror the profile
`ExposedDropdownMenuBox` already in `AddPlantScreen.kt`. **Consult Material3 docs** as needed.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect 20f4e354486f79d93e21bdbacbec24ff9d4ae7c3 == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`InventoryTestTags.kt`** — add:
   `FIELD_GARDEN_SPACE_SELECTOR = "field_garden_space_selector"` (dropdown anchor),
   `GARDEN_SPACE_CREATE_ITEM = "garden_space_create_item"` (the "Create new…" menu entry),
   `FIELD_NEW_GARDEN_SPACE_NAME = "field_new_garden_space_name"`,
   `FIELD_NEW_GARDEN_SPACE_KIND = "field_new_garden_space_kind"`,
   `GARDEN_SPACE_CREATE_BUTTON = "garden_space_create_button"`. Stop using `FIELD_GARDEN_SPACE_ID`.
2. **`AddPlantScreen.kt`** — add params `gardenSpaces: List<dev.plantapp.domain.model.GardenSpace>`
   and `onCreateGardenSpace: (name: String, kind: String) -> Unit` (place after `profiles`,
   before `onSubmit`). Replace the `Field("Garden space id", …)` with:
   - An `ExposedDropdownMenuBox` anchored by a read-only `OutlinedTextField` tagged
     `FIELD_GARDEN_SPACE_SELECTOR` (label "Garden space", placeholder "Select a garden space"),
     showing the selected space's `name`. The menu lists each `gardenSpaces` entry by `name`
     (selecting sets the chosen `GardenSpace`), followed by a final
     `DropdownMenuItem` "➕ Create new garden space" tagged `GARDEN_SPACE_CREATE_ITEM` that
     reveals the inline create form.
   - Inline create form (shown when the create item is chosen): an `OutlinedTextField` for name
     (`FIELD_NEW_GARDEN_SPACE_NAME`), one for kind (`FIELD_NEW_GARDEN_SPACE_KIND`), and a
     `Button` (`GARDEN_SPACE_CREATE_BUTTON`, label "Create garden space") that calls
     `onCreateGardenSpace(name.trim(), kind.trim())` when both are non-blank.
   - Track `selectedGardenSpace: GardenSpace?`. On submit, `gardenSpaceId = selectedGardenSpace?.id
     ?: ""`. After a create, the VM appends the new space to `gardenSpaces`; auto-select the
     newest by adding `LaunchedEffect(gardenSpaces) { if (selectedGardenSpace == null)
     gardenSpaces.lastOrNull()?.let { selectedGardenSpace = it } }` (so a freshly created space
     becomes the selection). Leave the container/growth/last-watered fields and the
     container-required validation unchanged.
3. **`InventoryViewModels.kt`** — `AddPlantViewModel`: add
   `private val _gardenSpaces = MutableStateFlow<List<GardenSpace>>(emptyList())` +
   `val gardenSpaces: StateFlow<List<GardenSpace>> = _gardenSpaces.asStateFlow()`, load it in the
   existing `init` (alongside profiles: `_gardenSpaces.value = repository.getGardenSpaces()`), and
   add `fun createGardenSpace(name: String, kind: String) { viewModelScope.launch { try { val gs =
   repository.createGardenSpace(name, kind); _gardenSpaces.value = _gardenSpaces.value + gs } catch
   (e: Exception) { _error.value = e.message ?: "Could not create garden space" } } }`. (import
   `dev.plantapp.domain.model.GardenSpace`.)
4. **`:app` `MainActivity.kt`** — in `Routes.ADD`: `val gardenSpaces by vm.gardenSpaces.collectAsState()`
   and pass `gardenSpaces = gardenSpaces, onCreateGardenSpace = vm::createGardenSpace` to
   `AddPlantScreen`. No other route change.

### Tests — `InventoryScreensTest.kt`
- Add a `gardenSpaces` fixture, e.g. `listOf(GardenSpace("00000000-0000-4000-8000-000000000003",
  "West Balcony","balcony"), GardenSpace("…0004","East Patio","patio"))`.
- **Update `#22`**: render `AddPlantScreen(profiles = profiles, gardenSpaces = gardenSpaces,
  onCreateGardenSpace = { _, _ -> }, onSubmit = { submitted = it })`; select the profile (as now),
  open `FIELD_GARDEN_SPACE_SELECTOR`, pick "West Balcony", fill container/growth, submit; assert
  `submitted?.gardenSpaceId == "00000000-0000-4000-8000-000000000003"`.
- **Update `#24`**: same selector path; container-required error still shows; nothing submits.
- **Add** `garden-space selector lists existing spaces`: open the selector, assert "West Balcony"
  and "East Patio" are displayed.
- **Add** `garden-space create path invokes callback`: open selector → click
  `GARDEN_SPACE_CREATE_ITEM` → type name + kind → click `GARDEN_SPACE_CREATE_BUTTON`; assert a
  spy `onCreateGardenSpace` received the entered (name, kind).

### Forbidden
- No change to `:network`, `:data`, `:domain`, backend, `shared-schemas`, `supabase`. No new
  dependency. Do not change the container field in this step (3b-ui-c). No
  camera/photos/GPS/notifications/AI. Don't mount/repoint the SDK/Drive; don't commit
  `android/local.properties`. `AddPlantForm` unchanged.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Red→green: before the change the updated tests reference the garden-space selector that doesn't
exist; after, `:feature-inventory` Robolectric tests pass (updated `#22`/`#24` + the two new
garden-space tests green; profile dropdown test + `#21`/`#23` still green) and `:app:assembleDebug`
compiles. Report counts + new test names + assemble result.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/feature-inventory/ android/app/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-inventory): garden-space select-or-create for add-plant"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The selector + inline create (anchor/item/field/button tags), the VM `gardenSpaces` load +
   `createGardenSpace`, and the `MainActivity` wiring; how selection/creation maps to
   `gardenSpaceId`.
2. `:feature-inventory:testDebugUnitTest` (count before→after, updated/added tests green) +
   `:app:assembleDebug` result.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/feature-inventory/**` + `android/app/**` changed (not `local.properties`).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `feature-inventory/**`+`app/**`; selector + create + wiring; tests green;
assemble OK). Then **3b-ui-c**: container **select-or-create** (dropdown from `getContainers()` +
inline create via `createContainer(name, volumeLiters, material, drainage)`) replacing the last id
field — this also lets the container-required validation key off the selection. Then 3c
(magic-link sign-in → DataStore token), 3d (advisory→accept→CareTask). Then (2) emulator e2e
smoke; then (4) Slice 3 (WorkManager local first; STOP for owner Firebase/FCM setup). Vision-check
each product-surface step.
