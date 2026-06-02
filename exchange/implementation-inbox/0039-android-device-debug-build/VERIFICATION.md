# VERIFICATION — handoff 0039-android-device-debug-build

Gate: default unit tests + device-APK build with `-P` + APK inspection. Drive mounted.

## (a) Default (emulator) build unaffected
```
$ ./gradlew :data:testDebugUnitTest :feature-inventory:testDebugUnitTest
BUILD SUCCESSFUL
```
`:data` (15) + `:feature-inventory` (22) unit tests green — the BuildConfig change is
behaviour-neutral for tests (defaults compile in; nothing asserts on the URL value).

## (b) Device-ready APK with LAN IP via -P
```
$ ./gradlew :app:assembleDebug -Pplantapp.apiBaseUrl=http://10.0.0.179:3000/ -Pplantapp.authBaseUrl=http://10.0.0.179:54321/
BUILD SUCCESSFUL
$ ls -la app/build/outputs/apk/debug/app-debug.apk
12,299,519 bytes — mtime 2026-06-02 09:54:42.957 -0700
```

## (c) Baked into THIS apk
- `aapt2 dump xmltree … AndroidManifest.xml` → `networkSecurityConfig=@0x7f0e0000` (**present**).
- `unzip -p app-debug.apk classes*.dex | strings | grep -c 10.0.0.179:3000` → **2** (the `-P` value
  compiled into `BuildConfig.API_BASE_URL`).
- `aapt2 dump permissions` → `android.permission.POST_NOTIFICATIONS` (present).

## Scope / integrity
- `git show --stat HEAD`: 4 files, +27 −9 — only `android/data/build.gradle.kts`,
  `android/data/.../di/DataModule.kt`, `android/app/src/debug/{AndroidManifest.xml,res/xml/network_security_config.xml}`.
  No `:network`/`:domain`/`:feature-inventory` logic change. Release behaviour unchanged (cleartext
  debug-only).
- **No committed host IP**: `git show HEAD | grep -c 10.0.0.179` → 0. The only on-disk occurrence is
  `android/data/build/generated/.../BuildConfig.java` — git-ignored (`git check-ignore` confirms).
- **No apk committed** (`git show --stat | grep -c .apk` → 0). `local.properties` not committed.

## Final repo state
- origin/master = `a3cb50e4d82020d9716c151180c628f92d61e6b8`; local == origin.
- Device APK (uncommitted, for install): `android/app/build/outputs/apk/debug/app-debug.apk`,
  mtime `2026-06-02 09:54:42 -0700`.
