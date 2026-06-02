# DONE — handoff 0037-post-notifications-permission (Slice 3 step 4, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** the app now requests the `POST_NOTIFICATIONS` runtime permission (Android 13+/API 33+)
once on the plant-list route, so scheduled local reminders can show. Below API 33 it's
install-granted (no prompt). Still local-only — **no Firebase/FCM**. `:feature-inventory` tests
green; `:app:assembleDebug` OK. **This completes the LOCAL Slice 3 reminder path.** Final
`origin/master` = `369f2f06dcc6bc8019cf051b40228e01a0746b89`.

## Baseline + unblock
- HEAD at start = `e8aaeec…` == origin/master; clean. SDK resolves. Manifest already declares
  `POST_NOTIFICATIONS` (from 0035).

## What was added
1. **`:feature-inventory` `NotificationPermission.kt`** (new) — pure, Android-free decision:
   `object NotificationPermission { fun shouldRequest(sdkInt: Int, granted: Boolean) = sdkInt >= 33
   && !granted }`. JVM-testable.
2. **`:app` `MainActivity.kt`** — in `composable(Routes.LIST)`:
   - `val context = LocalContext.current`
   - `val launcher = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission())
     {}` (no-op callback — the Worker guards on the live permission, so we don't branch on the
     result).
   - `LaunchedEffect(Unit) { val granted = ContextCompat.checkSelfPermission(context,
     Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED; if
     (NotificationPermission.shouldRequest(Build.VERSION.SDK_INT, granted))
     launcher.launch(Manifest.permission.POST_NOTIFICATIONS) }`
   - Added the required imports (`android.Manifest`, `PackageManager`, `Build`,
     `rememberLauncherForActivityResult`, `ActivityResultContracts`, `LocalContext`,
     `ContextCompat`, `NotificationPermission`). LIST's `PlantListScreen` + other routes unchanged.

## Tests (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 19s
```
- **`NotificationPermissionTest`** (new): 4 tests — sdk 32 → false (both granted values);
  sdk 33 + not granted → true; sdk 33 + granted → false; sdk 34 + not granted → true.
- `:feature-inventory` total **18 → 22** (NotificationPermissionTest 4, InventoryScreensTest 9,
  NavSmokeTest 2, PlantDetailAdvisoriesTest 4, SignInScreenTest 3). All green.
- **`:app:assembleDebug` BUILD SUCCESSFUL** (launcher + permission-check wiring type-checks).
- The actual system dialog only appears on a real 33+ device/emulator (out of scope for the unit
  gate, which proves the decision helper + compile/wire).

## Implementation note
The test was first written with `kotlin.test.*`, which `:feature-inventory` (JUnit4 only — no
`kotlin-test-junit` dep) doesn't resolve; switched to `org.junit.Test` / `org.junit.Assert.assertEquals`
(matching the module's other tests). No production change.

## Commit
- `369f2f0` — feat(android): request POST_NOTIFICATIONS at runtime for local reminders (Slice 3)
- `git show --stat HEAD`: 3 files, +59 — only `android/feature-inventory/**` (NotificationPermission
  + its test) + `android/app/**` (MainActivity). `local.properties` NOT committed (grep 0).

## Compliance
- **No Firebase/FCM/`google-services`** (grep clean). No new permission (manifest already had it).
  No new dependency. No other route/screen change. No change to the scheduler/worker/`ReminderSync`.
  No camera/photos/GPS/AI. SDK/Drive untouched.

Final `origin/master` SHA: `369f2f06dcc6bc8019cf051b40228e01a0746b89`

## Status — LOCAL Slice 3 reminder path COMPLETE
Deterministic policy (`computeReminders`) → WorkManager local scheduling (`ReminderScheduler` +
`ReminderWorker`) → app-open sync (`ReminderSync`) → runtime `POST_NOTIFICATIONS` request.

## Next — FCM STOP gate (owner)
This is the planner's STOP point: server-triggered push needs a Firebase project +
`google-services.json` and the owner's go-ahead before any FCM handoff. Owner can also manually
verify on a 33+ device: run the app, grant the permission, confirm a reminder fires for a due task.
