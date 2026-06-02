# Next Implementation Prompt — Android device-debug build (LAN base URLs + cleartext)

**On-device full-stack enablement, step 2 of 2 (Android).** Make the app reach a **LAN-hosted**
backend from a real phone: (a) the two base URLs must be **build-overridable** (and the PlantApp
API base must point at **Fastify**, not Supabase — it is currently mis-set to `:54321`), and (b) a
**debug-only** `network-security-config` must permit cleartext to the LAN host (the device blocker
was `CLEARTEXT … not permitted`, *before* any socket). Release builds are untouched. No
host-specific IP is committed — the device IP is passed at build time via Gradle properties.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`e95c40ee0712d8e57d667f07f33d5974f99323bd` == `origin/master`, clean. `backend/src/server.ts` now
serves the Fastify API on `:3000` (`0038`). Android `:data` `di/DataModule.kt` has
`DEFAULT_BASE_URL = "http://10.0.2.2:54321/"` (used for **PlantAppApi** — wrong port; the
`/plants…` routes are Fastify) and `DEFAULT_AUTH_BASE_URL = "http://10.0.2.2:54321/"` +
`DEFAULT_ANON_KEY` (used for **SupabaseAuthApi**, correct host:port). `providePlantAppApi` uses
`settings.baseUrlBlocking(DEFAULT_BASE_URL)`; `provideSupabaseAuthApi` uses
`DEFAULT_AUTH_BASE_URL`/`DEFAULT_ANON_KEY`. `:data` is an `android.library` (no `buildConfig`
feature yet). `:app/src/main/AndroidManifest.xml` declares no `networkSecurityConfig`; there is no
`:app/src/debug/` sourceset. Device under test is Android 16 (cleartext blocked by default).

Single logical change (device-targetable base-URL config + debug cleartext) → one commit.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Make the base
URLs build-overridable (API→Fastify, auth→Supabase) and add a debug cleartext network config.
**Consult the Android `network-security-config` + AGP `buildConfigField` docs.**

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect e95c40ee0712d8e57d667f07f33d5974f99323bd == origin/master
git status --short                          # expect empty (git-ignored android/local.properties may exist)
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (Drive mounted)
```

### Scope
1. **`android/data/build.gradle.kts`** — enable BuildConfig + add two overridable fields (defaults
   are the **emulator** values; the API default is corrected to the Fastify port `:3000`):
   ```kotlin
   android {
     buildFeatures { buildConfig = true }
     defaultConfig {
       // ... existing ...
       val apiBase  = (project.findProperty("plantapp.apiBaseUrl")  as String?) ?: "http://10.0.2.2:3000/"
       val authBase = (project.findProperty("plantapp.authBaseUrl") as String?) ?: "http://10.0.2.2:54321/"
       buildConfigField("String", "API_BASE_URL",  "\"$apiBase\"")
       buildConfigField("String", "AUTH_BASE_URL", "\"$authBase\"")
     }
   }
   ```
2. **`android/data/.../di/DataModule.kt`** — use the BuildConfig values (keep the runtime
   `SettingsStore` override for the API base):
   - `providePlantAppApi`: `baseUrl = settings.baseUrlBlocking(dev.plantapp.data.BuildConfig.API_BASE_URL)`.
   - `provideSupabaseAuthApi`: `authBaseUrl = dev.plantapp.data.BuildConfig.AUTH_BASE_URL` (keep
     `DEFAULT_ANON_KEY` as-is). Remove the now-unused `DEFAULT_BASE_URL`/`DEFAULT_AUTH_BASE_URL`
     consts (or leave `DEFAULT_ANON_KEY`). Import `dev.plantapp.data.BuildConfig`.
3. **`android/app/src/debug/res/xml/network_security_config.xml`** (new) — permit cleartext for
   **debug** builds (dev/LAN HTTP):
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <network-security-config>
       <base-config cleartextTrafficPermitted="true" />
   </network-security-config>
   ```
4. **`android/app/src/debug/AndroidManifest.xml`** (new) — debug overlay that points the app at it
   (merges over main for debug only; release stays default-secure):
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <manifest xmlns:android="http://schemas.android.com/apk/res/android">
       <application android:networkSecurityConfig="@xml/network_security_config" />
   </manifest>
   ```

### Forbidden
- No `:network`/`:domain`/`:feature-inventory` logic change (only `:data` DI + build config + the
  `:app` debug sourceset). No change to release behavior (cleartext stays **debug-only**). No
  committed host-specific IP (the `10.0.0.179` device value is passed via `-P` at build time only —
  never written into a committed file). No Firebase/FCM. No new dependency. Don't mount/repoint the
  SDK/Drive; don't commit `android/local.properties`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
# (a) default (emulator) build still compiles + tests pass:
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :data:testDebugUnitTest :feature-inventory:testDebugUnitTest
# (b) DEVICE-READY build with the LAN IP injected via -P (this APK is what gets installed on the phone):
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug \
  -Pplantapp.apiBaseUrl=http://10.0.0.179:3000/ -Pplantapp.authBaseUrl=http://10.0.0.179:54321/
ls -la app/build/outputs/apk/debug/app-debug.apk
# (c) confirm the LAN URLs + cleartext config are actually baked into THIS apk:
"$ANDROID_HOME"/build-tools/*/aapt2 dump xmltree --file AndroidManifest.xml app/build/outputs/apk/debug/app-debug.apk 2>/dev/null | grep -i networkSecurityConfig || echo "(check NSC present)"
unzip -p app/build/outputs/apk/debug/app-debug.apk classes*.dex >/dev/null 2>&1 && echo "apk built"
```
Expected: unit tests green (BuildConfig change is behavior-neutral for tests); `app-debug.apk`
produced; the manifest references `networkSecurityConfig`. **Report the exact APK path + mtime** so
the planner installs that artifact. (Optionally `strings` the apk for `10.0.0.179` to confirm the
`-P` values baked in.)

### Commit + push (source only — NOT the apk)
```bash
git -C /home/israel/Documents/Development/PlantApp add android/data/build.gradle.kts android/data/src/main/kotlin/dev/plantapp/data/di/DataModule.kt android/app/src/debug/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android): build-overridable base URLs (API->Fastify) + debug cleartext network config"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The BuildConfig fields (defaults + `-P` overrides; API corrected to `:3000`), the DataModule
   change, and the debug-only NSC + manifest overlay.
2. Verification: unit tests green; the **device APK path + mtime** (built with the LAN `-P`); NSC
   present in the apk manifest.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only `:data` build/DI +
   `android/app/src/debug/**` changed; confirm **no** committed host IP and **no** apk committed.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `:data` build/DI + `:app/src/debug/**`; no committed IP/apk; tests green;
device APK produced). **Then step 3 (planner runs the LAN stack + re-test):** start local Supabase +
the Fastify server bound to the LAN (`HOST=0.0.0.0 PORT=3000`, env from `supabase status`); **ask
the owner to open `ufw` 54321 + 3000 to the LAN (sudo)**; `adb install -r` the device APK; re-run the
device agent suite (`reviews/device-test-suite.md`) for the real sign-in → add-plant → reminder
journey, capturing exhaustive evidence. (FCM remains a separate owner-gated step.)
