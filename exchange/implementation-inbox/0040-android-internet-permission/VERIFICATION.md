# VERIFICATION — handoff 0040-android-internet-permission

Gate: device-APK build + `aapt2` permission inspection. Drive mounted. Manifest fix — no unit-test
change needed.

## Defect
On a real device the app had no `android.permission.INTERNET`, so the OS denied the process any
socket: first backend call (`POST /auth/v1/otp`) → `SocketException: EPERM (Operation not
permitted)`. No unit/integration/Robolectric test opens a real socket, so none caught it; only the
device run did.

## Fix + GREEN
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug \
    -Pplantapp.apiBaseUrl=http://10.0.0.179:3000/ -Pplantapp.authBaseUrl=http://10.0.0.179:54321/
BUILD SUCCESSFUL
$ aapt2 dump permissions app/build/outputs/apk/debug/app-debug.apk | grep INTERNET
uses-permission: name='android.permission.INTERNET'     # present (was absent)
```
- Device APK: `app/build/outputs/apk/debug/app-debug.apk`, mtime `2026-06-02 10:11:06 -0700`
  (12,299,519 bytes) — built with the LAN `-P`, so the `0039` API/auth URLs + debug cleartext NSC
  remain baked in.

## Scope / integrity
- `git show --stat HEAD`: 1 file, +3 — only `android/app/src/main/AndroidManifest.xml` (the single
  `<uses-permission android:name="android.permission.INTERNET" />` line). No other manifest/permission
  change, no module/backend change, no dependency, no base-URL/NSC change.
- No apk committed (grep 0). `local.properties` not committed (grep 0).

## Final repo state
- origin/master = `786c12defcd930bf14fc363447f36e426ea8913b`; local == origin.
- Device APK (uncommitted, for reinstall): `android/app/build/outputs/apk/debug/app-debug.apk`,
  mtime `2026-06-02 10:11:06 -0700`.
