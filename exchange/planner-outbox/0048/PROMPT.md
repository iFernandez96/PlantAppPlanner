# Implementation prompt 0048 — Hearth card surfaces: GlassCard opacity retune (Wave 2 / W1 slice 2)

## 1. Scope (exactly one logical change)
Garden Hearth (PD-09) replaces translucent glass with **mostly-opaque, warm, readable cards**
(spec: card alpha `0.94f` light / `0.90f` dark; glass becomes decorative, not structural). This
slice retunes the **container alpha values inside `GlassCard`** — no rename (a `HearthCard`
rename/wrapper is a later slice if ever), no signature change, no call-site changes.

## 2. Forbidden changes
- Only `android/design-system/src/main/kotlin/dev/plantapp/designsystem/GlassCard.kt` may change.
- Do NOT rename `GlassCard` or alter either overload's signature/parameters.
- Do NOT touch call sites (`PlantListScreen.kt`, `PlantDetailScreen.kt`, `AddPlantWizard.kt`),
  any other design-system file, any other module, backend, schemas, tests, gradle/manifest.
- No installs, no new dependencies.

## 3. Exact file to touch (1 file)
`android/design-system/src/main/kotlin/dev/plantapp/designsystem/GlassCard.kt`:

1. Non-clickable overload — change
   `.copy(alpha = if (isDark) 0.64f else 0.74f)` → `.copy(alpha = if (isDark) 0.90f else 0.94f)`
2. Clickable overload — change
   `.copy(alpha = if (isDark) 0.68f else 0.78f)` → `.copy(alpha = if (isDark) 0.90f else 0.94f)`
3. Add a KDoc line above the first overload:
   `/** Garden Hearth surface: mostly opaque warm card (decorative translucency only). */`

Tint lerp fractions, borders, elevations, disabled alphas: unchanged.

## 4. Baseline precondition (STOP-and-report if different)
- Repo `/home/israel/Documents/Development/PlantApp`, branch `master`.
- Expected HEAD: `05fba1c048591defa2744fca0080f3958cb1610a` (0047 Garden Hearth tokens).
- Tree clean except untracked `android/.kotlin/` (leave it). Otherwise STOP + BLOCKED report.

## 5. Exact commands
```bash
cd /home/israel/Documents/Development/PlantApp
git rev-parse HEAD && git status --porcelain
# (make the §3 edits)
git diff --stat       # exactly 1 file: GlassCard.kt
cd android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
```

## 6. Expected failure mode
None expected (alpha literals are invisible to the Robolectric semantics tests). Any test/compile
failure is a regression: STOP, revert, report.

## 7. Standalone verification
- **Type:** regression + objective diff evidence (visual outcome verified by planner device
  screenshots at the W1 stage exit).
- **Commands & what they prove:**
  1. `grep -c "0.90f else 0.94f" android/design-system/src/main/kotlin/dev/plantapp/designsystem/GlassCard.kt` → `2` (both overloads retuned).
  2. `grep -c "0.64f\|0.74f\|0.68f\|0.78f" android/design-system/src/main/kotlin/dev/plantapp/designsystem/GlassCard.kt` → `0` (old glass alphas gone).
  3. `:feature-inventory:testDebugUnitTest` → 20/20 pass; 4. `:app:assembleDebug` → BUILD SUCCESSFUL.
- **Report:** grep outputs + test summary + assemble result, verbatim.

## 8. Commit title (exact)
```
feat(design): retune GlassCard to mostly-opaque Hearth surfaces (Wave 2 W1)
```

## 9. Push requirement
Commit and push to `origin master` (fast-forward expected). One change → one commit → one push.

## 10. Final-report requirements
Report to `exchange/implementation-inbox/0048/`: `git show --stat HEAD` (exactly GlassCard.kt),
§7 outputs, new commit hash, push confirmation (new `origin/master`), scope confirmation.
