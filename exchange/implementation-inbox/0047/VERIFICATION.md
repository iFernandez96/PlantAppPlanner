# Standalone verification — 0047

Type: regression + objective diff evidence (visual outcome verified by planner device
screenshots after merge).

## 1. Palette applied
```
$ grep -c "0xFF2F6B45\|0xFF94D8AA\|0xFFF8F3E7\|0xFF111711" android/design-system/src/main/kotlin/dev/plantapp/designsystem/Color.kt
4
```
✓ (expected 4)

## 2. Type + glow
```
$ grep -n "17.sp" android/design-system/src/main/kotlin/dev/plantapp/designsystem/Type.kt
54:    titleMedium = TextStyle(fontFamily = ManropeFontFamily, fontWeight = FontWeight.SemiBold, fontSize = 17.sp, lineHeight = 24.sp, letterSpacing = 0.15.sp),
56:    bodyLarge = TextStyle(fontFamily = ManropeFontFamily, fontWeight = FontWeight.Normal, fontSize = 17.sp, lineHeight = 28.sp, letterSpacing = 0.5.sp),

$ grep -n "0.11f" android/design-system/src/main/kotlin/dev/plantapp/designsystem/Background.kt
37:            colors = listOf(glowColor.copy(alpha = if (isDark) 0.11f else 0.12f), glowColor.copy(alpha = if (isDark) 0.05f else 0.06f), Color.Transparent),
```
✓ exactly 2 `17.sp` matches (titleMedium, bodyLarge); 1 `0.11f` match (glow calmed).

## 3. Unit tests — no behavioral regression
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
BUILD SUCCESSFUL in 11s
91 actionable tasks: 8 executed, 8 from cache, 75 up-to-date
```
JUnit XML aggregate: `tests=20 failures+errors=0` — 20/20 pass. ✓

## 4. App compiles end-to-end
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
BUILD SUCCESSFUL in 2s
125 actionable tasks: 5 executed, 4 from cache, 116 up-to-date
```
✓

## Diff evidence
`git diff --stat` before commit:
```
 .../kotlin/dev/plantapp/designsystem/Background.kt |  2 +-
 .../main/kotlin/dev/plantapp/designsystem/Color.kt | 42 +++++++++++-----------
 .../main/kotlin/dev/plantapp/designsystem/Shape.kt |  8 ++---
 .../main/kotlin/dev/plantapp/designsystem/Type.kt  |  6 ++--
 4 files changed, 29 insertions(+), 29 deletions(-)
```
Exactly the 4 listed design-system files; values changed, no `val` renamed.
