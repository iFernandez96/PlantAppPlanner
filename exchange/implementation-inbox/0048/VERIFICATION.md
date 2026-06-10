# Standalone verification — 0048

Type: regression + objective diff evidence (visual outcome verified by planner device
screenshots at W1 stage exit).

## 1. Both overloads retuned
```
$ grep -c "0.90f else 0.94f" android/design-system/src/main/kotlin/dev/plantapp/designsystem/GlassCard.kt
2
```
✓ (expected 2)

## 2. Old glass alphas gone
```
$ grep -c "0.64f\|0.74f\|0.68f\|0.78f" android/design-system/src/main/kotlin/dev/plantapp/designsystem/GlassCard.kt
0
```
✓ (expected 0; grep exits 1 on zero matches — that is the no-match exit code, not an error)

## 3. Unit tests — no behavioral regression
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
BUILD SUCCESSFUL in 10s
91 actionable tasks: 8 executed, 83 up-to-date
```
JUnit XML aggregate: `tests=20 failures+errors=0` — 20/20 pass. ✓

## 4. App compiles end-to-end
```
$ GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
BUILD SUCCESSFUL in 1s
125 actionable tasks: 5 executed, 120 up-to-date
```
✓

## Diff evidence
`git diff --stat` before commit:
```
 .../src/main/kotlin/dev/plantapp/designsystem/GlassCard.kt           | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)
```
(+3/−2 = two alpha lines replaced + one KDoc line added.)
