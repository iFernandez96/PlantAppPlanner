# Next Implementation Prompt — backlog (3b-ui-a): add-plant **profile dropdown** selector

**Backlog item (3) UX follow-ups, step 3b — part 3 of 3 (UI), sub-step a of b.** Replace the raw
**Profile id** text field on the add-plant form with a **dropdown** populated from the catalog
(`getPlantProfiles()`, landed `0022`). This is the first selector; the garden-space/container
**select-or-create** selectors are the next handoff (3b-ui-b). Garden-space id, container id,
growth stage, and last-watered stay exactly as they are in this step.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`3fba7184c52e87861dc222d4c42ecd11b9d36003` == `origin/master`, clean. The add-plant form
(`feature-inventory/.../AddPlantScreen.kt`) is a **stateless** composable taking `onSubmit:
(AddPlantForm) -> Unit`; it currently has five `OutlinedTextField`s incl. `FIELD_PROFILE_ID`.
`AddPlantViewModel` (`InventoryViewModels.kt`) only `submit()`s — it does **not** load profiles.
The screen is hosted by `:app` `MainActivity.kt` (`Routes.ADD` composable). `:domain` has
`PlantProfile(id, scientificName, commonNames, category)` + `InventoryRepository.getPlantProfiles()`.
UI tests are Robolectric (`InventoryScreensTest.kt`, `@Config(sdk=[34])`), driving the stateless
screens directly with fixture state + callback spies.

Single logical change (the profile dropdown selector + its VM load + route wiring) → one commit.
Red→green (the existing `#22`/`#24` tests, which type into `FIELD_PROFILE_ID`, must be updated to
the dropdown — that is the red-first driver).

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Replace the
add-plant profile **id text field** with a profile **dropdown**. Drive begins red (the two
existing tests reference `FIELD_PROFILE_ID`). **Consult the Material3 `ExposedDropdownMenuBox`
docs** for the dropdown.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect 3fba7184c52e87861dc222d4c42ecd11b9d36003 == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`feature-inventory/.../InventoryTestTags.kt`** — add `FIELD_PROFILE_SELECTOR =
   "field_profile_selector"` (the dropdown anchor). You may add a menu-item tag if helpful;
   keep `FIELD_PROFILE_ID` removed or unused. Leave the other tags untouched.
2. **`feature-inventory/.../AddPlantScreen.kt`** — add a parameter
   `profiles: List<dev.plantapp.domain.model.PlantProfile>` (place it before `modifier`).
   Replace the `Field("Profile id", …, FIELD_PROFILE_ID)` with a Material3
   `ExposedDropdownMenuBox`:
   - The anchor is a read-only `OutlinedTextField` tagged `FIELD_PROFILE_SELECTOR`, showing the
     selected profile's label (display label = `commonNames.firstOrNull() ?: scientificName`,
     optionally with the scientific name as supporting text). Placeholder e.g. "Select a profile".
   - The menu lists every `profiles` entry by its display label; selecting one stores that
     profile's **`id`** as the submitted `profileId`.
   - Keep the container/garden-space/growth-stage/last-watered fields and the container-required
     validation exactly as-is. `AddPlantForm` is unchanged (still submits `profileId`).
3. **`feature-inventory/.../InventoryViewModels.kt`** — `AddPlantViewModel`: load the catalog so
   the route can supply it. Add `private val _profiles = MutableStateFlow<List<PlantProfile>>(
   emptyList())` + `val profiles: StateFlow<List<PlantProfile>> = _profiles.asStateFlow()` and an
   `init { viewModelScope.launch { try { _profiles.value = repository.getPlantProfiles() } catch
   (e: Exception) { _error.value = e.message ?: "Could not load profiles" } } }`. Keep `submit()`
   as-is. (import `dev.plantapp.domain.model.PlantProfile`.)
4. **`:app` `MainActivity.kt`** — in the `Routes.ADD` composable, collect the profiles and pass
   them: `val profiles by vm.profiles.collectAsState()` then `AddPlantScreen(profiles = profiles,
   onSubmit = …, onCancel = …)`. No other route/file change.

### Tests — `feature-inventory/src/test/.../InventoryScreensTest.kt`
- Add a `profiles` fixture, e.g. `listOf(PlantProfile("solanum-lycopersicum","Solanum
  lycopersicum",listOf("Tomato"),"fruit"), PlantProfile("ocimum-basilicum","Ocimum
  basilicum",listOf("Basil"),"herb"))`.
- **Update `#22`**: render `AddPlantScreen(profiles = profiles, onSubmit = { submitted = it })`;
  open the dropdown (`onNodeWithTag(FIELD_PROFILE_SELECTOR).performClick()`), select the
  "Tomato" item (`onNodeWithText("Tomato").performClick()`), fill container/garden-space/growth
  via their existing tags, submit, assert `submitted?.profileId == "solanum-lycopersicum"`.
- **Update `#24`**: same dropdown selection path; assert the container-required error still shows
  and nothing submits.
- **Add `#new` `add-plant profile dropdown lists catalog profiles`**: render with `profiles`,
  open the dropdown, assert both "Tomato" and "Basil" are displayed.

### Forbidden
- No change to `:network`, `:data`, `:domain`, backend, `shared-schemas`, or `supabase`. No new
  dependency (Material3/Compose already present). Do not touch the garden-space/container/growth
  fields' behavior in this step (that's 3b-ui-b). No camera/photos/GPS/notifications/AI. Don't
  mount/repoint the SDK/Drive; don't commit `android/local.properties`. `AddPlantForm` unchanged.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Red→green: before the change the updated tests reference the dropdown that doesn't exist; after,
`:feature-inventory` Robolectric tests pass (updated `#22`/`#24` + the new dropdown test green,
`#21`/`#23` still green) and `:app:assembleDebug` compiles (the route wiring type-checks). Report
the test count + the new test name + assemble result. (Note: `:domain` is a JVM module — its task
is `:domain:test`, not needed here.)

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/feature-inventory/ android/app/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-inventory): profile dropdown selector for add-plant"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The dropdown (anchor tag, label rule, how selection maps to `profileId`), the VM profiles
   load, and the `MainActivity` wiring.
2. `:feature-inventory:testDebugUnitTest` (count before→after, updated `#22`/`#24` + new test
   green) and `:app:assembleDebug` result.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/feature-inventory/**` + `android/app/**` changed (not `local.properties`).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `feature-inventory/**`+`app/**`; dropdown + VM load + route wiring;
tests green; assemble OK). Then **3b-ui-b**: garden-space + container **select-or-create**
selectors (dropdowns from `getGardenSpaces()`/`getContainers()` + inline create via the existing
`createGardenSpace`/`createContainer` repo methods) replacing those two id fields, + tests. Then
3c (magic-link sign-in → DataStore token), 3d (advisory→accept→CareTask). Then (2) emulator e2e
smoke; then (4) Slice 3 (WorkManager local first; STOP for owner Firebase/FCM setup). Vision-check
each product-surface step.
