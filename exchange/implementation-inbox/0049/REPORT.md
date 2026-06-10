# Implementation report — 0049-bottom-tab-shell

## Status: DONE

## What was done
Garden Hearth bottom-tab navigation shell in `:app`, per §1/§3:

- **`app/build.gradle.kts`** — one line added next to the other compose deps:
  `implementation(libs.compose.material.icons.extended)` (already in the version catalog;
  already used by `:feature-inventory`). No other dependency change.
- **`MainActivity.kt`** —
  - `Routes` gains `TODAY = "today"` and `SPACES = "spaces"`; no existing route string changed.
  - New private `BottomTab` data class + `BOTTOM_TABS` list: Today (`Icons.Filled.WbSunny`,
    `tab_today`), My Garden (`Icons.Filled.LocalFlorist`, `tab_garden`), Spaces
    (`Icons.Filled.Balcony`, `tab_spaces`).
  - `PlantAppNavHost` now wraps the nav graph in `Scaffold(containerColor = Color.Transparent,
    contentColor = MaterialTheme.colorScheme.onBackground, bottomBar = { … })`. The
    `NavigationBar` (opaque `colorScheme.surface`, labels always visible, default
    primaryContainer indicator) renders **only** when `currentBackStackEntryAsState()`'s route
    is one of TODAY/LIST/SPACES — never on sign-in, wizard, or detail.
  - Tab clicks navigate with `launchSingleTop = true`, `restoreState = true`,
    `popUpTo(Routes.LIST) { saveState = true }`.
  - The NavHost body moved verbatim into a private `PlantAppNavGraph(nav, startDestination,
    modifier)` composable (receives the controller, so the four existing composable bodies —
    signin/list/add/detail, incl. POST_NOTIFICATIONS logic — are byte-identical, just indented
    location change is zero: bodies untouched). Two new entries added:
    `composable(Routes.TODAY)` / `composable(Routes.SPACES)` rendering the placeholders.
  - Start destination logic unchanged: `settings.tokenBlocking() != null → LIST else SIGN_IN`.
- **`PlaceholderScreens.kt`** (NEW) — `TodayPlaceholderScreen()` and `SpacesPlaceholderScreen()`
  with the exact beginner copy from §1, centered, `testTag("today_placeholder")` /
  `testTag("spaces_placeholder")`, drawn over the themed backdrop (transparent Scaffold above).

Assistant tab NOT added (W5), per scope.

## Baseline precondition
- HEAD before work: `7b5ba83327b5d85c1b58d9f5b10393ca4bae5b80` ✓
- Tree clean except untracked `android/.kotlin/` (left alone) ✓

## Commit + push
- New commit: `130c391a2fa088c3001e3e7fda62d625e0c1d29b`
- Title (exact): `feat(app): bottom-tab navigation shell (Today / My Garden / Spaces) for Garden Hearth (Wave 2 W1)`
- Pushed: `7b5ba83..130c391  master -> master` (fast-forward)
- New `origin/master`: `130c391a2fa088c3001e3e7fda62d625e0c1d29b`

### git show --stat HEAD
```
 android/app/build.gradle.kts                       |  1 +
 .../kotlin/dev/plantapp/android/MainActivity.kt    | 75 +++++++++++++++++++++-
 .../dev/plantapp/android/PlaceholderScreens.kt     | 60 +++++++++++++++++
 3 files changed, 135 insertions(+), 1 deletion(-)
```
Exactly the 3 files. ✓

## Scope confirmation
- No feature-module/design-system/domain/data/network/backend/schema/test changes.
- Sign-in/wizard/detail behavior, POST_NOTIFICATIONS logic, start-destination logic, and all
  existing route strings untouched.
- Only the catalog-existing icons-extended dep added; `android/.kotlin/` left untracked.

## Note for the planner
Device APK not rebuilt (not requested). For the W1 stage-exit device review, rebuild with the
LAN `-P` overrides as before.
