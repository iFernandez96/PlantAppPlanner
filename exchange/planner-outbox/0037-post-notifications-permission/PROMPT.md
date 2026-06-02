# Next Implementation Prompt — Slice 3 (runtime permission): request `POST_NOTIFICATIONS`

**Slice 3, step 4 — the last LOCAL step.** Request the `POST_NOTIFICATIONS` runtime permission
(Android 13+ / API 33+) after sign-in, so the scheduled local reminders (`0035`/`0036`) can actually
show. On API < 33 it's auto-granted (no prompt). **Still local-only — no Firebase/FCM.** After this
lands, the planner **STOPs and asks the owner for Firebase/FCM setup** before any push.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`e8aaeec50c0f1cb1114b3dc1b8186654d7fae091` == `origin/master`, clean. `:app`
`MainActivity.kt` has `PlantAppNavHost` with `composable(Routes.LIST){ … PlantListScreen(state,
onAddClick, onPlantClick) }`; `:app` already depends on `androidx.activity.compose` (it uses
`setContent`). The manifest already declares `<uses-permission
android:name="android.permission.POST_NOTIFICATIONS" />` (from `0035`). `:feature-inventory` has the
Robolectric/JVM unit-test setup (`@Config(sdk=[34])`). `minSdk = 26`.

Single logical change (the runtime-permission request + a pure decision helper) → one commit.
Red-first.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the runtime
`POST_NOTIFICATIONS` request. **Consult the Activity Result API (`RequestPermission`) + Compose
`rememberLauncherForActivityResult` docs.** Red-first: write the helper test first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect e8aaeec50c0f1cb1114b3dc1b8186654d7fae091 == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`:feature-inventory` `.../NotificationPermission.kt`** (new) — a pure, Android-free decision
   helper (testable on the JVM):
   ```kotlin
   object NotificationPermission {
       /** Android 13+ (API 33) gates POST_NOTIFICATIONS behind a runtime grant; below that it is
        *  granted at install. Request only when on 33+ AND not already granted. */
       fun shouldRequest(sdkInt: Int, granted: Boolean): Boolean = sdkInt >= 33 && !granted
   }
   ```
2. **`:app` `MainActivity.kt`** — in the `composable(Routes.LIST)` block, request the permission
   once when appropriate:
   - `val context = LocalContext.current`
   - `val launcher = rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission()) {}`
     (no-op callback — the Worker already guards on the live permission; we don't branch on the
     result here).
   - `LaunchedEffect(Unit) { val granted = ContextCompat.checkSelfPermission(context,
     Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED; if
     (NotificationPermission.shouldRequest(Build.VERSION.SDK_INT, granted))
     launcher.launch(Manifest.permission.POST_NOTIFICATIONS) }`
   - Add imports: `android.Manifest`, `android.content.pm.PackageManager`, `android.os.Build`,
     `androidx.activity.compose.rememberLauncherForActivityResult`,
     `androidx.activity.result.contract.ActivityResultContracts`,
     `androidx.compose.ui.platform.LocalContext`, `androidx.core.content.ContextCompat`,
     `dev.plantapp.feature.inventory.NotificationPermission`.
   Leave the rest of the LIST composable + the other routes unchanged. (`androidx.core` /
   `androidx.activity.compose` are already available to `:app`; if `ContextCompat` needs
   `androidx.core:core-ktx`, it is already an `:app` dependency.)

### Tests — `:feature-inventory` `.../NotificationPermissionTest.kt` (new, plain JUnit)
- `sdk 32 → false` (auto-granted below 33, regardless of `granted`).
- `sdk 33 + not granted → true`.
- `sdk 33 + granted → false`.
- `sdk 34 + not granted → true`.

### Forbidden
- **No Firebase/FCM/`google-services`.** No new permission (the manifest already has
  `POST_NOTIFICATIONS`). No new dependency. No other route/screen change. No change to the
  scheduler/worker/`ReminderSync`. No camera/photos/GPS/AI. Don't mount/repoint the SDK/Drive; don't
  commit `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
```
Red→green: `NotificationPermissionTest` fails before the helper exists; after, `:feature-inventory`
unit tests pass (new helper test green; prior green) and `:app:assembleDebug` compiles (the launcher
+ permission-check wiring type-checks). Report counts + new test name + assemble result. (The actual
system permission dialog only appears on a real 33+ device/emulator — out of scope for the unit
gate; the gate proves the decision helper + that it compiles/wires.)

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/feature-inventory/ android/app/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android): request POST_NOTIFICATIONS at runtime for local reminders (Slice 3)"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The `NotificationPermission.shouldRequest` helper + the `MainActivity` LIST-route launcher /
   `LaunchedEffect` wiring (request once on 33+ when not granted; no-op callback).
2. `:feature-inventory:testDebugUnitTest` count before→after + new test name; `:app:assembleDebug`
   result.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/feature-inventory/**` + `android/app/**` changed (not `local.properties`); confirm no
   FCM/google-services.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `:feature-inventory`+`:app`; helper + launcher wiring; tests green; assemble
OK; no FCM). **That completes the LOCAL Slice 3 reminder path** — deterministic policy →
WorkManager local scheduling → app-open sync → runtime permission. **The planner then STOPs and asks
the owner for Firebase/FCM setup** (a Firebase project + `google-services.json`, and confirmation to
proceed with server-triggered push) — the Slice 3 FCM gate. No push/FCM handoff is published until
the owner provides that. The planner will also note the **on-device manual check** the owner can do
(run the app on a 33+ device, grant the permission, confirm a reminder fires for a due task).
