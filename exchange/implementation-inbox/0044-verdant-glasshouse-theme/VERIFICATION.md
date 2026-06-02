# VERIFICATION — handoff 0044-verdant-glasshouse-theme

Gate: `:design-system:assembleDebug :feature-inventory:testDebugUnitTest :app:assembleDebug`. Theme
foundation — token-only change; the existing screen tests are the no-regression guard.

## GREEN
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :design-system:assembleDebug :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL
```
- `:design-system:assembleDebug` ✅ — Color/Type/Shape/Theme compile; `R.font.fraunces` /
  `R.font.manrope` generated from `res/font/`.
- `:feature-inventory:testDebugUnitTest` — **20 tests, 0 failures** (unchanged from baseline; theme
  is presentation-only).
- `:app:assembleDebug` BUILD SUCCESSFUL — the new `PlantAppTheme(darkTheme, content)` + schemes +
  fonts resolve; MainActivity's content-only `PlantAppTheme { }` compiles via the default arg.

## Font integrity
`file design-system/src/main/res/font/*.ttf` → both "TrueType Font data"; sizes 360,440 B
(fraunces) + 165,420 B (manrope) — non-trivial, not curl error pages.

## Experimental-API note (not a regression)
First compile failed only because the `Font(..., variationSettings = …)` overload is
`@ExperimentalTextApi`; resolved by annotating the two font-builder helpers with
`@OptIn(ExperimentalTextApi::class)`. No design/behaviour change.

## Scope / integrity
- `git show --stat HEAD`: 8 files, +332 −4 — **only `android/design-system/**`**: Color.kt, Type.kt,
  Shape.kt, Theme.kt (replaced), fraunces.ttf, manrope.ttf, FONT_LICENSES/{Fraunces,Manrope}-OFL.txt.
- No raster (`grep .png/.jpg/...` → 0). No `local.properties` (0). No `libs.versions.toml` or other
  module change. No dynamic color. No emoji.

## Device APK (uncommitted, for owner review)
`android/app/build/outputs/apk/debug/app-debug.apk`, mtime `2026-06-02 13:43:14 -0700` (19.1 MB),
built with the LAN `-P` URLs.

## Final repo state
- origin/master = `70c6be9892538624817d39df623e04bf07b1ffc0`; local == origin.
- Working tree clean except git-ignored build output + `android/local.properties`.
