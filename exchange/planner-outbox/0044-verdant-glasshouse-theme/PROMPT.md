# Next Implementation Prompt — "Verdant Glasshouse" theme foundation (re-skin the whole app)

**Modern/thematic UI overhaul (owner top priority), theme foundation.** `:design-system` is
currently bare (`PlantAppTheme { MaterialTheme(content) }` — default M3, no color/type/shape). Build
the owner-chosen **"Verdant Glasshouse"** theme into it: full light+dark Material-3 color schemes,
**Fraunces** (display) + **Manrope** (body) typography from bundled **OFL** fonts, modern rounded
shapes, and a `PlantAppTheme` that applies them. Because every screen already uses
`MaterialTheme.colorScheme/typography/shapes` tokens, this **re-skins the entire app at once**.
(The reference Kotlin below was generated with Codex and reviewed by the planner — use it as-is with
the corrections noted.) Signature components (glass hero cards, dew-drop progress, motion, leaf
imagery) + the copy sweep are LATER handoffs; this is the foundation.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `c485afc...` == `origin/master`, clean.
`:design-system/src/main/kotlin/dev/plantapp/designsystem/Theme.kt` is the only file (the bare
wrapper). `:design-system/build.gradle.kts` has Compose + Material3, **no fonts, no res/**. No
`res/font` anywhere. `:app` `MainActivity` calls `PlantAppTheme { … }` (content-only) — the new
`PlantAppTheme(darkTheme = isSystemInDarkTheme(), content)` keeps that call compiling (default arg).

Single logical change (the theme foundation) → one commit.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Build the Verdant
Glasshouse theme in `:design-system`. **Consult the Compose `FontFamily`/`res/font` docs.**

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect c485afc52f3e687c138ec4ac106dae7e1d7a237e == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **Bundle the fonts (OFL — free to bundle)** in `:design-system/src/main/res/font/`:
   - **Fraunces** (variable) → `fraunces.ttf`; **Manrope** (variable) → `manrope.ttf`. Download the
     OFL TTFs from the official `google/fonts` repo, e.g.:
     ```bash
     mkdir -p android/design-system/src/main/res/font
     curl -fsSL "https://raw.githubusercontent.com/google/fonts/main/ofl/fraunces/Fraunces%5BSOFT%2CWONK%2Copsz%2Cwght%5D.ttf" -o android/design-system/src/main/res/font/fraunces.ttf
     curl -fsSL "https://raw.githubusercontent.com/google/fonts/main/ofl/manrope/Manrope%5Bwght%5D.ttf" -o android/design-system/src/main/res/font/manrope.ttf
     ```
     If those exact paths 404, find the correct OFL TTF path in `google/fonts` (the static or
     variable build) and use it — **STOP and report** if neither family can be fetched. Android
     `res/font` resource names must be lowercase `[a-z0-9_]` (`fraunces`, `manrope` — good). Also
     fetch each family's `OFL.txt` license → `res/font/` is invalid for `.txt`, so put the two
     license files at `android/design-system/FONT_LICENSES/` (FontLog/OFL).
2. **Add the theme files** (NOTE: project uses `src/main/kotlin/...`, NOT `java`). Use this
   planner-reviewed, Codex-generated code (adjust only if the compiler requires):
   - `android/design-system/src/main/kotlin/dev/plantapp/designsystem/Color.kt`
   - `.../Type.kt`  ·  `.../Shape.kt`  ·  replace `.../Theme.kt`

   **`Color.kt`**
   ```kotlin
   package dev.plantapp.designsystem

   import androidx.compose.material3.darkColorScheme
   import androidx.compose.material3.lightColorScheme
   import androidx.compose.ui.graphics.Color

   val VerdantPrimary = Color(0xFF1F6F4A); val VerdantPrimaryDark = Color(0xFF7ED9A4)
   val VerdantOnPrimary = Color(0xFFFFFFFF); val VerdantOnPrimaryDark = Color(0xFF062013)
   val VerdantPrimaryContainer = Color(0xFFC9F2D8); val VerdantPrimaryContainerDark = Color(0xFF16472F)
   val VerdantSecondary = Color(0xFF8A6F3D); val VerdantSecondaryDark = Color(0xFFDCC58A)
   val VerdantTertiary = Color(0xFF2F7E8C); val VerdantTertiaryDark = Color(0xFF8CDCE6)
   val VerdantBackground = Color(0xFFF6F3E9); val VerdantBackgroundDark = Color(0xFF07130D)
   val VerdantSurface = Color(0xFFFFFBF2); val VerdantSurfaceDark = Color(0xFF0F1D16)
   val VerdantOnSurface = Color(0xFF1E241F); val VerdantOnSurfaceDark = Color(0xFFE7F0E9)

   val VerdantLightColorScheme = lightColorScheme(
       primary = VerdantPrimary, onPrimary = VerdantOnPrimary,
       primaryContainer = VerdantPrimaryContainer, onPrimaryContainer = Color(0xFF07351F),
       inversePrimary = VerdantPrimaryDark,
       secondary = VerdantSecondary, onSecondary = Color(0xFFFFFFFF),
       secondaryContainer = Color(0xFFF6E5B3), onSecondaryContainer = Color(0xFF2D2108),
       tertiary = VerdantTertiary, onTertiary = Color(0xFFFFFFFF),
       tertiaryContainer = Color(0xFFC4EDF2), onTertiaryContainer = Color(0xFF062F36),
       background = VerdantBackground, onBackground = VerdantOnSurface,
       surface = VerdantSurface, onSurface = VerdantOnSurface,
       surfaceVariant = Color(0xFFE2E8DD), onSurfaceVariant = Color(0xFF434B45), surfaceTint = VerdantPrimary,
       inverseSurface = Color(0xFF293129), inverseOnSurface = Color(0xFFF0F7EF),
       error = Color(0xFFBA1A1A), onError = Color(0xFFFFFFFF),
       errorContainer = Color(0xFFFFDAD6), onErrorContainer = Color(0xFF410002),
       outline = Color(0xFF737B73), outlineVariant = Color(0xFFC3CBC1), scrim = Color(0xFF000000),
   )
   val VerdantDarkColorScheme = darkColorScheme(
       primary = VerdantPrimaryDark, onPrimary = VerdantOnPrimaryDark,
       primaryContainer = VerdantPrimaryContainerDark, onPrimaryContainer = Color(0xFFC9F2D8),
       inversePrimary = VerdantPrimary,
       secondary = VerdantSecondaryDark, onSecondary = Color(0xFF3B2D0A),
       secondaryContainer = Color(0xFF5E4A20), onSecondaryContainer = Color(0xFFF6E5B3),
       tertiary = VerdantTertiaryDark, onTertiary = Color(0xFF00363E),
       tertiaryContainer = Color(0xFF145B66), onTertiaryContainer = Color(0xFFC4EDF2),
       background = VerdantBackgroundDark, onBackground = VerdantOnSurfaceDark,
       surface = VerdantSurfaceDark, onSurface = VerdantOnSurfaceDark,
       surfaceVariant = Color(0xFF3F4A42), onSurfaceVariant = Color(0xFFC4CEC5), surfaceTint = VerdantPrimaryDark,
       inverseSurface = Color(0xFFE7F0E9), inverseOnSurface = Color(0xFF253027),
       error = Color(0xFFFFB4AB), onError = Color(0xFF690005),
       errorContainer = Color(0xFF93000A), onErrorContainer = Color(0xFFFFDAD6),
       outline = Color(0xFF8D978E), outlineVariant = Color(0xFF3F4A42), scrim = Color(0xFF000000),
   )
   ```
   **`Type.kt`** — `FrauncesFontFamily` (`Font(R.font.fraunces, FontWeight.X)` for Light/Normal/
   Medium/SemiBold/Bold) for display+headline; `ManropeFontFamily` (Normal/Medium/SemiBold/Bold) for
   title/body/label; a `PlantAppTypography = Typography(...)` mapping display/headline→Fraunces and
   title/body/label→Manrope with modern sizes (displayLarge 56/64 SemiBold … bodyLarge 16/26 Normal …
   labelLarge 14/20 Bold). Import `dev.plantapp.designsystem.R`. **Variable fonts:** since one
   variable TTF backs all weights, apply `FontVariation.Settings(FontVariation.weight(<n>))` to each
   `Font(...)` **up front** (e.g. weight 300/400/500/600/700) so the weight axis actually renders
   distinct weights — don't rely on the bare `Font(res, FontWeight.X)` alone.
   **`Shape.kt`** — `PlantAppShapes = Shapes(extraSmall 8.dp, small 12.dp, medium 18.dp, large 24.dp,
   extraLarge 28.dp)` (RoundedCornerShape).
   **`Theme.kt`** (replace):
   ```kotlin
   package dev.plantapp.designsystem
   import androidx.compose.foundation.isSystemInDarkTheme
   import androidx.compose.material3.MaterialTheme
   import androidx.compose.runtime.Composable
   @Composable
   fun PlantAppTheme(darkTheme: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit) {
       MaterialTheme(
           colorScheme = if (darkTheme) VerdantDarkColorScheme else VerdantLightColorScheme,
           typography = PlantAppTypography,
           shapes = PlantAppShapes,
           content = content,
       )
   }
   ```
3. **No new dependency / no `libs.versions.toml` change** — `res/font` + the Compose font APIs are
   built in. If `R` isn't generated for the module, ensure `buildFeatures { compose = true }` stays
   and the fonts are under `src/main/res/font/`. (If you somehow find a gradle change is truly
   required, STOP and report — the scope is `:design-system/**` only.)

### Forbidden
- No dynamic color (use the brand palette). No emoji. No raster app imagery in THIS handoff (fonts
  only; hero imagery is a later handoff). No `:network`/`:data`/`:domain`/backend/schema change. No
  per-screen redesign here (the re-skin comes free via tokens; signature components are later). Only
  **OFL** fonts (free to bundle) — record the OFL license. Don't commit `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :design-system:assembleDebug :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Expected: all compile; `:app:assembleDebug` BUILD SUCCESSFUL (the new `PlantAppTheme` + fonts +
schemes resolve; MainActivity's `PlantAppTheme { }` still compiles via the default `darkTheme`).
Existing `:feature-inventory` tests stay green (theme tokens, no behavior change). Report results +
confirm the two TTFs are in `res/font/`. **Also verify font integrity** (a `curl -fsSL` can still
write a tiny error page): `file android/design-system/src/main/res/font/*.ttf` reports TrueType, and
each is non-trivial (e.g. `>50 KB`) — if a TTF is missing/empty/not-a-font, STOP and report.
(Final look is the owner's on-device call — the planner rebuilds + reinstalls for review.)

### Expected failure mode (distinguish from regressions)
- `gradlew` aborts with **"SDK location not found"** / Drive-unmounted → **infrastructure**, STOP
  and report (not a regression). Tripwire: Drive must be mounted.
- `Type.kt` fails to compile on **`R.font.fraunces`/`R.font.manrope` unresolved** → the TTFs aren't
  under `src/main/res/font/` with lowercase names, or `compose`/`R` isn't generated — fix the
  resource placement; do **not** treat as pre-existing.
- A **`curl` URL 404s** → STOP and report the exact URL tried; do **not** guess a different font and
  silently proceed.
- If a `:feature-inventory` test fails, check whether it failed at baseline `c485afc` (pre-existing)
  vs. introduced here; report which. The theme change should not alter any test behavior.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/design-system/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(design-system): Verdant Glasshouse theme (M3 color schemes + Fraunces/Manrope type + shapes)"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The files added (Color/Type/Shape/Theme), the two OFL TTFs bundled (+ where the OFL licenses
   live), and confirmation `PlantAppTheme(darkTheme, content)` is applied (dynamic color OFF).
2. `:design-system:assembleDebug` + `:feature-inventory:testDebugUnitTest` + `:app:assembleDebug`
   results; the two TTFs present in `res/font/`.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm **only
   `android/design-system/**`** changed; no raster, no `local.properties`, OFL fonts only.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; `:design-system` themed; OFL fonts bundled; builds green). Then **rebuild the LAN
APK + reinstall** for an owner device-review of the new look (backend still up). Then the signature
components (glass hero cards, dew-drop progress, gentle motion, leaf hero imagery — imagery may add
assets) and the **copy sweep** (Plant detail screen showing "Tomato" not the slug + hiding raw
engine text/ISO/"engine v0.1.0", friendlier sign-in, confirm echoes the pot). Vision-check each.
