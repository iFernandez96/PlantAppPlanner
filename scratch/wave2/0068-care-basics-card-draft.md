# Implementation prompt 0068 — "Care basics" card on plant detail (W2 detail enrichment, part 2/2)

You are the implementation Claude for PlantApp. Apply exactly ONE logical change:
show the catalog care basics (carried into `PlantProfile` by 0067) on the plant
detail screen as a beginner-language "Care basics" card. Display-only — the
backend engine remains the sole scheduler (D-09).

## 1. Scope — one logical change

1. **`InventoryUiState.kt`** — `PlantDetailUiState.Content` gains
   `val profile: PlantProfile? = null` (defaulted; the 5 existing named-arg
   constructions in tests keep compiling).
2. **`InventoryViewModels.kt`** — `PlantDetailViewModel.loadFor` keeps the whole
   matched profile (it already fetches it for the name).
3. **`DisplayText.kt`** — two pure copy helpers: `cadence(days: Double)` and
   `issuePreview(issue: String)`.
4. **`PlantDetailScreen.kt`** — `CareBasicsCard` AFTER the engine's task card
   (and before the advisories): the actionable "Next: … Due …" stays visually
   primary (D-09 — the engine is the authority); care basics read as background
   context below it.
5. **`InventoryTestTags.kt`** — ADD `const val CARE_BASICS_SECTION = "care_basics_section"`
   (no renames/removals).
6. Tests — red-first UI test + pure DisplayText tests.

## 2. Forbidden changes — do NOT touch

- The care-task card, advisories section, accept flow (engine surface — D-09).
- `:domain`, `:data`, `:network` (0067 already landed the data).
- Wizard, list, sign-in screens, MainActivity, backend, schemas, migrations,
  design-system. No new dependencies.
- Do NOT `git add` untracked `android/.kotlin/`.

## 3. Exact files to touch

1. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryUiState.kt`
2. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryViewModels.kt`
3. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/DisplayText.kt`
4. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/PlantDetailScreen.kt`
5. `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryTestTags.kt`
6. `android/feature-inventory/src/test/kotlin/dev/plantapp/feature/inventory/PlantDetailAdvisoriesTest.kt` (red-first UI test added here — it already builds detail Content states)
7. `android/feature-inventory/src/test/kotlin/dev/plantapp/feature/inventory/DisplayTextTest.kt`

## 4. Baseline precondition — STOP if it doesn't hold

```bash
git -C /home/israel/Documents/Development/PlantApp rev-parse HEAD   # must be 3a2f4c36b1483ebc6c21ed3b770fc7bf19f6e868
git -C /home/israel/Documents/Development/PlantApp status --short   # clean (untracked android/.kotlin/ OK)
git -C /home/israel/Documents/Development/PlantApp branch --show-current  # master
```
Also confirm 0067 landed: `grep -n "wateringIntervalDays" android/domain/src/main/kotlin/dev/plantapp/domain/model/InventoryModels.kt` → 1 hit.
Differs → **STOP, BLOCKED report.**

## 5. Exact changes

### 5a. `InventoryUiState.kt`

In `PlantDetailUiState.Content`, after `speciesName`:
```kotlin
        /** Full catalog profile for the care-basics card; null if the lookup failed. */
        val profile: PlantProfile? = null,
```
(Import `dev.plantapp.domain.model.PlantProfile` — the file already imports
sibling domain models.)

### 5b. `InventoryViewModels.kt` — `PlantDetailViewModel.loadFor`

Old (inside the Content build):
```kotlin
                    // Friendly name only; a profile-lookup failure must never fail the screen.
                    val speciesName = runCatching {
                        repository.getPlantProfiles()
                            .firstOrNull { it.id == plant.profileId }
                            ?.commonNames?.firstOrNull()
                    }.getOrNull()
                    PlantDetailUiState.Content(
                        plant = plant,
                        task = task,
                        advisories = advisories,
                        speciesName = speciesName,
                    )
```
New:
```kotlin
                    // Full profile (name + care basics); a lookup failure must never fail the screen.
                    val profile = runCatching {
                        repository.getPlantProfiles().firstOrNull { it.id == plant.profileId }
                    }.getOrNull()
                    PlantDetailUiState.Content(
                        plant = plant,
                        task = task,
                        advisories = advisories,
                        speciesName = profile?.commonNames?.firstOrNull(),
                        profile = profile,
                    )
```

### 5c. `DisplayText.kt` — two pure helpers (inside the object)

```kotlin
    /** Plain-language cadence for a day interval ("about every 3 days", "about once a week").
     *  Display copy only — never feeds scheduling (D-09). */
    fun cadence(days: Double): String {
        val n = kotlin.math.round(days).toInt()
        return when {
            days < 1.75 -> "every day or two"
            n < 7 -> "about every $n days"
            n <= 10 -> "about once a week"
            n <= 17 -> "about every 2 weeks"
            n <= 24 -> "about every 3 weeks"
            n <= 45 -> "about once a month"
            else -> "about every ${kotlin.math.round(n / 30.0).toInt()} months"
        }
    }

    /** First clause of a catalog common-issue entry (entries can be long, ';'-joined). */
    fun issuePreview(issue: String): String = issue.substringBefore(';').trim()
```

### 5d. `PlantDetailScreen.kt`

In the `Content` branch, AFTER the task line
(`if (state.task != null) CareTaskCard(state.task) else Text("No care task yet.")`)
and BEFORE the advisories line, add:
```kotlin
                    state.profile?.let { CareBasicsCard(it) }
```
(The engine's actionable task card stays on top; care basics are background
context below it.)

