# Implementation prompt 0066 — searchable species picker with category chips (W2 UI)

You are the implementation Claude for PlantApp. Apply exactly ONE logical change:
turn the add-plant wizard's species step into a beginner-first picker — pinned
search field + category chips — so 75 catalog species stay browsable. Garden
Hearth spec (planner `reviews/redesign-directions-wave2.md` §Species Picker):
search field 60dp w/ leading icon + placeholder "Search tomato, basil, mint…";
chips 40dp / 12dp radius / selected `primaryContainer`; rows common-name-first.

Note on the spec's chip list: the Codex direction sketched aspirational chips
(Easy/Shade/Sunny) that need difficulty data we don't have. Per the planner's
data-honesty call, chips are the REAL catalog categories with friendly labels
(Gate B/PD-14: "Houseplants" included). Easy/Sunny/Shade may come later with a
difficulty field.

## 1. Scope — one logical change

1. **`addplant/WizardModel.kt`** — pure `filterProfiles(profiles, query, category)`
   (JVM-testable, red-first) + `CATEGORY_ORDER`.
2. **`DisplayText.kt`** — `categoryLabel(category)` plain-language labels.
3. **`addplant/AddPlantWizard.kt`** — step 1 gains the search field + chip row;
   tiles render from `filterProfiles(...)`.
4. **`InventoryTestTags.kt`** — ADD two new constants (no renames, no removals):
   `WIZARD_SPECIES_SEARCH` and `WIZARD_CATEGORY_CHIP_PREFIX`.
5. Tests: `AddPlantWizardTest` (red-first UI), `AddPlantWizardModelTest` +
   `DisplayTextTest` (pure logic).

## 2. Forbidden changes — do NOT touch

- Wizard steps 2–4 (location/pot/confirm) and their tiles/tags.
- `WizardIcons.kt` (species icons stay as-is — most of the 75 hit the existing
  fallback until the icon slice (PD-15) lands; that is expected).
- The wizard's Column/verticalScroll structure (no LazyColumn refactor here —
  75 simple tiles compose acceptably; filtering shrinks the visible set).
- Existing test tags (rename/removal forbidden; additions per §1 only).
- `PlantListScreen`, `PlantDetailScreen`, `SignInScreen`, MainActivity, backend,
  schemas, migrations, design-system. No new dependencies.
- Do NOT `git add` untracked `android/.kotlin/`.

## 3. Exact files to touch

1. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/WizardModel.kt`
2. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/DisplayText.kt`
3. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/AddPlantWizard.kt`
4. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryTestTags.kt`
5. `android/feature-inventory/src/test/kotlin/dev/plantapp/feature/inventory/AddPlantWizardTest.kt`
6. `android/feature-inventory/src/test/kotlin/dev/plantapp/feature/inventory/AddPlantWizardModelTest.kt`
7. `android/feature-inventory/src/test/kotlin/dev/plantapp/feature/inventory/DisplayTextTest.kt`

## 4. Baseline precondition — STOP if it doesn't hold

```bash
git -C /home/israel/Documents/Development/PlantApp rev-parse HEAD   # must be <SHA-AFTER-0065> — FILL BEFORE PUBLISHING
git -C /home/israel/Documents/Development/PlantApp status --short   # clean (untracked android/.kotlin/ OK)
git -C /home/israel/Documents/Development/PlantApp branch --show-current  # master
```
Differs → **STOP, BLOCKED report.**

## 5. Exact changes

### 5a. `WizardModel.kt`

Add `import dev.plantapp.domain.model.PlantProfile` and, inside
`AddPlantWizardModel`:

```kotlin
    /** Friendly browse order for the species-picker category chips. Only categories that are
     *  actually present in the loaded catalog get a chip. */
    val CATEGORY_ORDER: List<String> = listOf(
        "houseplant", "herb", "vegetable", "fruit", "berry",
        "ornamental", "succulent", "root", "vine", "other",
    )

    /** Pure picker filter: case-insensitive substring match on any common name or the
     *  scientific name; optional category; result sorted by display name. */
    fun filterProfiles(
        profiles: List<PlantProfile>,
        query: String,
        category: String?,
    ): List<PlantProfile> {
        val q = query.trim()
        return profiles
            .filter { category == null || it.category == category }
            .filter {
                q.isEmpty() ||
                    it.commonNames.any { n -> n.contains(q, ignoreCase = true) } ||
                    it.scientificName.contains(q, ignoreCase = true)
            }
            .sortedBy { (it.commonNames.firstOrNull() ?: it.scientificName).lowercase() }
    }
```

