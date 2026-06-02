# VERIFICATION — handoff 0023-android-profile-dropdown (3b-ui-a, red→green)

Gate: `:feature-inventory:testDebugUnitTest` + `:app:assembleDebug`, Drive mounted.

## RED driver
The existing `#22`/`#24` typed into `FIELD_PROFILE_ID`, which is removed/replaced by the
dropdown — so they were updated to the dropdown selection path (open
`FIELD_PROFILE_SELECTOR`, click "Tomato"); before the screen/VM changes those references
don't exist.

## GREEN
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 1m 28s
# InventoryScreensTest        tests="5" failures="0" errors="0"
# PlantDetailAdvisoriesTest   tests="2" failures="0" errors="0"
# :app:assembleDebug          SUCCESSFUL
```
- `#22` selects "Tomato" from the dropdown → `submitted.profileId == "solanum-lycopersicum"`.
- `#24` selects a profile but leaves container blank → container error shown, no submit.
- new `add-plant profile dropdown lists catalog profiles` → "Tomato" + "Basil" displayed.
- `#21`/`#23` unchanged and green.
- `:app:assembleDebug` confirms the `AddPlantScreen(profiles=…)` route wiring + the
  `AddPlantViewModel.profiles` load type-check.

## Scope / integrity
- Only `android/feature-inventory/**` + `android/app/**` changed (`git show --stat`:
  5 files, +86/−10). No `:network`/`:data`/`:domain`/backend/schema change. No new deps.
  Garden-space/container/growth fields unchanged (3b-ui-b). `local.properties` not
  committed (grep 0).

## Final repo state
- origin/master = `20f4e354486f79d93e21bdbacbec24ff9d4ae7c3`; local == origin.
- Working tree clean except git-ignored `android/local.properties`.
