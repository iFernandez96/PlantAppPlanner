# Next Implementation Prompt — beginner add-plant wizard, H1: pure model + mappings

**Beginner-first UX overhaul (owner top priority), add-plant wizard part 1 of 2.** Pin the
wizard's data choices as **pure, unit-tested** Kotlin before any UI: the pot-size options (labeled
"how pots are sold", each mapping to a volume the care engine uses), the location presets, and the
category→icon map. **No UI in this handoff** (that's H2). Spec:
`PlantAppPlanner/reviews/beginner-ux-addplant-spec.md` (owner-approved).

**Why:** the current add-plant form exposes jargon a novice can't answer (litres, material,
drainage, growth stage, ISO dates). The wizard replaces it with plain icon+name choices and lets
the engine derive technical values. This handoff is the derivation/model layer.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`786c12defcd930bf14fc363447f36e426ea8913b` == `origin/master`, clean. `:feature-inventory` has the
pure-object + JUnit pattern (`NotificationPermission.kt` + its test). `:domain` `PlantProfile` has a
`category` field; `getPlantProfiles()` feeds the species tiles (H2). The care engine consumes
`container.volumeLiters` (factor = clamp(vol/recommendedMin, .5, 1.5)) — so the pot→litres mapping
is the only "technical" value the user's size choice produces.

Single logical change (the pure wizard model) → one commit. Red-first.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the pure
add-plant-wizard model. Red-first: write the test first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect 786c12defcd930bf14fc363447f36e426ea8913b == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope — one new pure file (no Android imports, no UI)
**`android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/WizardModel.kt`**
(new):
```kotlin
package dev.plantapp.feature.inventory.addplant

/** A pot size the way pots are SOLD (user never sees litres). [volumeLiters] feeds the care engine. */
data class PotSizeOption(val label: String, val volumeLiters: Double)

/** A friendly place-to-live preset; [kind] is what the backend garden_space.kind stores. */
data class LocationPreset(val label: String, val kind: String)

object AddPlantWizardModel {
    val POT_SIZES: List<PotSizeOption> = listOf(
        PotSizeOption("4-inch pot", 0.5),
        PotSizeOption("6-inch pot", 1.5),
        PotSizeOption("1-gallon pot", 4.0),
        PotSizeOption("5-gallon bucket", 19.0),
        PotSizeOption("Window box", 6.0),
        PotSizeOption("Raised bed / in-ground", 75.0),
    )
    val LOCATION_PRESETS: List<LocationPreset> = listOf(
        LocationPreset("Windowsill", "windowsill"),
        LocationPreset("Balcony", "balcony"),
        LocationPreset("Backyard", "yard"),
        LocationPreset("Indoors", "indoor"),
    )
    /** Plant-category → emoji icon (data-driven via PlantProfile.category; NOT per-species). */
    fun categoryIcon(category: String): String = when (category.lowercase()) {
        "fruit" -> "🍅"; "berry" -> "🍓"; "herb" -> "🌿"; "vegetable" -> "🥬"
        "vine" -> "🍇"; "root" -> "🥕"; "succulent" -> "🌵"; "ornamental" -> "🌸"
        else -> "🌱"
    }
    // Hidden defaults the novice never sets (the engine/back end need them):
    const val DEFAULT_MATERIAL = "plastic"
    const val DEFAULT_DRAINAGE = "good"
    const val DEFAULT_GROWTH_STAGE = "seedling"
}
```
(Keep it pure Kotlin — no `android.*` imports — so it unit-tests on the JVM.)

### Tests — `android/feature-inventory/src/test/.../AddPlantWizardModelTest.kt` (new, JUnit4)
- `POT_SIZES` has the 6 options in order with the exact labels + volumes above (e.g. "5-gallon
  bucket" → 19.0; "Raised bed / in-ground" → 75.0); all volumes > 0.
- `LOCATION_PRESETS` has the 4 presets with the expected `kind`s (Backyard→"yard", Indoors→"indoor").
- `categoryIcon` maps each known category to its emoji and any unknown/empty → "🌱" (fallback);
  case-insensitive.

### Forbidden
- No UI/composable/screen change (that's H2). No `:network`/`:data`/`:domain`/backend/schema change.
  No new dependency. No Android imports in `WizardModel.kt`. Don't mount/repoint the SDK/Drive;
  don't commit `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
```
Red→green: `AddPlantWizardModelTest` fails before `WizardModel.kt` exists; after, `:feature-inventory`
unit tests pass (new test green; prior green). Report count before→after + the new test name.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/feature-inventory/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-inventory): pure add-plant wizard model (pot sizes, location presets, category icons)"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The model (the 6 pot sizes + litres, the 4 location presets, the category→icon map, the hidden
   defaults).
2. `:feature-inventory:testDebugUnitTest` count before→after + new test name (all green).
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/feature-inventory/**` changed (not `local.properties`).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `:feature-inventory`; pure model + tests green). Then **H2 (`0042`): the
`AddPlantWizard` composable** — a 3-step wizard (What are you growing? → Where will it live? →
What's it planted in?) + confirmation, replacing the jargon `AddPlantScreen`: species tiles
(icon by `categoryIcon` + `commonNames.first()` from `getPlantProfiles()`), location preset tiles
(auto-create via `createGardenSpace`), pot-size tiles (→ `createContainer` with `volumeLiters` from
`POT_SIZES` + hidden material/drainage defaults), `growthStage` defaulted, then `addPlant`; big
tappable targets, plain language, no litres/jargon shown; `:app` route wiring + Robolectric tests.
Then the **copy sweep** (sign-in/list/detail + friendly advisory wording). Vision-check each.
