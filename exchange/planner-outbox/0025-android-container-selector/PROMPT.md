# Next Implementation Prompt — backlog (3b-ui-c): add-plant **container select-or-create**

**Backlog item (3) UX follow-ups, step 3b-ui, sub-step c (final selector).** Replace the last raw
id field — **Container id** — with a **select-or-create** control: a dropdown of the caller's
containers (`getContainers()`) plus an inline "create new" path using the existing
`createContainer(name, volumeLiters, material, drainage)` repo method. After this, the add-plant
form has no raw-id fields. The container-required validation moves to key off the **selection**
(no container selected → error, no submit).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`5ce6f29cc14a0fb1946dece9b4ff9432e29f2b68` == `origin/master`, clean. `AddPlantScreen` is a
stateless composable `AddPlantScreen(profiles, gardenSpaces, onCreateGardenSpace, onSubmit,
modifier, onCancel)` with profile + garden-space `ExposedDropdownMenuBox` selectors (the
garden-space one with inline select-or-create — the **exact pattern to mirror**). Container is
still `Field("Container id", …, FIELD_CONTAINER_ID)` with `containerError` keyed off a blank
string. `:domain` has `Container(id, name, volumeLiters, material, drainage)`,
`InventoryRepository.getContainers()` and `createContainer(name, volumeLiters, material,
drainage): Container`. `AddPlantViewModel` loads `profiles`+`gardenSpaces` in `init` and has
`createGardenSpace(...)`. Hosted by `:app` `MainActivity.kt` `Routes.ADD`. UI tests Robolectric
(`InventoryScreensTest.kt`).

Single logical change (the container select-or-create selector + VM load/create + route wiring) →
one commit. Red→green (`#22`/`#24` use `FIELD_CONTAINER_ID` / blank-string validation — they move
to the selector; that is the red-first driver).

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Replace the
container **id text field** with a **select-or-create** control, mirroring the garden-space
selector already in `AddPlantScreen.kt`. Drive begins red (the two tests reference
`FIELD_CONTAINER_ID` and string-blank validation).

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect 5ce6f29cc14a0fb1946dece9b4ff9432e29f2b68 == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`InventoryTestTags.kt`** — add:
   `FIELD_CONTAINER_SELECTOR = "field_container_selector"`,
   `CONTAINER_CREATE_ITEM = "container_create_item"`,
   `FIELD_NEW_CONTAINER_NAME = "field_new_container_name"`,
   `FIELD_NEW_CONTAINER_VOLUME = "field_new_container_volume"`,
   `FIELD_NEW_CONTAINER_MATERIAL = "field_new_container_material"`,
   `FIELD_NEW_CONTAINER_DRAINAGE = "field_new_container_drainage"`,
   `CONTAINER_CREATE_BUTTON = "container_create_button"`. Stop using `FIELD_CONTAINER_ID`. Keep
   `CONTAINER_ERROR` (re-used for the no-selection error).
2. **`AddPlantScreen.kt`** — add params `containers: List<dev.plantapp.domain.model.Container>`
   and `onCreateContainer: (name: String?, volumeLiters: Double, material: String, drainage:
   String) -> Unit` (place near the garden-space params). Replace the container `Field`(+error)
   with a select-or-create block mirroring garden-space:
   - `ExposedDropdownMenuBox` anchored by a read-only `OutlinedTextField` tagged
     `FIELD_CONTAINER_SELECTOR` (label "Container", placeholder "Select a container"), showing the
     selected container's `name ?: "Container ${id-prefix}"` (use `name` when present, else a
     short fallback label). The menu lists each `containers` entry by that label, then a final
     `CONTAINER_CREATE_ITEM` "➕ Create new container" revealing the inline form.
   - Inline create form: name (optional, `FIELD_NEW_CONTAINER_NAME`), volume liters
     (`FIELD_NEW_CONTAINER_VOLUME`, numeric — parse with `toDoubleOrNull()`), material
     (`FIELD_NEW_CONTAINER_MATERIAL`), drainage (`FIELD_NEW_CONTAINER_DRAINAGE`), and a
     `CONTAINER_CREATE_BUTTON` ("Create container") that calls `onCreateContainer(name.ifBlank
     { null }, volume, material.trim(), drainage.trim())` when volume parses > 0 and
     material/drainage are non-blank.
   - Track `selectedContainer: Container?`. **Validation moves to the selection:** on submit, if
     `selectedContainer == null` set `containerError = true` and do not submit; else submit with
     `containerId = selectedContainer.id`. Keep the `CONTAINER_ERROR` text node. Auto-select the
     newest created container with `LaunchedEffect(containers) { if (selectedContainer == null)
     containers.lastOrNull()?.let { selectedContainer = it } }`.