### 5b. `DisplayText.kt` — add inside the object

```kotlin
    /** Catalog category -> beginner browse label ("ornamental" -> "Flowers"). */
    fun categoryLabel(category: String): String = when (category) {
        "houseplant" -> "Houseplants"
        "herb" -> "Herbs"
        "vegetable" -> "Vegetables"
        "fruit" -> "Fruit"
        "berry" -> "Berries"
        "ornamental" -> "Flowers"
        "succulent" -> "Succulents"
        "root" -> "Root vegetables"
        "vine" -> "Climbers"
        "other" -> "More"
        else -> category.replace('-', ' ').replaceFirstChar { it.uppercase() }
    }
```

### 5c. `InventoryTestTags.kt` — append two constants

```kotlin
    const val WIZARD_SPECIES_SEARCH = "wizard_species_search"
    const val WIZARD_CATEGORY_CHIP_PREFIX = "wizard_category_chip_"
```

### 5d. `AddPlantWizard.kt` — step 1 picker

Inside the composable, add picker state next to the existing wizard state:
```kotlin
    var speciesQuery by remember { mutableStateOf("") }
    var speciesCategory by remember { mutableStateOf<String?>(null) }
```

Replace the step-1 branch (currently `1 -> profiles.forEach { profile -> … }`)
with:
```kotlin
                1 -> {
                    OutlinedTextField(
                        value = speciesQuery,
                        onValueChange = { speciesQuery = it },
                        singleLine = true,
                        leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null) },
                        placeholder = { Text("Search tomato, basil, mint…") },
                        modifier = Modifier
                            .fillMaxWidth()
                            .heightIn(min = 60.dp)
                            .testTag(InventoryTestTags.WIZARD_SPECIES_SEARCH),
                    )
                    val presentCategories = AddPlantWizardModel.CATEGORY_ORDER
                        .filter { c -> profiles.any { it.category == c } }
                    if (presentCategories.size > 1) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .horizontalScroll(rememberScrollState()),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                        ) {
                            presentCategories.forEach { c ->
                                FilterChip(
                                    selected = speciesCategory == c,
                                    onClick = {
                                        speciesCategory = if (speciesCategory == c) null else c
                                    },
                                    label = { Text(DisplayText.categoryLabel(c)) },
                                    shape = RoundedCornerShape(12.dp),
                                    modifier = Modifier
                                        .height(40.dp)
                                        .testTag(InventoryTestTags.WIZARD_CATEGORY_CHIP_PREFIX + c),
                                )
                            }
                        }
                    }
                    AddPlantWizardModel.filterProfiles(profiles, speciesQuery, speciesCategory)
                        .forEach { profile ->
                            Tile(
                                label = speciesName(profile),
                                tag = InventoryTestTags.WIZARD_SPECIES_TILE_PREFIX + profile.id,
                                leadingIcon = {
                                    Image(
                                        painter = painterResource(WizardIcons.speciesIconRes(profile.id)),
                                        contentDescription = null,
                                        modifier = Modifier.size(48.dp),
                                    )
                                },
                            ) {
                                selectedProfile = profile
                                step = 2
                            }
                        }
                }
```
New imports needed: `androidx.compose.foundation.horizontalScroll`,
`androidx.compose.foundation.layout.Row`, `androidx.compose.foundation.layout.heightIn`,
`androidx.compose.foundation.layout.height`, `androidx.compose.foundation.shape.RoundedCornerShape`,
`androidx.compose.material.icons.Icons`, `androidx.compose.material.icons.filled.Search`,
`androidx.compose.material3.FilterChip`, `androidx.compose.material3.Icon`,
`androidx.compose.material3.OutlinedTextField`, plus `DisplayText` if not imported
(same package — not needed). Keep selected-chip default colors (M3 FilterChip
selected container is the Hearth `secondaryContainer`-family; do NOT hand-tint).

