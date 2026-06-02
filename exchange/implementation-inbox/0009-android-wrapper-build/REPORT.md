# DONE — handoff 0009-android-wrapper-build (a1)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** Gradle wrapper generated + committed; the 6-module Android skeleton assembles
(`:app:assembleDebug` → BUILD SUCCESSFUL, debug APK produced). No product/feature code,
no forbidden deps.
Final `origin/master` = `d0ec682b1d3e086ea8d7d35d61a404a74dd45f21`.

## Baseline precondition — matched
- HEAD = `603869e6cf111957083042ce2b2dd4ce6ec2e1cf` == origin/master; clean.
- `ANDROID_HOME=/home/israel/Android/Sdk`; platforms `android-34/36/36.1`; Java 21; no
  system `gradle`; wrapper not committed.

## 1. How Gradle was provided
System `gradle` absent. Downloaded the distribution named in
`android/gradle/wrapper/gradle-wrapper.properties` (`gradle-8.11.1-bin.zip`) from
`services.gradle.org` to `/tmp`, unzipped it, and used that one-off `gradle` to generate
the wrapper:
```
cd android && /tmp/gradle-8.11.1/bin/gradle wrapper --gradle-version 8.11.1 --distribution-type bin
```
Committed wrapper files: `android/gradlew`, `android/gradlew.bat`,
`android/gradle/wrapper/gradle-wrapper.jar` (none git-ignored).

## 2. SDK components installed + compileSdk
The app's `compileSdk`/`targetSdk` is **35**, but only `android-34/36/36.1` were present.
Installed the matching platform via the SDK's `sdkmanager` (licenses auto-accepted),
keeping the pinned config intact rather than changing `compileSdk`:
```
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platforms;android-35"
```
`build-tools;35.0.0` was already installed. No other components needed.

## 3. Minimal Gradle/version fixes
**None.** The existing `libs.versions.toml` stack (AGP 8.7.3, Kotlin 2.1.0, KSP
2.1.0-1.0.29, Compose BOM 2024.12.01, Hilt/Room/Retrofit) and the six module build files
assembled unchanged. No commit 2 was necessary.

## 4. Build result + commits
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug --console=plain --no-daemon
...
BUILD SUCCESSFUL in 5m 10s
106 actionable tasks: 101 executed, 5 from cache
```
Produced `android/app/build/outputs/apk/debug/app-debug.apk` (~11.3 MB). The feature
modules show `NO-SOURCE` for Kotlin/KSP (empty skeleton, as intended) — the app still
packages, proving toolchain + wrapper + module wiring.

Commit:
- `d0ec682` — chore(android): generate Gradle wrapper (`gradlew`, `gradlew.bat`,
  `gradle/wrapper/gradle-wrapper.jar`; +346 lines / 43 KB jar).

Final `origin/master` SHA: `d0ec682b1d3e086ea8d7d35d61a404a74dd45f21`.

## 5. Compliance
- No feature code added (modules remain empty `.gitkeep` skeletons; all feature-module
  Kotlin tasks were `NO-SOURCE`).
- No forbidden deps: no CameraX, Firebase/FCM, WorkManager, AI/LLM SDK, or `:care-engine`
  Android module. The 6-module set (`:app`, `:design-system`, `:domain`, `:data`,
  `:network`, `:feature-inventory`) is unchanged.
- `backend/**`, `shared-schemas/**`, `supabase/**` untouched.
- `android/local.properties` (not created — AGP used `ANDROID_HOME`), `android/.gradle/`,
  and `android/**/build/` are git-ignored and were not committed. Working tree clean.

## Environment notes (mechanical, for the planner / a2)
Two host-specific workarounds were required, neither changing repo files:
- **`~/.gradle` is a symlink to a slow external Drive** (`/media/israel/Drive/Linux/gradle`).
  A first `./gradlew` invocation stalled downloading the dist there and held a lock,
  which made a concurrent `assembleDebug` time out. Resolved by killing the stuck
  wrapper/daemon and running gradlew with **`GRADLE_USER_HOME=/tmp/plantapp-gradle-home`**
  (local SSD). Recommend a2 use the same `GRADLE_USER_HOME` and avoid concurrent gradlew
  runs. (Same Drive root-cause as the earlier `npm_config_cache=/tmp/...` npx workaround.)
- `platforms;android-35` had to be installed (done).

## Next (a2, per planner follow-up)
Slice 1 Compose screens in `:feature-inventory` (add-plant form, list, detail showing the
water task) wired to `:network` Retrofit DTOs for the backend `/plants` API, with Compose
UI tests #21–#24 — prefer Robolectric (JVM) to avoid an emulator. Decompose: DTOs/network
→ screens → tests.
