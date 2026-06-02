# DONE — handoff 0045-app-backdrop-glass

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** the whole app is now immersive — a themed **backdrop** sits behind every screen,
surfaces use translucent **glass** cards, Scaffolds/app-bars are transparent so the backdrop shows,
the **lavender** wizard tiles are replaced with primary-tinted glass, and top-app-bar titles use the
**Fraunces serif**. Visual-only. Builds green. Final `origin/master` =
`ae60aea075aac3c89ebe82c2b49887eea7a6992c`.

## Baseline + unblock
- HEAD at start = `70c6be9…` == origin/master; clean. SDK resolves.

## What changed
1. **`:design-system` (2 new composables, verbatim from the planner reference):**
   - `Background.kt` — `PlantAppBackground(modifier, content: BoxScope.() -> Unit)`: full-bleed
     theme-aware linear gradient (background→surface→primaryContainer tint→tertiaryContainer tint→
     background) + a soft top radial "sunlight" glow; light/dark via `background.luminance() < 0.5`.
   - `GlassCard.kt` — translucent greenhouse-glass `Card` (container = `surfaceColorAtElevation`
     lerped toward `primaryContainer`, alpha ≈0.74 light / 0.64 dark, 1dp low-alpha outline,
     `shapes.large`) + a **clickable** `GlassCard(onClick, …)` variant.
2. **`:app` `MainActivity.kt`** — `PlantAppTheme { PlantAppBackground { PlantAppNavHost(...) } }` so
   the backdrop is behind every route.
3. **`:feature-inventory` (all Scaffold screens):**
   - `PlantListScreen`, `AddPlantWizard`, `PlantDetailScreen`: `Scaffold(containerColor =
     Color.Transparent)` + `TopAppBar(colors = topAppBarColors(containerColor = Transparent))` +
     title `style = headlineSmall` (Fraunces). (`SignInScreen` is a plain `Column` — it already
     renders over the backdrop, no Scaffold to make transparent.)
   - **Wizard tiles de-lavendered:** `AddPlantWizard`'s `Tile` now uses `GlassCard(onClick = …)`
     (primary-tinted glass) instead of the default M3 `Card` (which read lavender). Every tile keeps
     its `testTag` + onClick + the create/select logic.
   - **Content cards → glass:** list items (`PlantRow`), the detail `CareTaskCard`, and each
     `AdvisoryRow` now render inside `GlassCard` for a consistent look over the backdrop. All test
     tags (`PLANT_LIST`, `TASK_KIND`/`TASK_RATIONALE`/`ENGINE_VERSION_BADGE`/`TASK_DUE_AT`,
     `ADVISORY_SECTION`, `ADVISORY_ACCEPT_BUTTON_*`) preserved; the `PlantRow` keeps its `clickable`
     on the text node so `onNodeWithText(...).performClick()` (NavSmokeTest) still works.
   - Dark-mode legibility uses `onSurface`/glass alphas ≥0.62 per the reference.

## Gate
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :design-system:assembleDebug :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL
```
- `:design-system:assembleDebug` ✅, `:app:assembleDebug` ✅.
- `:feature-inventory` **20 tests, 0 failures** (visual-only; tags/behaviour unchanged — incl.
  NavSmokeTest list-tap + the wizard walk through glass tiles).

## Device APK (rebuilt with LAN -P for the owner review)
`android/app/build/outputs/apk/debug/app-debug.apk`, **mtime `2026-06-02 14:05:00 -0700`**
(19,134,116 B), built with the LAN `-P` URLs.

## Commit
- `ae60aea` — feat(ui): app-wide themed backdrop + glass surfaces (Verdant Glasshouse); fix lavender wizard tiles + serif app-bar titles
- `git show --stat HEAD`: 6 files, +160 −25 — only `android/design-system/**` (Background, GlassCard)
  + `android/feature-inventory/**` (PlantListScreen, AddPlantWizard, PlantDetailScreen) +
  `android/app/**` (MainActivity). No raster (grep 0), no `local.properties` (grep 0), no new
  dependency.

## Compliance
- No `:network`/`:data`/`:domain`/backend/schema/care-engine change. Visual-only (no behaviour/nav
  change). No new dependency. No raster (gradient/vector only). No emoji. No dynamic color. Every
  `testTag` + the wizard create/select logic intact. SDK/Drive untouched.

Final `origin/master` SHA: `ae60aea075aac3c89ebe82c2b49887eea7a6992c`

## Next (per planner follow-up)
Rebuild LAN APK + reinstall for the owner device-review (light + dark). Then optional hero/leaf
imagery + the copy sweep (detail screen "Tomato" not the slug, hide raw engine text/ISO/"engine
v0.1.0", friendlier sign-in, confirm echoes the pot).
