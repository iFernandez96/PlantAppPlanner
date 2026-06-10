# Implementation prompt 0049 — bottom-tab navigation shell (Wave 2 / W1 slice 3)

## 1. Scope (exactly one logical change)
Introduce the Garden Hearth **bottom-tab navigation shell** in `:app` (wave plan W1; spec
`reviews/redesign-directions-wave2.md` §1 "Bottom Bar"): a Material 3 `NavigationBar` with three
tabs — **Today · My Garden · Spaces** — where My Garden is the existing plant list and Today/
Spaces are warm placeholder screens (their real content is W3/W4). The **Assistant** tab is NOT
added (W5). Start destination stays exactly as today (plant list when signed in, sign-in
otherwise) until W3 flips home to Today.

Behavior spec:
- The bar shows **only** on the three top-level tab routes — not on sign-in, the add-plant
  wizard, or plant detail.
- Labels always visible; icons from the **already-used** Material extended set: Today =
  `Icons.Filled.WbSunny`, My Garden = `Icons.Filled.LocalFlorist`, Spaces = `Icons.Filled.Balcony`
  (all three are proven imports in `WizardIcons.kt`).
- Tab clicks navigate with `launchSingleTop = true`, `restoreState = true`, and
  `popUpTo(Routes.LIST) { saveState = true }` (standard M3 bottom-nav pattern; consult the
  androidx navigation-compose docs if unsure).
- Bar surface: opaque (`containerColor = MaterialTheme.colorScheme.surface`) per Hearth (no
  translucency); selected indicator default (`primaryContainer`).
- Placeholders (new file, plain beginner copy, no jargon):
  - Today: headline "Today" + body "Your care list is coming soon. For now, open a plant to
    see what it needs."
  - Spaces: headline "Spaces" + body "Browsing by balcony, backyard and windowsill is coming
    soon."
  - Both centered on the themed backdrop, `testTag("today_placeholder")` /
    `testTag("spaces_placeholder")`; bar items get `testTag("tab_today")`, `testTag("tab_garden")`,
    `testTag("tab_spaces")`.

## 2. Forbidden changes
- Do NOT touch `:feature-inventory`, `:design-system`, `:domain`, `:data`, `:network`, backend,
  schemas, supabase, docs, or any test file.
- Do NOT change sign-in/wizard/detail behavior, the POST_NOTIFICATIONS logic, start-destination
  logic, or any existing route string.
- Do NOT add any dependency that is not already in `gradle/libs.versions.toml`.

## 3. Exact files to touch (3)
1. `android/app/build.gradle.kts` — add one line next to the other compose deps (line ~57):
   `implementation(libs.compose.material.icons.extended)` (already in the version catalog and
   already used by `:feature-inventory`).
2. `android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt` — add `TODAY = "today"`
   and `SPACES = "spaces"` to `Routes`; wrap the existing `NavHost` in a `Scaffold(
   containerColor = Color.Transparent, contentColor = MaterialTheme.colorScheme.onBackground,
   bottomBar = { … })` whose `NavigationBar` renders only when the current destination (via
   `currentBackStackEntryAsState()`) is one of TODAY/LIST/SPACES; add `composable(Routes.TODAY)`
   and `composable(Routes.SPACES)` entries rendering the placeholders. Existing composable
   bodies (signin/list/add/detail) move inside unchanged — do not edit their logic.
3. `android/app/src/main/kotlin/dev/plantapp/android/PlaceholderScreens.kt` — NEW file with
   `TodayPlaceholderScreen()` and `SpacesPlaceholderScreen()` per §1.

## 4. Baseline precondition (STOP-and-report if different)
- Repo `/home/israel/Documents/Development/PlantApp`, branch `master`.
- Expected HEAD: `7b5ba83327b5d85c1b58d9f5b10393ca4bae5b80` (0048).
- Tree clean except untracked `android/.kotlin/` (leave it). Otherwise STOP + BLOCKED report.

## 5. Exact commands
```bash
cd /home/israel/Documents/Development/PlantApp
git rev-parse HEAD && git status --porcelain
# (make the §3 changes)
git diff --stat        # exactly: app/build.gradle.kts, MainActivity.kt, PlaceholderScreens.kt (new)
cd android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :data:testDebugUnitTest
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
```
(Drive must be mounted; EPERM/missing SDK → STOP and report.)

## 6. Expected failure mode
None expected — `:app` has no unit tests; module suites don't exercise MainActivity. Any compile
error or module-test failure is a **regression**: STOP, revert, report. A first-build download
of the icons-extended artifact for `:app` is normal, not a failure.

## 7. Standalone verification
- **Type:** regression + objective diff/grep evidence (interactive behavior verified by planner
  on-device at the W1 stage exit).
- **Commands & what they prove:**
  1. `grep -n "tab_today\|tab_garden\|tab_spaces" android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt` → 3 matches (bar + tags exist).
  2. `grep -n "today_placeholder\|spaces_placeholder" android/app/src/main/kotlin/dev/plantapp/android/PlaceholderScreens.kt` → 2 matches (placeholders exist).
  3. `grep -c "icons.extended" android/app/build.gradle.kts` → 1 (catalog dep wired).
  4. `grep -n "startDestination" android/app/src/main/kotlin/dev/plantapp/android/MainActivity.kt` → still driven by the existing `settings.tokenBlocking()` check (unchanged home).
  5. `:feature-inventory:testDebugUnitTest` + `:data:testDebugUnitTest` green; `:app:assembleDebug` BUILD SUCCESSFUL.
- **Report:** all outputs verbatim.

## 8. Commit title (exact)
```
feat(app): bottom-tab navigation shell (Today / My Garden / Spaces) for Garden Hearth (Wave 2 W1)
```

## 9. Push requirement
Commit and push to `origin master` (fast-forward expected). One change → one commit → one push.

## 10. Final-report requirements
Report to `exchange/implementation-inbox/0049/`: `git show --stat HEAD` (exactly the 3 files),
§7 outputs, new commit hash, push confirmation (new `origin/master`), scope confirmation
(no feature-module/test changes; routes/start logic untouched; only catalog-existing dep added).