FilterChip default selected color note: the Hearth spec asks `primaryContainer` —
use `FilterChipDefaults.filterChipColors(selectedContainerColor =
MaterialTheme.colorScheme.primaryContainer)` to honor it (one extra import).

### 5e. Tests

**RED-FIRST (step 1 of §7) — add to `AddPlantWizardTest.kt`** (uses a raw tag
string so it compiles against the CURRENT code; the constant arrives in 5c):

```kotlin
    @Test
    fun `species step filters tiles by search text`() {
        composeRule.setContent {
            AddPlantWizard(
                profiles = listOf(
                    fakeProfile(id = "solanum-lycopersicum", common = "Tomato"),
                    fakeProfile(id = "ocimum-basilicum", common = "Basil"),
                ),
                /* …match the file's existing wizard invocation pattern for the
                   remaining parameters (gardenSpaces/containers/callbacks)… */
            )
        }
        composeRule.onNodeWithTag("wizard_species_search").performTextInput("toma")
        composeRule.onNodeWithTag(InventoryTestTags.WIZARD_SPECIES_TILE_PREFIX + "solanum-lycopersicum").assertIsDisplayed()
        composeRule.onNodeWithTag(InventoryTestTags.WIZARD_SPECIES_TILE_PREFIX + "ocimum-basilicum").assertDoesNotExist()
    }
```
Adapt `fakeProfile(...)` to however `AddPlantWizardTest` currently builds
`PlantProfile` fixtures (reuse its existing helper/fixtures — ground your edit in
the file's current content; do NOT invent a new fixture style).

**Step 3 (post-implementation) — pure tests:**
- `AddPlantWizardModelTest`: `filterProfiles` — (a) blank query + null category
  returns all sorted by display name; (b) query "toma" matches Tomato by common
  name case-insensitively; (c) query matches scientificName; (d) category filter
  keeps only that category; (e) query+category compose.
- `DisplayTextTest`: `categoryLabel("houseplant") == "Houseplants"`,
  `categoryLabel("ornamental") == "Flowers"`, unknown value falls back to
  de-slugged capitalization.
- `AddPlantWizardTest`: one more UI test — tapping the Houseplants chip hides
  non-houseplant tiles (build 2 fake profiles with different categories; tap
  `WIZARD_CATEGORY_CHIP_PREFIX + "houseplant"`; assert).

## 6. Expected failure modes (not regressions)

- §7 step 1: the new UI test fails with "no node with tag wizard_species_search"
  (or assertion equivalent) — expected red.
- Existing `AddPlantWizardTest` flows that walk step 1 by tapping a species tile
  keep working (tiles still render, unfiltered by default). If any existing
  wizard test fails after implementation, that IS a regression — fix the
  implementation, not the test, unless the test hard-codes tile ORDER (the new
  sort orders by display name); if an order-pin exists, report it and align the
  test with a provenance comment (0050/0064 precedent).
- Gradle deprecation warnings: pre-existing, ignore.

## 7. Standalone verification (red → green, objective)

From `/home/israel/Documents/Development/PlantApp/android`,
`GRADLE_USER_HOME=/tmp/plantapp-gradle-home`.

**Step 1 — RED:** add ONLY the §5e red test, then:
```bash
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest --tests "dev.plantapp.feature.inventory.AddPlantWizardTest"
```
Expected: exactly the new test fails (missing search node). Passing → STOP, BLOCKED.

**Step 2 — implement** §5a–§5d. **Step 3 — add the remaining tests** (§5e).

**Step 4 — GREEN:**
```bash
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Full `:feature-inventory` suite green (report the actual count — expect roughly
39 + 9 new) and the app assembles.

## 8. Commit title (Conventional Commits, exact)

```
feat(wizard): searchable species picker with category chips for the 75-plant catalog
```

## 9. Push requirement

`git push origin master` — fast-forward expected. Confirm new `origin/master`.

## 10. Final report requirements

Report to `exchange/implementation-inbox/0066-species-picker/` via the report
script. Include: scope confirmation (7 files) + `git show --stat HEAD`; RED
evidence; GREEN totals + assembleDebug; the final step-1 code block (search +
chips) for planner review; commit hash + push confirmation; deviations (or "none").
