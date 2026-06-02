# DONE — handoff 0039-android-device-debug-build

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** the Android base URLs are now **build-overridable** (PlantApp API default corrected to
the Fastify port `:3000`, auth to Supabase `:54321`), and a **debug-only** network-security-config
permits cleartext to a dev/LAN host. Release builds untouched; no host IP committed. Unit tests
green; a device-ready debug APK was produced with the LAN IP injected via `-P`. Final
`origin/master` = `a3cb50e4d82020d9716c151180c628f92d61e6b8`.

## Baseline + unblock
- HEAD at start = `e95c40e…` == origin/master; clean. SDK resolves.

## What was added
1. **`android/data/build.gradle.kts`** — `buildFeatures { buildConfig = true }`; in
   `defaultConfig`, two `-P`-overridable BuildConfig fields with **emulator** defaults:
   `API_BASE_URL` ← `plantapp.apiBaseUrl` (default `http://10.0.2.2:3000/` — **corrected to
   Fastify**), `AUTH_BASE_URL` ← `plantapp.authBaseUrl` (default `http://10.0.2.2:54321/`).
2. **`android/data/.../di/DataModule.kt`** — `providePlantAppApi` uses
   `settings.baseUrlBlocking(BuildConfig.API_BASE_URL)` (runtime `SettingsStore` override kept);
   `provideSupabaseAuthApi` uses `BuildConfig.AUTH_BASE_URL` (kept `DEFAULT_ANON_KEY`). Removed the
   now-unused `DEFAULT_BASE_URL`/`DEFAULT_AUTH_BASE_URL` consts; imported `dev.plantapp.data.BuildConfig`.
3. **`android/app/src/debug/res/xml/network_security_config.xml`** (new) — `<base-config
   cleartextTrafficPermitted="true" />` (debug only).
4. **`android/app/src/debug/AndroidManifest.xml`** (new) — debug overlay setting
   `android:networkSecurityConfig="@xml/network_security_config"` (merges over main for debug;
   release stays default-secure).

## Verification (the gate)
```
# (a) default (emulator) build still green:
$ ./gradlew :data:testDebugUnitTest :feature-inventory:testDebugUnitTest   → BUILD SUCCESSFUL
# (b) DEVICE-READY apk with the LAN IP injected via -P:
$ ./gradlew :app:assembleDebug -Pplantapp.apiBaseUrl=http://10.0.0.179:3000/ -Pplantapp.authBaseUrl=http://10.0.0.179:54321/
  → BUILD SUCCESSFUL
# (c) confirm baked into THIS apk:
$ aapt2 dump xmltree ... AndroidManifest.xml → networkSecurityConfig=@0x7f0e0000 (present)
$ unzip -p app-debug.apk classes*.dex | strings | grep -c 10.0.0.179:3000 → 2
$ aapt2 dump permissions → android.permission.POST_NOTIFICATIONS (present)
```
- Unit tests green (BuildConfig change is behaviour-neutral for tests).
- **Device APK:** `android/app/build/outputs/apk/debug/app-debug.apk`
  **mtime `2026-06-02 09:54:42 -0700`** (12,299,519 bytes). This is the artifact to `adb install -r`.
- `networkSecurityConfig` present in the apk manifest; the LAN URL `10.0.0.179:3000` is baked into
  the apk (2 occurrences, from the `-P` value compiled into BuildConfig); `POST_NOTIFICATIONS`
  declared.

## Commit (source only — not the apk)
- `a3cb50e` — feat(android): build-overridable base URLs (API->Fastify) + debug cleartext network config
- `git show --stat HEAD`: 4 files, +27 −9 — only `android/data/build.gradle.kts`,
  `android/data/.../di/DataModule.kt`, and `android/app/src/debug/**` (NSC + manifest overlay).
- **No committed host IP**: `git show HEAD | grep -c 10.0.0.179` → **0** (the only `10.0.0.179` on
  disk is in `android/data/build/generated/.../BuildConfig.java`, which is git-ignored — confirmed
  via `git check-ignore`). **No apk committed** (grep 0). `local.properties` not committed (grep 0).

## Compliance
- No `:network`/`:domain`/`:feature-inventory` logic change (only `:data` DI + build config + the
  `:app` debug sourceset). Release behaviour unchanged — cleartext is **debug-only**. No
  host-specific IP committed (LAN value passed via `-P` at build time). No Firebase/FCM. No new
  dependency. SDK/Drive untouched.

Final `origin/master` SHA: `a3cb50e4d82020d9716c151180c628f92d61e6b8`

## Device APK for the planner to install
`android/app/build/outputs/apk/debug/app-debug.apk` (mtime `2026-06-02 09:54:42 -0700`), built with
`-Pplantapp.apiBaseUrl=http://10.0.0.179:3000/ -Pplantapp.authBaseUrl=http://10.0.0.179:54321/`.

## Next (per planner follow-up)
Step 3 (planner runs the LAN stack + re-test): start local Supabase + `HOST=0.0.0.0 PORT=3000 npm
run start` (env from `supabase status`); **owner opens `ufw` 54321 + 3000 to the LAN (sudo)**;
`adb install -r` the device APK; re-run the device suite for sign-in → add-plant → reminder. (FCM
remains a separate owner-gated step.)