New private composable (place near `CareTaskCard`, same idioms):
```kotlin
@Composable
private fun CareBasicsCard(profile: PlantProfile) {
    val lines = buildList {
        profile.wateringIntervalDays?.let { add("Water " + DisplayText.cadence(it)) }
        profile.feedingIntervalDays?.let { add("Feed " + DisplayText.cadence(it)) }
        profile.sunHoursTarget?.let { add("Likes about ${kotlin.math.round(it).toInt()} hours of light a day") }
        if (profile.frostSensitive == true) add("Keep away from frost")
    }
    val issues = profile.commonIssues.take(2).map(DisplayText::issuePreview)
    if (lines.isEmpty() && issues.isEmpty()) return
    GlassCard(modifier = Modifier.fillMaxWidth().testTag(InventoryTestTags.CARE_BASICS_SECTION)) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp),
        ) {
            Text("Care basics", style = MaterialTheme.typography.titleMedium)
            lines.forEach { Text(it, style = MaterialTheme.typography.bodyMedium) }
            if (issues.isNotEmpty()) {
                Text(
                    text = "Watch out for",
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                issues.forEach {
                    Text(it, style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }
    }
}
```
New import needed: `dev.plantapp.domain.model.PlantProfile` (the file already
imports `Advisory`/`CareTask` from the same package).

### 5e. `InventoryTestTags.kt` — append

```kotlin
    const val CARE_BASICS_SECTION = "care_basics_section"
```

### 5f. Tests

**RED-FIRST (§7 step 1) — add to `PlantDetailAdvisoriesTest.kt`** (compiles on
baseline: raw tag string; `profile` param doesn't exist yet so build the state
WITHOUT it and assert the section is MISSING-vs-EXPECTED):

```kotlin
    @Test
    fun `care basics card shows plain-language cadence from the profile`() {
        composeRule.setContent {
            PlantDetailScreen(
                state = PlantDetailUiState.Content(plant = plant, task = task, advisories = emptyList()),
            )
        }
        // RED on baseline: no care-basics section exists at all.
        composeRule.onNodeWithTag("care_basics_section").assertIsDisplayed()
    }
```
This fails on baseline (no such node). In step 3 (after implementing), UPGRADE
this same test to construct a profile and assert real copy:
```kotlin
    @Test
    fun `care basics card shows plain-language cadence from the profile`() {
        val profile = PlantProfile(
            "solanum-lycopersicum", "Solanum lycopersicum", listOf("Tomato"), "vegetable",
            wateringIntervalDays = 2.0, feedingIntervalDays = 7.0, sunHoursTarget = 8.0,
            frostSensitive = true,
            commonIssues = listOf("Blossom end rot from uneven watering; keep moisture steady"),
        )
        composeRule.setContent {
            PlantDetailScreen(
                state = PlantDetailUiState.Content(plant = plant, task = task, advisories = emptyList(), profile = profile),
            )
        }
        composeRule.onNodeWithTag(InventoryTestTags.CARE_BASICS_SECTION).assertIsDisplayed()
        composeRule.onNodeWithText("Water about every 2 days").assertIsDisplayed()
        composeRule.onNodeWithText("Feed about once a week").assertIsDisplayed()
        composeRule.onNodeWithText("Likes about 8 hours of light a day").assertIsDisplayed()
        composeRule.onNodeWithText("Keep away from frost").assertIsDisplayed()
        composeRule.onNodeWithText("Blossom end rot from uneven watering").assertIsDisplayed()
    }
```
(Import `dev.plantapp.domain.model.PlantProfile` in the test; check which
assertion helpers the file already imports and match.)
Also add one no-profile guard test: Content WITHOUT `profile` → tag
`assertDoesNotExist()` (the card hides when the lookup failed).

**`DisplayTextTest.kt` additions (step 3):**
- `cadence(1.5) == "every day or two"`
- `cadence(2.0) == "about every 2 days"`
- `cadence(7.0) == "about once a week"`
- `cadence(14.0) == "about every 2 weeks"`
- `cadence(30.0) == "about once a month"`
- `cadence(60.0) == "about every 2 months"`
- `issuePreview("Root rot from overwatering (Penn State); brown roots") == "Root rot from overwatering (Penn State)"`

## 6. Expected failure modes (not regressions)

- §7 step 1: exactly ONE new test fails ("no node with tag care_basics_section").
- All 5 existing `PlantDetailUiState.Content(...)` named-arg constructions keep
  compiling (the new param is defaulted). Any existing test break = regression.
- Gradle deprecation warnings: pre-existing, ignore.

## 7. Standalone verification (red → green, objective)

From `/home/israel/Documents/Development/PlantApp/android`,
`GRADLE_USER_HOME=/tmp/plantapp-gradle-home`.

**Step 1 — RED:** add ONLY the baseline-form red test, run:
```bash
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest --tests "dev.plantapp.feature.inventory.PlantDetailAdvisoriesTest"
```
Expected: exactly the new test fails. Passing → STOP, BLOCKED.

**Step 2 — implement** §5a–§5e. **Step 3 — upgrade the red test + add the
remaining tests** (§5f).

**Step 4 — GREEN:**
```bash
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Full suite green (report actual; expect roughly 48 + 9 new) + app assembles.

## 8. Commit title (Conventional Commits, exact)

```
feat(detail): beginner-language Care basics card from the catalog profile
```

## 9. Push requirement

`git push origin master` — fast-forward expected. Confirm new `origin/master`.

## 10. Final report requirements

Report to `exchange/implementation-inbox/0068-care-basics-card/` via the report
script. Include: scope confirmation (7 files) + `git show --stat HEAD`; RED
evidence; GREEN totals + assembleDebug; the rendered card code block; commit
hash + push confirmation; deviations (or "none").
