# Implementation report — 0066-species-picker

## Status: DONE

## 1. Scope confirmation + git show --stat HEAD
Exactly the 7 listed files:
```
 .../dev/plantapp/feature/inventory/DisplayText.kt  | 15 ++++
 .../feature/inventory/InventoryTestTags.kt         |  2 +
 .../feature/inventory/addplant/AddPlantWizard.kt   | 83 ++++++++++++++++++----
 .../feature/inventory/addplant/WizardModel.kt      | 27 +++++++
 .../feature/inventory/AddPlantWizardModelTest.kt   | 39 ++++++++++
 .../feature/inventory/AddPlantWizardTest.kt        | 39 ++++++++++
 .../plantapp/feature/inventory/DisplayTextTest.kt  | 11 +++
 7 files changed, 202 insertions(+), 14 deletions(-)
```
- `WizardModel.kt` — `CATEGORY_ORDER` + pure `filterProfiles(profiles, query, category)`
  (verbatim §5a; `PlantProfile` import added).
- `DisplayText.kt` — `categoryLabel` (verbatim §5b; real catalog categories only, per the
  data-honesty note — no Easy/Sunny/Shade).
- `InventoryTestTags.kt` — the two new constants appended; no renames/removals.
- `AddPlantWizard.kt` — step-1 picker per §5d (60dp search field with leading Search icon +
  the spec placeholder; chip row only when >1 category present, 40dp/12dp-radius FilterChips
  with `selectedContainerColor = primaryContainer`, toggling chip deselects; tiles render
  from `filterProfiles(...)`). Steps 2–4, tiles/tags, Column/verticalScroll structure, and
  `WizardIcons` untouched. All prescribed imports added incl. the cross-package
  `dev.plantapp.feature.inventory.DisplayText`.
- Tests — red-first search UI test + chip UI test (`AddPlantWizardTest`, reusing the existing
  class-level positional-style fixture and adding `performTextInput` import); 5 pure
  `filterProfiles` tests (blank/sorted, common-name case-insensitive, scientific-name,
  category-only, query+category compose); 2 `categoryLabel` tests (friendly labels +
  de-slugged fallback).

## 2. RED evidence (§7 step 1 — search test only, raw tag string)
```
AddPlantWizardTest > species step filters tiles by search text FAILED
    java.lang.AssertionError at AddPlantWizardTest.kt:126
5 tests completed, 1 failed
```
JUnit XML: `Failed to perform text input. Reason: Expected exactly '1' node but could not
find any node that satisfies: (TestTag = 'wizard_species_search')` — exactly the predicted
missing-search-node red; no other failure.

## 3. GREEN
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 10s
143 actionable tasks: 15 executed, 128 up-to-date
```
JUnit XML aggregate: **feature-inventory: tests=48 failures+errors=0** (39 from 0059 + 9 new:
2 UI + 5 model + 2 DisplayText). All pre-existing wizard flows (walk-through, dedupe, error
card, confirm copy) still pass — no tile-order pins existed. `:app:assembleDebug`
BUILD SUCCESSFUL in the same invocation.

## 4. Final step-1 code block (for planner review)
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
                                    colors = FilterChipDefaults.filterChipColors(
                                        selectedContainerColor = MaterialTheme.colorScheme.primaryContainer,
                                    ),
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

## 5. Commit + push
- New commit: `3243ae7fd756985a6a9ac45e9e5c2de4b5c22aac`
- Title (exact): `feat(wizard): searchable species picker with category chips for the 75-plant catalog`
- Pushed: `59288c6..3243ae7  master -> master`; new `origin/master` =
  `3243ae7fd756985a6a9ac45e9e5c2de4b5c22aac`.

## 6. Deviations
None.
