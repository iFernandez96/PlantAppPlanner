# DONE — handoff 0044-verdant-glasshouse-theme

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** the "Verdant Glasshouse" theme is built into `:design-system` — full light+dark M3 color
schemes, Fraunces (display/headline) + Manrope (title/body/label) typography from bundled **OFL**
variable fonts, rounded shapes, and a `PlantAppTheme(darkTheme, content)` applying them. Since every
screen uses `MaterialTheme.colorScheme/typography/shapes`, the whole app is re-skinned at once.
Builds green. Final `origin/master` = `70c6be9892538624817d39df623e04bf07b1ffc0`.

## Baseline + unblock
- HEAD at start = `c485afc…` == origin/master; clean. `:design-system` was the bare wrapper. SDK
  resolves.

## Fonts (OFL — free to bundle)
- `res/font/fraunces.ttf` (Fraunces variable, 360,440 B) + `res/font/manrope.ttf` (Manrope variable,
  165,420 B), downloaded from the official `google/fonts` OFL paths. `file` confirms both are
  TrueType (non-trivial size) — not error pages.
- OFL licenses bundled at `android/design-system/FONT_LICENSES/Fraunces-OFL.txt` +
  `Manrope-OFL.txt` (kept out of `res/font/`, where a `.txt` would fail AAPT).

## Theme files (`:design-system/src/main/kotlin/dev/plantapp/designsystem/`)
- **`Color.kt`** — `VerdantLightColorScheme` / `VerdantDarkColorScheme` (full M3 roles) from the
  brand palette (per the planner-reviewed reference).
- **`Type.kt`** — `FrauncesFontFamily` (Light/Normal/Medium/SemiBold/Bold) + `ManropeFontFamily`
  (Normal/Medium/SemiBold/Bold) + `PlantAppTypography` (display/headline → Fraunces; title/body/label
  → Manrope; modern sizes). **Variable-font weights are realised by setting the `wght` axis up
  front** via `FontVariation.Settings(FontVariation.weight(n))` on each `Font(...)`
  (`@OptIn(ExperimentalTextApi::class)` — that `Font` overload is experimental), so the weights
  render distinctly rather than collapsing to one.
- **`Shape.kt`** — `PlantAppShapes` (8/12/18/24/28 dp rounded).
- **`Theme.kt`** (replaced) — `PlantAppTheme(darkTheme = isSystemInDarkTheme(), content)` →
  `MaterialTheme(colorScheme = if (darkTheme) dark else light, typography = PlantAppTypography,
  shapes = PlantAppShapes)`. **Dynamic color OFF** (brand palette only). MainActivity's
  content-only `PlantAppTheme { }` still compiles via the default `darkTheme`.

## Gate
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :design-system:assembleDebug :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL
```
- `:design-system:assembleDebug` ✅, `:app:assembleDebug` ✅ (new theme + fonts + schemes resolve;
  `R.font.fraunces`/`R.font.manrope` generated; the default-arg `PlantAppTheme {}` call site
  compiles).
- `:feature-inventory` **20** tests, **0 failures** (theme is token-only; no behaviour change).
- Both TTFs present in `res/font/` and valid TrueType.
- (First compile failed only on the experimental-API opt-in for the `variationSettings` `Font`
  overload — added `@OptIn(ExperimentalTextApi::class)`; no design change.)

## Device APK (rebuilt with LAN -P for the owner review)
`android/app/build/outputs/apk/debug/app-debug.apk`, **mtime `2026-06-02 13:43:14 -0700`**
(19,134,116 B), built with
`-Pplantapp.apiBaseUrl=http://10.0.0.179:3000/ -Pplantapp.authBaseUrl=http://10.0.0.179:54321/`.

## Commit
- `70c6be9` — feat(design-system): Verdant Glasshouse theme (M3 color schemes + Fraunces/Manrope type + shapes)
- `git show --stat HEAD`: 8 files, +332 −4 — **only `android/design-system/**`** (Color/Type/Shape/
  Theme, the 2 TTFs, the 2 OFL licenses). No raster (`.png/.jpg/...` → grep 0). No
  `local.properties` (grep 0). No `libs.versions.toml`/other-module change.

## Compliance
- No dynamic color. No emoji. No raster app imagery (fonts only). Only OFL fonts (licenses
  recorded). No `:network`/`:data`/`:domain`/backend/schema change. No per-screen redesign (re-skin
  comes free via tokens). Scope = `:design-system/**` only. SDK/Drive untouched.

Final `origin/master` SHA: `70c6be9892538624817d39df623e04bf07b1ffc0`

## Next (per planner follow-up)
Rebuild LAN APK + reinstall for the owner device-review of the new look. Then signature components
(glass hero cards, dew-drop progress, gentle motion, leaf hero imagery — may add assets) and the
copy sweep (Plant detail showing "Tomato" not the slug + hiding raw engine text/ISO/"engine v0.1.0",
friendlier sign-in, confirm echoing the pot).
