# Next Implementation Prompt — beginner add-plant wizard, H2: the `AddPlantWizard` screen (custom icons, no emoji)

**Beginner-first UX overhaul, add-plant wizard part 2 of 2 — the screen.** Replace the jargon
`AddPlantScreen` with a **3-step, icon-led wizard** a total novice / elderly user can complete:
*What are you growing? → Where will it live? → What's it planted in?* → confirm. Big tappable
tiles, plain language, **no litres / material / drainage / growth-stage / ISO ever shown**; the
engine gets the technical values from the friendly choices (via the `0041` model). **Icons are
custom per-species vector drawables — NO EMOJI** (owner decision); the emoji `categoryIcon` from
`0041` is removed. Spec: `PlantAppPlanner/reviews/beginner-ux-addplant-spec.md`.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`12f0dbb...` (the `0041` commit) == `origin/master`, clean. `:feature-inventory` has:
`addplant/WizardModel.kt` (`AddPlantWizardModel.POT_SIZES` [label+volumeLiters], `LOCATION_PRESETS`
[label+kind], `DEFAULT_MATERIAL/DRAINAGE/GROWTH_STAGE`, **and an emoji `categoryIcon` to remove**);
the stateless `AddPlantScreen(profiles, gardenSpaces, containers, onCreateGardenSpace,
onCreateContainer, onSubmit, onCancel)` + `AddPlantViewModel` (loads `profiles`/`gardenSpaces`/
`containers`; `createGardenSpace`/`createContainer` append + the screen auto-selects newest;
`submit(form){onSaved}`); `:app` `MainActivity` `Routes.ADD` wires the VM → `AddPlantScreen`.
Catalog: 5 species — `solanum-lycopersicum` (Tomato), `ocimum-basilicum` (Basil),
`fragaria-x-ananassa` (Strawberry), `passiflora-edulis` (Passion fruit), `physalis-philadelphica`
(Tomatillo). Tests are Robolectric (`@Config(sdk=[34])`) driving stateless screens with fixtures.

