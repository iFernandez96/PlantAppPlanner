# Implementation prompt 0047 — Garden Hearth design tokens (Wave 2 / W1 slice 1)

## 1. Scope (exactly one logical change)
Re-tune the `:design-system` **tokens** to the owner-approved **Garden Hearth** direction
(Wave 2 Gate A, planner `reviews/redesign-directions-wave2.md` §1): warmer palette, slightly
larger beginner-readable body type, slightly tighter shapes, calmer backdrop glow. Token values
only — **no component, screen, navigation, or API changes**. `GlassCard`→`HearthCard` and all
screen rework come in later slices.

## 2. Forbidden changes
- Do NOT touch anything outside the 4 listed files in `android/design-system/`.
- Do NOT touch `Theme.kt`, `GlassCard.kt`, fonts/`FONT_LICENSES`, any other module, backend,
  schemas, supabase, docs, tests, gradle/manifest files.
- Do NOT rename any public `val` (e.g. `VerdantLightColorScheme` keeps its name — renames would
  ripple; a rename slice may come later). Values change, names don't.
- No installs, no new dependencies, no migrations.

## 3. Exact files to touch (4 files, all in `android/design-system/src/main/kotlin/dev/plantapp/designsystem/`)

### 3a. `Color.kt` — Garden Hearth palette (values only, same structure/names)
Change these `val` definitions (lines 7–22):
```kotlin
val VerdantPrimary = Color(0xFF2F6B45)
val VerdantPrimaryDark = Color(0xFF94D8AA)
val VerdantOnPrimary = Color(0xFFFFFFFF)
val VerdantOnPrimaryDark = Color(0xFF07331A)
val VerdantPrimaryContainer = Color(0xFFD7EEDB)
val VerdantPrimaryContainerDark = Color(0xFF245236)
val VerdantSecondary = Color(0xFF9A6B3F)
val VerdantSecondaryDark = Color(0xFFE7BE8E)
val VerdantTertiary = Color(0xFF3D7D87)
val VerdantTertiaryDark = Color(0xFF96D7DF)
val VerdantBackground = Color(0xFFF8F3E7)
val VerdantBackgroundDark = Color(0xFF111711)
val VerdantSurface = Color(0xFFFFFDF6)
val VerdantSurfaceDark = Color(0xFF1B211B)
val VerdantOnSurface = Color(0xFF1E241F)
val VerdantOnSurfaceDark = Color(0xFFE7F0E9)
```
Inside `VerdantLightColorScheme` change only these inline literals:
- `onPrimaryContainer`: `0xFF07351F` → `0xFF10351F`
- `secondaryContainer`: `0xFFF6E5B3` → `0xFFF4DEC4`
- `surfaceVariant`: `0xFFE2E8DD` → `0xFFE7DED0`
- `outline`: `0xFF737B73` → `0xFF8A8174`

Inside `VerdantDarkColorScheme` change only these inline literals:
- `onPrimaryContainer`: `0xFFC9F2D8` → `0xFFD7EEDB`
- `secondaryContainer`: `0xFF5E4A20` → `0xFF5B3E22`
- `onSecondaryContainer`: `0xFFF6E5B3` → `0xFFF4DEC4`
- `surfaceVariant`: `0xFF3F4A42` → `0xFF42483F`
- `outline`: `0xFF8D978E` → `0xFFA39B8D`
- `outlineVariant`: `0xFF3F4A42` → `0xFF42483F`

All other scheme fields (tertiaryContainer, error*, inverse*, scrim, …) stay as they are.

### 3b. `Type.kt` — beginner-readable body sizes (3 styles)
- `titleMedium`: `fontSize = 16.sp, lineHeight = 24.sp` → `fontSize = 17.sp, lineHeight = 24.sp`
- `bodyLarge`: `fontSize = 16.sp, lineHeight = 26.sp` → `fontSize = 17.sp, lineHeight = 28.sp`
- `labelLarge`: `fontSize = 14.sp, lineHeight = 20.sp` → `fontSize = 15.sp, lineHeight = 22.sp`
Nothing else in the file changes (families/weights/other styles untouched).

### 3c. `Shape.kt` — tighter, less pillowy
- `small`: `12.dp` → `10.dp`
- `medium`: `18.dp` → `16.dp`
- `large`: `24.dp` → `22.dp`
(`extraSmall` 8.dp and `extraLarge` 28.dp unchanged.) Update the comment line 7 to
`/** Garden Hearth: friendly, slightly tighter rounding. */`

### 3d. `Background.kt` — glow intensity −40% (line 37)
```kotlin
colors = listOf(glowColor.copy(alpha = if (isDark) 0.11f else 0.12f), glowColor.copy(alpha = if (isDark) 0.05f else 0.06f), Color.Transparent),
```
(replaces the current `0.18f/0.20f` + `0.08f/0.10f` line; everything else unchanged.)

## 4. Baseline precondition (STOP-and-report if different)
- Repo `/home/israel/Documents/Development/PlantApp`, branch `master`.
- Expected HEAD: `a5968a40b466d99a9e5597ce02e5cfa5e24b14ae` (0046).
- Tree clean **except** an untracked `android/.kotlin/` cache dir, which is expected — leave it
  untracked, do not add or delete it.
- If HEAD differs or tracked files are dirty: STOP, change nothing, write a BLOCKED report.

## 5. Exact commands
```bash
cd /home/israel/Documents/Development/PlantApp
git rev-parse HEAD && git status --porcelain
# (make the edits in §3)
git diff --stat            # must show exactly the 4 design-system files
cd android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
```
(Drive must be mounted; EPERM/missing SDK → STOP and report.)

## 6. Expected failure mode
None expected — token-value changes are invisible to the Robolectric semantics tests (20 tests).
Any test failure or compile error is a **regression**: STOP, revert, report.

## 7. Standalone verification
- **Type:** regression + objective diff evidence (visual outcome verified by planner device
  screenshots after merge).
- **Commands & what they prove:**
  1. `grep -c "0xFF2F6B45\|0xFF94D8AA\|0xFFF8F3E7\|0xFF111711" android/design-system/src/main/kotlin/dev/plantapp/designsystem/Color.kt` → expect `4` (palette applied).
  2. `grep -n "17.sp" android/design-system/src/main/kotlin/dev/plantapp/designsystem/Type.kt` → exactly 2 matches (titleMedium, bodyLarge); `grep -n "0.11f" android/design-system/src/main/kotlin/dev/plantapp/designsystem/Background.kt` → 1 match (glow calmed).
  3. `:feature-inventory:testDebugUnitTest` → 20/20 pass (no behavioral regression).
  4. `:app:assembleDebug` → BUILD SUCCESSFUL (theme compiles end-to-end).
- **Report:** all grep outputs + test summary + assemble result, verbatim.

## 8. Commit title (exact)
```
feat(design): retune design-system tokens to Garden Hearth (Wave 2 W1)
```

## 9. Push requirement
Commit and push to `origin master` (fast-forward expected). One change → one commit → one push.

## 10. Final-report requirements
Report to `exchange/implementation-inbox/0047/`:
- `git show --stat HEAD` (exactly 4 files under `android/design-system/`).
- Standalone-verification outputs (§7), new commit hash, push confirmation (new `origin/master`),
  scope confirmation (no renames, no files outside the 4, `.kotlin/` left untracked).
