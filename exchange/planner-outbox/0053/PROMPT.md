# Implementation prompt 0053 — Hearth list rows with friendly names (Wave 2 / W1 slice 6)

## 1. Scope (exactly one logical change)
Re-skin **My Garden's plant rows** to the Garden Hearth list spec and kill the last slug leak:
rows currently render `plant.nickname ?: plant.profileId` as a bare text line (the 0052 device
check showed `fragaria-x-ananassa` in the list). Target (spec `reviews/redesign-directions-wave2.md`
§1 "My Garden"): roomy tappable cards with a big species icon and plain names.

1. **Friendly names in state** — `PlantListUiState.Content` gains
   `val speciesNames: Map<String, String> = emptyMap()` (profileId → first common name).
   `PlantListViewModel.refresh()` also fetches `repository.getPlantProfiles()`
   (`runCatching … getOrDefault(emptyList())`) and builds the map. Profile failure must never
   break the list.
2. **Shared fallback helper** — add to `DisplayText`:
   `fun speciesFallbackName(profileId: String): String = profileId.replace('-', ' ')
   .replaceFirstChar { it.uppercase() }`. Replace `PlantDetailScreen`'s private `prettify` with
   it (delete the private fun; same output).
3. **`PlantRow` re-skin** (`PlantListScreen.kt`) — use the **clickable `GlassCard(onClick = …)`**
   overload (drop the inner `Modifier.clickable` text); row content: `Row` with 16.dp padding,
   `Image(painterResource(WizardIcons.speciesIconRes(plant.profileId)))` at 64.dp, then a
   `Column`: primary `Text` = `plant.nickname ?: speciesNames[plant.profileId] ?:
   DisplayText.speciesFallbackName(plant.profileId)` in `titleMedium`; secondary `Text`
   (only when it differs from the primary) = `speciesNames[plant.profileId]` in `bodyMedium`
   + `onSurfaceVariant`. Min row height 104.dp (`Modifier.heightIn(min = 104.dp)`), icon and
   texts vertically centered. Each card gets `testTag(InventoryTestTags.PLANT_ROW_PREFIX +
   plant.id)` — add that const (`"plant_row_"`) to `InventoryTestTags`.
   `PlantRow` gains a `speciesNames: Map<String, String>` parameter; the `items(...)` call site
   passes it from `state`.
4. **Tests** — in `InventoryScreensTest`: new test — render `PlantListScreen` with
   `Content(plants = listOf(plant), speciesNames = mapOf("solanum-lycopersicum" to "Tomato"))`
   using a `plant` copy with `nickname = null`, assert `onNodeWithText("Tomato")` is displayed
   and `onNodeWithText("solanum-lycopersicum")` does NOT exist (red-first: fails on current
   code, which renders the slug). Existing tests must keep passing (`Content` default param +
   nickname-first behavior preserve them).

## 2. Forbidden changes
- Do NOT touch `:domain`, `:data`, `:network`, `:app`, `:design-system`, backend, schemas,
  supabase, gradle/manifest.
- Do NOT change the FAB, top bar, empty/error states, detail/wizard/sign-in behavior (except
  the `prettify` → `DisplayText.speciesFallbackName` swap in `PlantDetailScreen`).
- No new dependencies.

## 3. Exact files to touch (6, all under `android/feature-inventory/src/`)
- `main/.../InventoryUiState.kt` (Content + speciesNames)
- `main/.../InventoryViewModels.kt` (PlantListViewModel.refresh only)
- `main/.../DisplayText.kt` (+ speciesFallbackName)
- `main/.../PlantListScreen.kt` (PlantRow re-skin + call site)
- `main/.../PlantDetailScreen.kt` (swap private prettify → DisplayText.speciesFallbackName)
- `main/.../InventoryTestTags.kt` (+ PLANT_ROW_PREFIX) and
  `test/.../InventoryScreensTest.kt` (new red-first test)

## 4. Baseline precondition (STOP-and-report if different)
- Repo `/home/israel/Documents/Development/PlantApp`, branch `master`.
- Expected HEAD: `a22292988b9a32c5aa04433da6e3485a189a9933` (0052).
- Tree clean except untracked `android/.kotlin/` (leave it). Otherwise STOP + BLOCKED report.

## 5. Exact commands
```bash
cd /home/israel/Documents/Development/PlantApp
git rev-parse HEAD && git status --porcelain
# 1) RED: add ONLY the new §1.4 test, run:
cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
#    -> expect exactly the new test to FAIL (slug rendered / "Tomato" missing). Capture it.
# 2) GREEN: apply §1.1–1.3, re-run the suite, then:
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
```

## 6. Expected failure mode
Red step: only the new list-name test fails. Green step: full suite passes (report new count);
any other failure is a regression: STOP, revert, report.

## 7. Standalone verification
- **Type:** red-first → green + planner device follow-up (list shows "Tomato"/"Strawberry"
  with icons, 104dp Hearth rows).
- **Commands & what they prove:** §5 red output (test guards the slug leak); §5 green run +
  new count (fix, no regression); `grep -c "prettify" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/PlantDetailScreen.kt` → `0` (helper unified);
  `grep -c "speciesIconRes" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/PlantListScreen.kt` → `1` (icon wired); `:app:assembleDebug` BUILD SUCCESSFUL.
- **Report:** outputs verbatim.

## 8. Commit title (exact)
```
feat(ui): Hearth plant-list rows — species icon + friendly names, no slugs
```

## 9. Push requirement
Commit and push to `origin master` (fast-forward expected). One change → one commit → one push.

## 10. Final-report requirements
Report to `exchange/implementation-inbox/0053/`: `git show --stat HEAD` (only
`android/feature-inventory/**`), red+green evidence, new test count, commit hash, push
confirmation (new `origin/master`), scope confirmation.