3. **`InventoryViewModels.kt`** — `AddPlantViewModel`: add `_containers` /
   `val containers: StateFlow<List<Container>>`, load it in `init` (alongside profiles +
   gardenSpaces: `_containers.value = repository.getContainers()`), and add
   `fun createContainer(name: String?, volumeLiters: Double, material: String, drainage: String)`
   that calls `repository.createContainer(...)`, appends the result to `_containers`, and routes
   errors to `_error` (mirror `createGardenSpace`). (import `dev.plantapp.domain.model.Container`.)
4. **`:app` `MainActivity.kt`** — `Routes.ADD`: `val containers by vm.containers.collectAsState()`
   and pass `containers = containers, onCreateContainer = vm::createContainer`. No other change.

### Tests — `InventoryScreensTest.kt`
- Add a `containers` fixture, e.g. `listOf(Container("00000000-0000-4000-8000-000000000002","Blue
  barrel",19.0,"plastic","good"), Container("…0005","Terracotta",8.0,"terracotta","good"))`.
- **Update `#22`**: pass `containers = containers, onCreateContainer = { _,_,_,_ -> }`; select the
  profile + garden space (as now) + open `FIELD_CONTAINER_SELECTOR` and pick "Blue barrel"; fill
  growth; submit; assert `submitted?.containerId == "00000000-0000-4000-8000-000000000002"`.
- **Update `#24`** (no container): render with **empty** `containers = emptyList()` (so nothing is
  auto-selected), select profile + garden space, fill growth, click submit; assert
  `CONTAINER_ERROR` is displayed and nothing submitted (`submitted` stays null).
- **Add** `container selector lists existing containers`: open the selector, assert "Blue barrel"
  and "Terracotta" listed (use `onAllNodesWithText(...).onFirst()` if the auto-selected name also
  appears in the anchor, matching the garden-space test).
- **Add** `container create path invokes callback`: open selector → `CONTAINER_CREATE_ITEM` →
  enter name/volume/material/drainage → `CONTAINER_CREATE_BUTTON`; assert the spy received
  `(name, volume, material, drainage)`.

### Forbidden
- No change to `:network`, `:data`, `:domain`, backend, `shared-schemas`, `supabase`. No new
  dependency. No camera/photos/GPS/notifications/AI. Don't mount/repoint the SDK/Drive; don't
  commit `android/local.properties`. `AddPlantForm` unchanged (still submits `containerId`).

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Red→green: before, the updated tests reference the container selector that doesn't exist; after,
`:feature-inventory` Robolectric tests pass (updated `#22`/`#24` + the two new container tests
green; profile/garden-space tests + `#21`/`#23` still green) and `:app:assembleDebug` compiles.
Report counts + new test names + assemble result.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/feature-inventory/ android/app/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-inventory): container select-or-create for add-plant"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The selector + inline create (tags), the validation moved onto selection, the VM `containers`
   load + `createContainer`, and the `MainActivity` wiring.
2. `:feature-inventory:testDebugUnitTest` (count before→after, updated/added tests green) +
   `:app:assembleDebug` result.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/feature-inventory/**` + `android/app/**` changed (not `local.properties`).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `feature-inventory/**`+`app/**`; container selector + create + wiring;
validation off selection; tests green; assemble OK). **3b (Android selectors) is then COMPLETE** —
the add-plant form is fully selector-driven with no raw-id fields. Then **3c**: a Supabase
magic-link **sign-in** screen writing the token to DataStore (replacing the current
manual-token-in-DataStore assumption) — likely `:feature-inventory` or a small `:feature-auth`
surface + `:data` SettingsStore token write; planner will ground it against the existing
`SettingsStore`/`PlantAppApiFactory` auth interceptor first. Then 3d (advisory→accept→CareTask,
routed through the engine — has a backend endpoint half + an Android action). Then (2) emulator
e2e smoke; then (4) Slice 3 (WorkManager local first; STOP for owner Firebase/FCM setup).
Vision-check each product-surface step.
