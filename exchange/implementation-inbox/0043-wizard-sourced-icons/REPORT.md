# DONE — handoff 0043-wizard-sourced-icons

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** the wizard's hand-authored placeholder vectors are replaced with **real, openly-licensed
sourced icons** — species = CC0 crop SVGs (converted to vector drawables), pots + locations =
Material Symbols (Apache-2.0) with **distinct** glyphs so the six pot sizes are no longer identical.
No emoji, no hand-drawn art, no raster. `:feature-inventory` tests green; `:app:assembleDebug` OK.
Final `origin/master` = `c485afc52f3e687c138ec4ac106dae7e1d7a237e`.

## Baseline + unblock
- HEAD at start = `5f1e7ce…` == origin/master; clean. SDK resolves. CC0 SVGs downloaded fine from
  `openfarmcc/open-crop-icons` (branch `mainline`).

## Species — CC0 crop drawables (openfarmcc/open-crop-icons, public domain)
Downloaded `tomato/basil/strawberry/tomatillo/generic-plant`. The upstream SVGs use CSS
`<style>`-class fills + `<circle>` shapes (not Android-vector-compatible), so I **inlined styles
with SVGO** (`inlineStyles` + `convertStyleToAttrs` + `removeStyleElement` + `convertShapeToPath`)
then converted SVG→vector-drawable with `svg2vectordrawable`. Result drawables carry real per-path
`android:fillColor` (verified: tomato 8, basil 22, strawberry 37, tomatillo 6, default 9, passion
9 fills — not black blobs):
- `ic_species_tomato.xml` ← tomato, `ic_species_basil.xml` ← basil,
  `ic_species_strawberry.xml` ← strawberry, `ic_species_tomatillo.xml` ← tomatillo,
  `ic_species_default.xml` ← generic-plant, **`ic_species_passionfruit.xml` ← generic-plant** (the
  set has no passion fruit). CC0 → no attribution required; provenance recorded.

## Pots + locations — Material Symbols (Apache-2.0), distinct glyphs
Added `androidx.compose.material:material-icons-extended` (catalog `compose-material-icons-extended`
[BOM-managed] + `:feature-inventory` impl dep). `WizardIcons` now returns `ImageVector`s:
- **Pots (visually distinct):** 4-inch / 6-inch / 1-gallon → `LocalFlorist`; **5-gallon bucket →
  `Compost`**; **Window box → `Window`**; **Raised bed / in-ground → `Grass`** (bucket/window-box/
  raised-bed all differ from the small pots and each other).
- **Locations:** Windowsill → `WbSunny`, Balcony → `Balcony`, Backyard → `Cottage`, Indoors →
  `Home`.

## Rework
- `WizardIcons.kt`: `@DrawableRes speciesIconRes(profileId)` (5 ids + `ic_species_default` fallback;
  passion fruit → passionfruit drawable) + `potIcon(label): ImageVector` + `locationIcon(kind):
  ImageVector`.
- `AddPlantWizard.kt`: `Tile` now takes a `leadingIcon` slot — species render via
  `Image(painterResource(...))`, pots/locations via `Icon(imageVector = ...)`. All test tags +
  behaviour unchanged.
- **Deleted** the now-unused placeholders: `ic_loc_windowsill/balcony/backyard/indoors.xml`,
  `ic_pot.xml`. No orphans (the old hand-drawn `ic_species_*` were overwritten by the CC0 versions).
- **License note:** `android/feature-inventory/ICON_LICENSES.md` (species = open-crop-icons CC0;
  pots/locations = Material Symbols Apache-2.0). Placed at the module root, **not** in `res/drawable/`
  (a `.md` there would fail AAPT).

## Tests (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL
```
- `:feature-inventory` **20** tests, all green (icon swap is presentation; behavioural assertions
  unchanged — AddPlantWizardTest 2, AddPlantWizardModelTest 3, InventoryScreensTest 2, NavSmokeTest
  2, NotificationPermissionTest 4, PlantDetailAdvisoriesTest 4, SignInScreenTest 3). No test
  referenced the old `ic_*` ids, so no test edits were needed.
- **`:app:assembleDebug` BUILD SUCCESSFUL** with `material-icons-extended` added.
- No emoji in changed source (grep over `:feature-inventory`/`:app` src → none). No raster.

## Device APK (rebuilt with LAN -P for the owner review)
`android/app/build/outputs/apk/debug/app-debug.apk`, **mtime `2026-06-02 13:20:00 -0700`**
(18,746,525 bytes — larger due to material-icons-extended), built with
`-Pplantapp.apiBaseUrl=http://10.0.0.179:3000/ -Pplantapp.authBaseUrl=http://10.0.0.179:54321/`.

## Commit
- `c485afc` — feat(android-inventory): real sourced wizard icons (CC0 crop SVGs + Material Symbols) replacing placeholders
- `git show --stat HEAD`: 16 files, +369 −126 — only `android/feature-inventory/**` (6 species
  drawables, 5 placeholders deleted, WizardIcons/AddPlantWizard, build.gradle, ICON_LICENSES.md) +
  `android/gradle/libs.versions.toml`. **No apk / no raster / no `local.properties`** committed
  (grep 0/0/0).

## Compliance
- No emoji; no hand-drawn icons (species converted from CC0 SVGs; pots/locations are Material
  Symbols); vectors only (no PNG/raster). Only CC0 + Apache sources. No
  `:network`/`:data`/`:domain`/backend/schema change. No litres/jargon surfaced. SDK/Drive
  untouched.

Final `origin/master` SHA: `c485afc52f3e687c138ec4ac106dae7e1d7a237e`

## Next (per planner follow-up)
Rebuild LAN APK + reinstall for the owner device-review of the new icons (backend still up). Then
the copy sweep — incl. the Plant detail screen (show "Tomato" not the slug, hide raw rationale /
"engine v0.1.0" badge / ISO timestamps), friendlier sign-in, confirm-screen echoing the pot choice,
and friendly advisory copy.