Single logical change (the add-plant wizard screen + its icons, replacing the old form) → one commit.
Red→green.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Build the
beginner add-plant wizard with custom (non-emoji) icons, replacing `AddPlantScreen`. **Consult the
Compose docs** (state, `Image`/`Icon` with vector drawables). Red-first: write the screen test first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect the 0041 commit == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **Custom vector icons** in `android/feature-inventory/src/main/res/drawable/` — **original,
   simple, flat/line-style** `<vector>` drawables (you author them; no emoji, no copied/licensed
   art — keep them simple geometric/recognizable so there's no licensing concern):
   - **Per species** (distinct + recognizable at tile size): `ic_species_tomato.xml`,
     `ic_species_basil.xml`, `ic_species_strawberry.xml`, `ic_species_passionfruit.xml`,
     `ic_species_tomatillo.xml`, + `ic_species_default.xml` (generic plant/sprout fallback).
   - **Locations**: `ic_loc_windowsill.xml`, `ic_loc_balcony.xml`, `ic_loc_backyard.xml`,
     `ic_loc_indoors.xml`.
   - **Pot**: `ic_pot.xml` (one generic pot is fine — the size label distinguishes the choices).
   Use a single accent `android:tint`/fill; ~24–48dp viewport; no raster/PNG.
2. **Icon mapping** — a new Android file `android/feature-inventory/.../addplant/WizardIcons.kt`:
   `@DrawableRes fun speciesIconRes(profileId: String): Int` (map the 5 ids → their drawable,
   else `ic_species_default`); `@DrawableRes fun locationIconRes(kind: String): Int`;
   `@DrawableRes fun potIconRes(): Int`. (Kept separate from the pure `WizardModel` because it
   references `R.drawable`.)
3. **Remove the emoji `categoryIcon`** from `WizardModel.kt` and its assertions from
   `AddPlantWizardModelTest.kt` (emoji is rejected; icons now come from `WizardIcons`).
4. **`addplant/AddPlantWizard.kt`** (new) — a **stateless** composable (hoisted data + callbacks,
   internal step state), replacing `AddPlantScreen`'s role:
   ```kotlin
   @Composable fun AddPlantWizard(
       profiles: List<PlantProfile>,
       gardenSpaces: List<GardenSpace>,
       containers: List<Container>,
       onCreateGardenSpace: (name: String, kind: String) -> Unit,
       onCreateContainer: (name: String?, volumeLiters: Double, material: String, drainage: String) -> Unit,
       onSubmit: (AddPlantForm) -> Unit,
       onCancel: () -> Unit = {},
       modifier: Modifier = Modifier,
   )
   ```
   - Internal `var step by remember { mutableStateOf(1) }` (1→2→3→confirm), a title per step, a
     Back affordance, big tiles (icon from `WizardIcons` + plain name, large tap target).
   - **Step 1 "What are you growing?":** a tile per `profiles` entry — `speciesIconRes(profile.id)`
     + `commonNames.firstOrNull() ?: scientificName`; tap selects + advances. No scientific names as
     the primary label.
   - **Step 2 "Where will it live?":** tiles for `AddPlantWizardModel.LOCATION_PRESETS` (icon via
     `locationIconRes(kind)` + label). Tapping a preset calls `onCreateGardenSpace(label, kind)` and
     advances (the VM appends + this screen uses the newest gardenSpace as the selection — mirror
     the existing auto-select-newest pattern). (Existing spaces may also be shown as tiles.)
   - **Step 3 "What's it planted in?":** tiles for `AddPlantWizardModel.POT_SIZES` (icon
     `potIconRes()` + the size label, e.g. "5-gallon bucket"). Tapping calls
     `onCreateContainer(name = "<selected species> – <size label>", volumeLiters = option.volumeLiters,
     material = DEFAULT_MATERIAL, drainage = DEFAULT_DRAINAGE)` and advances. **No litres shown.**
   - **Confirm:** plain summary ("Add your {Tomato} to the {Balcony}?") + a big **Add** button that
     calls `onSubmit(AddPlantForm(profileId = selectedProfile.id, containerId = <newest container id>,
     gardenSpaceId = <newest garden space id>, growthStage = DEFAULT_GROWTH_STAGE, lastWateredAt = null))`.
   - Add test tags (in `InventoryTestTags`): `WIZARD_SPECIES_TILE_PREFIX = "wizard_species_"`,
     `WIZARD_LOCATION_TILE_PREFIX = "wizard_location_"`, `WIZARD_POT_TILE_PREFIX = "wizard_pot_"`,
     `WIZARD_ADD_BUTTON = "wizard_add_button"` (use stable suffixes — profileId / kind / label-slug).
   - **Delete `AddPlantScreen.kt`** (replaced) — or keep it unused? **Replace it** (remove the file
     + its now-stale tests in `InventoryScreensTest` #22/#24 that drove the old fields).
5. **`:app` `MainActivity.kt`** — `Routes.ADD` now hosts `AddPlantWizard` (same VM; pass `profiles`/
   `gardenSpaces`/`containers` + `vm::createGardenSpace`/`vm::createContainer` + the submit→navigate
   wiring). No other route change.

### Correctness requirements — wizard create/select plumbing (READ FIRST)
`AddPlantViewModel.createGardenSpace`/`createContainer` are **async** (they `viewModelScope.launch`
the network call and *then* append to the StateFlow) — so the new row is **not** in
`gardenSpaces`/`containers` on the very next recomposition. Therefore:
1. **Reuse, don't duplicate.** On a Step-2/Step-3 tap, first check whether a matching entry already
   exists (garden space by `name`+`kind`; container by the `name` the wizard would use) — if so,
   **select it and advance, do NOT call `onCreate…`**. Only call `onCreateGardenSpace`/
   `onCreateContainer` when none matches. This prevents orphan spaces/containers when the user taps
   **Back** and re-picks.
2. **Select by identity, not "last".** Track the name/kind you created and resolve the selected id by
   **matching that identity** in the (re-supplied) list via a `LaunchedEffect(gardenSpaces)` /
   `LaunchedEffect(containers)` — never assume `list.last()`. The **Add** button must be disabled
   until both the created space id and container id have resolved (so `onSubmit` never fires with a
   blank/stale id).
3. First **read** `AddPlantViewModel` to confirm the above; if the create path differs from this
   (e.g. it exposes the created id directly), prefer that — and **STOP and report** if the wiring
   can't yield the new ids deterministically.

### Forbidden
- **No emoji anywhere** — do NOT copy the spec's emoji glyphs (🪟/🏞️/🌱/…) into code or copy text;
  all icons come from `WizardIcons`, success/summary copy is plain text. No raster images (vectors only). No `:network`/`:data`/`:domain`/backend/
  schema change (reuse existing repo/VM methods). No new dependency unless strictly needed for vector
  drawables (they're built-in — none should be required). No litres/material/drainage/growth-stage/ISO
  surfaced in the UI. No camera/photos/GPS/AI. Don't mount/repoint the SDK/Drive; don't commit
  `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Red→green: the new `AddPlantWizardTest` fails before the wizard exists; after, `:feature-inventory`
tests pass and `:app:assembleDebug` compiles (route wiring). **New test `AddPlantWizardTest`**
(Robolectric): render `AddPlantWizard` with 5 fixture profiles + spy callbacks; assert step-1 shows
a species tile per profile; walk Tomato → a location tile (assert `onCreateGardenSpace` called) →
a pot tile e.g. "5-gallon bucket" (assert `onCreateContainer` called with volumeLiters 19.0) →
**Add** → assert `onSubmit` got `profileId = "solanum-lycopersicum"`, `growthStage = "seedling"`,
`lastWateredAt == null`, and a non-blank `containerId`/`gardenSpaceId` resolved from the re-supplied
lists. **Add a Back-then-reselect test:** pick a location, go Back, pick the same location again →
assert `onCreateGardenSpace` is **not** called a second time (reuse, no duplicate). Report counts +
new test name + assemble result. (Final icon look is the
owner's on-device call.)

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/feature-inventory/ android/app/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-inventory): beginner add-plant wizard (3-step, custom icons) replacing the jargon form"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The 3-step wizard (tags + what each step shows), the custom vector drawables added (list them),
   the `WizardIcons` mapping, removal of the emoji `categoryIcon`, and the `MainActivity` wiring.
2. `:feature-inventory:testDebugUnitTest` (count before→after; new wizard test green; old
   AddPlantScreen tests removed/updated) + `:app:assembleDebug` result.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/feature-inventory/**` + `android/app/**` changed; confirm **no emoji** in the changes.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `feature-inventory`+`app`; wizard replaces the form; custom vector icons,
no emoji; tests green; assemble OK). **Then a device review:** rebuild the LAN-debug APK + reinstall
so the owner can eyeball the wizard + icons on the phone (offer to re-stand-up the backend for a
full run). Then the **copy sweep** (friendly sign-in/list/detail + advisory wording). Icon
refinement (nicer per-species art) is an easy follow-up after the owner sees them. Vision-check each.
