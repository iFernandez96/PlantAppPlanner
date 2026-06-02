# DONE — handoff 0040-android-internet-permission (on-device defect fix)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** declared `android.permission.INTERNET` in the main manifest — the app talks to Supabase
(auth) + the Fastify API over the network, but the permission was never declared, so on a real
device the OS denied the process any socket (`SocketException: EPERM` on the first
`POST /auth/v1/otp`). It's an install-time permission and belongs in `src/main` (release needs it
too). Device APK rebuilt with INTERNET present. Final `origin/master` =
`786c12defcd930bf14fc363447f36e426ea8913b`.

## Baseline + unblock
- HEAD at start = `a3cb50e…` == origin/master; clean. INTERNET absent from the main manifest
  (grep 0), as the prompt stated.

## The fix (one line) — `android/app/src/main/AndroidManifest.xml`
```diff
 <manifest xmlns:android="http://schemas.android.com/apk/res/android">
 
+    <!-- The app talks to Supabase (auth) + the Fastify API over the network. -->
+    <uses-permission android:name="android.permission.INTERNET" />
+
     <!-- Slice 3: local watering reminders post a notification (Android 13+ requires this at runtime). -->
     <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```
Nothing else changed — not `<application>`, not the activity, not the `0039` debug sourceset/NSC.

## Verification (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug \
    -Pplantapp.apiBaseUrl=http://10.0.0.179:3000/ -Pplantapp.authBaseUrl=http://10.0.0.179:54321/
  → BUILD SUCCESSFUL
$ aapt2 dump permissions app/build/outputs/apk/debug/app-debug.apk | grep INTERNET
  → uses-permission: name='android.permission.INTERNET'      # now present
```
- `assembleDebug` succeeds; the built apk now lists `android.permission.INTERNET`.
- **Device APK:** `android/app/build/outputs/apk/debug/app-debug.apk`
  **mtime `2026-06-02 10:11:06 -0700`** (12,299,519 bytes), built with the LAN `-P` (so the
  `10.0.0.179` API/auth URLs + the debug cleartext NSC from `0039` are still baked in). This is the
  artifact to `adb install -r`.
- Why no test caught it: no unit/integration/Robolectric test opens a real socket; only the device
  run surfaced the EPERM. (This handoff is a manifest fix — no unit-test change needed.)

## Commit
- `786c12d` — fix(android): declare INTERNET permission (app networking failed with EPERM on-device)
- `git show --stat HEAD`: 1 file, +3 — only `android/app/src/main/AndroidManifest.xml`.
  No apk committed (grep 0). `local.properties` not committed (grep 0).

## Compliance
- No other manifest/permission change. No `:data`/`:network`/`:domain`/`:feature-inventory`/backend
  change. No new dependency. No base-URL/NSC change (those were `0039`). SDK/Drive untouched.

Final `origin/master` SHA: `786c12defcd930bf14fc363447f36e426ea8913b`

## Device APK for the planner to reinstall
`android/app/build/outputs/apk/debug/app-debug.apk` (mtime `2026-06-02 10:11:06 -0700`), built with
`-Pplantapp.apiBaseUrl=http://10.0.0.179:3000/ -Pplantapp.authBaseUrl=http://10.0.0.179:54321/`.

## Next (per planner follow-up)
Planner `adb install -r`s the new APK and re-runs the device suite (OTP → Mailpit code → verify →
list → add-plant → CareTask/advisories → accept → reminder fires) against the still-up LAN backend,
then tears down (re-close ufw, stop Fastify). FCM remains a separate owner-gated step.
