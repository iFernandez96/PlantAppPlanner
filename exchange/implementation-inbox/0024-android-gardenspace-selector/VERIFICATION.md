# VERIFICATION — handoff 0024-android-gardenspace-selector (3b-ui-b, red→green)

Gate: `:feature-inventory:testDebugUnitTest` + `:app:assembleDebug`, Drive mounted.

## RED driver
`#22`/`#24` typed into `FIELD_GARDEN_SPACE_ID`, which is replaced by the
`FIELD_GARDEN_SPACE_SELECTOR` select-or-create control — so they were moved to the
selector path; the new selector/tags don't exist before the change.

## GREEN
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL
# InventoryScreensTest        tests="7" failures="0" errors="0"
# PlantDetailAdvisoriesTest   tests="2" failures="0" errors="0"
# :app:assembleDebug          SUCCESSFUL (app-debug.apk ~11.3 MB)
```
- `#22` picks profile + "West Balcony" → `submitted.gardenSpaceId == "…003"`.
- `#24` picks profile + space, container blank → error, no submit.
- `garden-space selector lists existing spaces` → "West Balcony" + "East Patio" present.
- `garden-space create path invokes callback` → create item → name+kind → button →
  spy received `("North Ledge","window-ledge")`.
- profile dropdown test + `#21`/`#23` still green.

Mid-run fix: the auto-select placed the last space ("East Patio") into the anchor, so
`onNodeWithText("East Patio")` matched 2 nodes; the "lists existing spaces" test now uses
`onAllNodesWithText(...).onFirst()`.

## Scope / integrity
- Only `android/feature-inventory/**` + `android/app/**` changed (`git show --stat`:
  5 files, +144/−11). No `:network`/`:data`/`:domain`/backend/schema change. No new deps.
  Container field unchanged (3b-ui-c). `local.properties` not committed (grep 0).

## Final repo state
- origin/master = `5ce6f29cc14a0fb1946dece9b4ff9432e29f2b68`; local == origin.
- Working tree clean except git-ignored `android/local.properties`.
