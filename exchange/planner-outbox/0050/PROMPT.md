# Implementation prompt 0050 — beginner-friendly plant detail (Wave 2 / W1 slice 4)

## 1. Scope (exactly one logical change)
Make the **plant-detail screen** beginner-clean (Garden Hearth + the TOP product constraint:
usable by an elderly novice). Today it leaks jargon: title falls back to the species slug
(`solanum-lycopersicum`), "Growth stage: vegetative", "Next: water" (raw kind), a raw engine
rationale at full prominence, and an "engine v0.1.0" badge.

Changes:
1. **Friendly species name** — `PlantDetailViewModel.loadFor` additionally calls the existing
   `repository.getPlantProfiles()` and resolves the plant's profile; `PlantDetailUiState.Content`
   gains `val speciesName: String? = null` (default keeps all existing constructors compiling).
   On any profile-fetch failure, proceed with `speciesName = null` (never fail the screen for it).
2. **Plain-language mappings** — NEW file `DisplayText.kt` in the feature package:
   ```kotlin
   object DisplayText {
       /** "water" -> "Water", "repot" -> "Move to a bigger pot", etc. */
       fun taskKindLabel(kind: String): String = when (kind) {
           "water" -> "Water"
           "feed" -> "Feed"
           "prune" -> "Trim"
           "repot" -> "Move to a bigger pot"
           "scout-pests" -> "Check for bugs"
           "harvest" -> "Harvest"
           "support" -> "Add a support"
           "rotate" -> "Turn the pot"
           "seasonal-prep" -> "Get ready for the season"
           else -> kind.replace('-', ' ').replaceFirstChar { it.uppercase() }
       }
       /** "vegetative" -> "Growing well", etc. */
       fun growthStageLabel(stage: String): String = when (stage) {
           "seedling" -> "Just starting out"
           "vegetative" -> "Growing well"
           "flowering" -> "Flowering"
           "fruiting" -> "Making fruit"
           "dormant" -> "Resting for now"
           else -> stage.replace('-', ' ').replaceFirstChar { it.uppercase() }
       }
   }
   ```
   (kind list mirrors the DB check constraint in `supabase/migrations/0003` — water/feed/prune/
   repot/scout-pests/harvest/support/rotate/seasonal-prep.)
3. **`PlantDetailScreen.kt`** —
   - Title: `state.plant.nickname ?: state.speciesName ?: prettify(state.plant.profileId)` where
     `prettify` is a tiny private fun (`replace('-', ' ').replaceFirstChar { uppercase }`).
   - `"Growth stage: ${...}"` → just `DisplayText.growthStageLabel(state.plant.growthStage)`.
   - `"Next: ${task.kind}"` → `"Next: ${DisplayText.taskKindLabel(task.kind)}"`.
   - Rationale: keep text + `TASK_RATIONALE` tag (engine explainability stays) but de-emphasize:
     `style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant`.
   - **Delete the engine-version badge** `Surface { … }` block entirely.
   - Advisory row title: drop the `"${severity.uppercase()} · "` prefix — show just
     `advisory.title` (severity stays available in the model; visual severity treatment is a
     later slice). Button text "Accept" → "Yes, add this task".
4. **Tests** (same logical change — the copy is the behavior):
   - `InventoryScreensTest` test `#23`: remove the `ENGINE_VERSION_BADGE` and `"0.1.0"`
     assertions; the `onNodeWithText("water" …)` assertion still passes ("Next: Water" matches
     ignoreCase/substring) — keep it; keep KIND/RATIONALE/DUE_AT tag assertions. Add one
     assertion: `composeRule.onNodeWithText("Growing well").assertIsDisplayed()`.
   - `InventoryTestTags.ENGINE_VERSION_BADGE` constant: delete it (now unused).
   - NEW `DisplayTextTest.kt` (plain JUnit, no Robolectric needed): asserts
     `taskKindLabel("water") == "Water"`, `taskKindLabel("repot") == "Move to a bigger pot"`,
     `taskKindLabel("unknown-kind") == "Unknown kind"`, `growthStageLabel("vegetative") ==
     "Growing well"`, `growthStageLabel("odd-stage") == "Odd stage"`.

## 2. Forbidden changes
- Do NOT touch `:domain`, `:data`, `:network`, `:app`, `:design-system`, backend, schemas,
  supabase, docs, gradle/manifest files.
- Do NOT change `InventoryRepository`, DTOs, or any network/engine behavior.
- Do NOT change the wizard, list, or sign-in screens (their polish is later slices).
- No new dependencies.

## 3. Exact files to touch (6, all under `android/feature-inventory/src/`)
- `main/kotlin/dev/plantapp/feature/inventory/InventoryUiState.kt` (Content + speciesName field)
- `main/kotlin/dev/plantapp/feature/inventory/InventoryViewModels.kt` (PlantDetailViewModel only)
- `main/kotlin/dev/plantapp/feature/inventory/DisplayText.kt` (NEW)
- `main/kotlin/dev/plantapp/feature/inventory/PlantDetailScreen.kt`
- `main/kotlin/dev/plantapp/feature/inventory/InventoryTestTags.kt` (delete unused badge tag)
- `test/kotlin/dev/plantapp/feature/inventory/InventoryScreensTest.kt` (+ NEW
  `test/kotlin/dev/plantapp/feature/inventory/DisplayTextTest.kt`)

## 4. Baseline precondition (STOP-and-report if different)
- Repo `/home/israel/Documents/Development/PlantApp`, branch `master`.
- Expected HEAD: `130c391a2fa088c3001e3e7fda62d625e0c1d29b` (0049).
- Tree clean except untracked `android/.kotlin/` (leave it). Otherwise STOP + BLOCKED report.

## 5. Exact commands
```bash
cd /home/israel/Documents/Development/PlantApp
git rev-parse HEAD && git status --porcelain
# (make the §1/§3 changes)
git diff --stat
cd android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
```

## 6. Expected failure mode
If you run the test suite BEFORE the test edits, `#23` fails on the removed badge — that is the
expected red confirming the visible change. After the §1.4 test updates everything must be green;
any other failure is a regression: STOP, revert, report.

## 7. Standalone verification
- **Type:** green (behavioral copy change covered by updated + new unit tests).
- **Commands & what they prove:**
  1. `grep -c "ENGINE_VERSION_BADGE\|engine v" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/PlantDetailScreen.kt android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/InventoryTestTags.kt | grep -v :0 || echo CLEAN` → `CLEAN` (badge + tag fully gone).
  2. `grep -c "Growth stage:" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/PlantDetailScreen.kt` → `0` (jargon label gone).
  3. `:feature-inventory:testDebugUnitTest` → all pass, count INCREASES from 20 (updated #23 +
     new DisplayTextTest) — report the exact new count.
  4. `:app:assembleDebug` → BUILD SUCCESSFUL.
- **Report:** outputs verbatim + the new test count.

## 8. Commit title (exact)
```
feat(ui): beginner-friendly plant detail (species name, plain stage/kind labels, no engine badge)
```

## 9. Push requirement
Commit and push to `origin master` (fast-forward expected). One change → one commit → one push.

## 10. Final-report requirements
Report to `exchange/implementation-inbox/0050/`: `git show --stat HEAD` (only
`android/feature-inventory/**`), §7 outputs incl. new test count, new commit hash, push
confirmation (new `origin/master`), scope confirmation.
