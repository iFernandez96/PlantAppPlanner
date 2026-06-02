# VERIFICATION — handoff 0043-wizard-sourced-icons

Gate: `:feature-inventory:testDebugUnitTest :app:assembleDebug`, Drive mounted. Icon swap is a
presentation change (no red-first test); the wizard's existing behavioural tests are the guard.

## GREEN
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL
```
- `:feature-inventory` 20 tests, all pass (AddPlantWizardTest 2, AddPlantWizardModelTest 3,
  InventoryScreensTest 2, NavSmokeTest 2, NotificationPermissionTest 4, PlantDetailAdvisoriesTest 4,
  SignInScreenTest 3). No test referenced the old `ic_*` resource ids, so no test edits were needed;
  the wizard behavioural assertions (tile tags, callbacks, resolved form) stand unchanged.
- `:app:assembleDebug` — **BUILD SUCCESSFUL** with `material-icons-extended` on the classpath.

## Icon integrity
- Species drawables carry real per-path `android:fillColor` (8/22/37/6/9/9 for
  tomato/basil/strawberry/tomatillo/default/passionfruit) — they render in colour, not as black
  silhouettes (the bug a naive convert would have caused).
- Pots use **distinct** Material glyphs: small pots `LocalFlorist`, bucket `Compost`, window box
  `Window`, raised bed `Grass` — the six options are no longer identical.
- No emoji (`grep -P` over src → none). No raster/PNG — vectors only.

## Scope / integrity
- `git show --stat HEAD`: 16 files, +369 −126 — only `android/feature-inventory/**` (6 species
  drawables, 5 placeholder drawables deleted, WizardIcons, AddPlantWizard, build.gradle,
  ICON_LICENSES.md) + `android/gradle/libs.versions.toml`. No `:network`/`:data`/`:domain`/backend/
  schema change.
- No apk committed, no raster committed, no `local.properties` committed (grep 0/0/0).
- `ICON_LICENSES.md` at the module root (not `res/drawable/`, which would break AAPT).

## Device APK (uncommitted, for owner review)
`android/app/build/outputs/apk/debug/app-debug.apk`, mtime `2026-06-02 13:20:00 -0700` (18.7 MB),
built with the LAN `-P` URLs.

## Final repo state
- origin/master = `c485afc52f3e687c138ec4ac106dae7e1d7a237e`; local == origin.
- Working tree clean except git-ignored build output (`android/.kotlin/`, `build/`) +
  `android/local.properties`.
