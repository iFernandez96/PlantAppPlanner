# Next Implementation Prompt — fix: declare `android.permission.INTERNET` (real on-device bug)

**On-device defect found by the real full-stack run.** The app's Android manifest **never declares
`android.permission.INTERNET`**, so on a real device the OS denies the process any network socket:
the very first backend call (`POST /auth/v1/otp`) fails instantly with `java.net.SocketException:
socket failed: EPERM (Operation not permitted)`. **No** unit/integration/Robolectric test caught
this (none open a real socket); only the device run did. INTERNET is a normal install-time
permission — it belongs in **`src/main`** (release needs it too, not just debug).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`a3cb50e4d82020d9716c151180c628f92d61e6b8` == `origin/master`, clean. `android/app/src/main/
AndroidManifest.xml` declares **no `<uses-permission>`** (the merged APK has POST_NOTIFICATIONS +
WorkManager's FOREGROUND_SERVICE/RECEIVE_BOOT_COMPLETED/WAKE_LOCK/ACCESS_NETWORK_STATE, but **not
INTERNET** — confirmed on-device via `dumpsys package`). The app talks to Supabase (auth) + the
Fastify API over HTTP, so INTERNET is required.

Single logical change (declare the INTERNET permission) → one commit.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Declare the
INTERNET permission the app has always needed.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect a3cb50e4d82020d9716c151180c628f92d61e6b8 == origin/master
git status --short                         # expect empty (git-ignored android/local.properties may exist)
grep -c 'android.permission.INTERNET' android/app/src/main/AndroidManifest.xml   # expect 0 (absent)
```

### Scope — one line in the main manifest
**`android/app/src/main/AndroidManifest.xml`** — add, as a child of `<manifest>` and **before**
`<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```
(Place it alongside where other top-level `<uses-permission>` would go. Do not change anything
else — not the `<application>`, not the activity, not the debug sourceset/NSC from `0039`.)

### Forbidden
- No other manifest/permission change. No `:data`/`:network`/`:domain`/`:feature-inventory`/backend
  change. No new dependency. No base-URL/NSC change (those are `0039`). Don't mount/repoint the
  SDK/Drive; don't commit `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
# default build compiles + tests still green:
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug
# rebuild the DEVICE-READY apk (same LAN -P as 0039) so it's ready to reinstall:
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug \
  -Pplantapp.apiBaseUrl=http://10.0.0.179:3000/ -Pplantapp.authBaseUrl=http://10.0.0.179:54321/
# confirm INTERNET is now in the built apk:
"$ANDROID_HOME"/build-tools/*/aapt2 dump permissions app/build/outputs/apk/debug/app-debug.apk 2>/dev/null | grep INTERNET || echo "INTERNET still missing!"
ls -la app/build/outputs/apk/debug/app-debug.apk   # report path + mtime
```
Expected: `assembleDebug` succeeds; `aapt2 dump permissions` now lists
`android.permission.INTERNET`. **Report the APK path + mtime** so the planner reinstalls it. (No
unit-test change needed; this is a manifest fix. Optionally run `:feature-inventory:testDebugUnitTest`
to confirm no regression.)

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/app/src/main/AndroidManifest.xml
git -C /home/israel/Documents/Development/PlantApp commit -m "fix(android): declare INTERNET permission (app networking failed with EPERM on-device)"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The one-line addition (show the manifest diff).
2. Verification: `assembleDebug` OK; `aapt2 dump permissions` now includes `android.permission.INTERNET`;
   the **device APK path + mtime** (built with the LAN `-P`).
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/app/src/main/AndroidManifest.xml` changed (not `local.properties`, no apk committed).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only the main manifest; `aapt2` shows INTERNET; device APK rebuilt). Then the
planner reinstalls the new APK (`adb install -r`) and **re-runs the device agent suite from Step 2**
(request OTP → Mailpit code → verify → list → add-plant via selectors → CareTask + advisories →
accept → reminder fires), capturing exhaustive evidence — the backend (Supabase + Fastify on the
LAN) is still up and `ufw` is open. Tear down afterward (re-close ufw, stop Fastify `bhdrygzdg`).
FCM remains a separate owner-gated step.
