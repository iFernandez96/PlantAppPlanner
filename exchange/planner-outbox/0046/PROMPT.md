# Implementation prompt 0046 — fix dark-mode content color on transparent Scaffolds

## 1. Scope (exactly one logical change)
Fix the dark-mode contrast bug found in the 2026-06-02 on-device backdrop review
(`reviews/backdrop-device-review-2026-06-02.md` in the planner repo): screen body text (e.g. the
plant-list empty state "No plants yet. Tap + to add your first plant.") renders dark-on-dark in
dark mode and is nearly invisible.

Root cause: the three screens use `Scaffold(containerColor = Color.Transparent)` so the themed
`PlantAppBackground` shows through, but Material 3 derives `contentColor` via
`contentColorFor(containerColor)`, which has **no mapping for `Color.Transparent`** and falls back
to the default `LocalContentColor` (black) — wrong in dark theme. (App-bar titles are unaffected
because `TopAppBar` sets its own title color.)

Fix: pass an explicit `contentColor = MaterialTheme.colorScheme.onBackground` to all **three**
transparent Scaffolds. This also fixes the same latent bug on the error text and detail body.

No other change. The confirm-step "Add" button flagged in the same review was verified as the
legitimate *disabled* state (enables after the space/container round-trip; covered by
`AddPlantWizardTest`) — do NOT touch it.

## 2. Forbidden changes
- Do NOT touch: `backend/**`, `shared-schemas/**`, `supabase/**`, `docs/**`,
  `android/design-system/**`, `android/network/**`, `android/domain/**`, `android/data/**`,
  `android/app/**`, any test file, any gradle/build/manifest file.
- Do NOT change any string, layout, typography, tile, icon, or button logic.
- Do NOT run installs, migrations, or DB commands. No new dependencies.

## 3. Exact files to touch (3 files, one-line edit each)
All in `android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/`:

1. `PlantListScreen.kt` — Scaffold at line 36; after line 38
   (`        containerColor = Color.Transparent,`) add:
   `        contentColor = MaterialTheme.colorScheme.onBackground,`
2. `PlantDetailScreen.kt` — Scaffold at line 40; after its
   `        containerColor = Color.Transparent,` line (line 42) add the same line.
3. `addplant/AddPlantWizard.kt` — Scaffold at line 93; after its
   `        containerColor = Color.Transparent,` line (line 95) add the same line.

`androidx.compose.material3.MaterialTheme` is already imported in all three files — no import
changes needed.

## 4. Baseline precondition (STOP-and-report if different)
- Repo: `/home/israel/Documents/Development/PlantApp`, branch `master`, clean tree.
- Expected HEAD: `ae60aea075aac3c89ebe82c2b49887eea7a6992c`
  (`feat(ui): app-wide themed backdrop + glass surfaces …`).
- If HEAD differs or the tree is dirty: **STOP, change nothing, write a BLOCKED report** to the
  exchange inbox describing what you found.

## 5. Exact commands
```bash
cd /home/israel/Documents/Development/PlantApp
git rev-parse HEAD            # must print ae60aea075aac3c89ebe82c2b49887eea7a6992c
git status --porcelain        # must be empty
# (make the 3 one-line edits)
git diff                      # must show exactly 3 files, +1 line each
cd android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
```
(Drive must be mounted for gradle; if the SDK path errors with EPERM/missing, STOP and report —
owner needs to remount.)

## 6. Expected failure mode
None expected — this is a green change on a green tree. If `:feature-inventory` tests fail, that
is a **regression** (the change should be invisible to Robolectric semantics): STOP, revert your
edit, and report. Pre-existing warnings (Kotlin/AGP deprecation notices) are noise — ignore.

## 7. Standalone verification
- **Type:** regression + objective diff evidence (visual styling change; final visual confirmation
  is a planner device re-screenshot after merge).
- **Commands & what they prove:**
  1. `grep -n "contentColor = MaterialTheme.colorScheme.onBackground" android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/PlantListScreen.kt android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/PlantDetailScreen.kt android/feature-inventory/src/main/kotlin/dev/plantapp/feature/inventory/addplant/AddPlantWizard.kt`
     → must print exactly **3 matches, one per file** (proves the fix is present everywhere the
     transparent-Scaffold pattern exists).
  2. `GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest`
     → all tests pass (currently 22) — proves no behavioral regression.
  3. `GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug` → BUILD SUCCESSFUL —
     proves the app still compiles end-to-end.
- **Report:** the grep output, the test summary line, and the assemble result, verbatim.

## 8. Commit title (exact)
```
fix(ui): set onBackground content color on transparent Scaffolds (dark-mode empty-state contrast)
```

## 9. Push requirement
Commit and push to `origin master` (fast-forward expected; remote is
`git@github.com:iFernandez96/PlantApp.git`). One change → one commit → one push.

## 10. Final-report requirements
Write the report to the exchange inbox (`exchange/implementation-inbox/0046/` per protocol):
- `git show --stat HEAD` output (must show exactly the 3 files, +3/-0 total).
- The standalone-verification outputs (grep 3/3, test summary, assembleDebug result).
- New commit hash + push confirmation (new `origin/master` SHA).
- Scope confirmation: nothing outside the 3 listed files changed; no forbidden paths touched.
