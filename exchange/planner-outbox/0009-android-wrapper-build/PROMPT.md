# Next Implementation Prompt — a1: generate Gradle wrapper + build the Android skeleton

**Milestone a (Android UI #21–#24), step a1.** De-risk the Android toolchain first:
generate the (uncommitted) Gradle wrapper and make the existing 6-module skeleton
**assemble**, before any Compose screens/tests (a2). No product code yet.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `603869e` == `origin/master`,
clean. Backend Slice 1 DOD #1–#20 done (unit 50/50, integration 20/20, lint clean).
Android env (read-only check): `ANDROID_HOME=~/Android/Sdk` with platforms
`android-34/36/36.1`, build-tools `34–37`, `cmdline-tools/latest` (→ `sdkmanager`),
`platform-tools` (adb), `emulator` + `system-images` + `licenses` present; **Java 21**.
**System `gradle` is NOT installed**; `gradlew`/`gradle-wrapper.jar` are not committed
(intentional — see `android/README.md`). Stack pinned in `android/gradle/libs.versions.toml`
(AGP 8.7.3, Kotlin 2.1.0, Compose BOM 2024.12.01, Hilt/Room/Retrofit) — no forbidden deps.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Get the
Android build working: generate the Gradle wrapper and assemble the existing skeleton.
**Consult the official Gradle + Android docs** for current commands. Milestone "a" is
owner-approved, which includes the necessary Android toolchain setup (installing Gradle,
and any missing SDK components via `sdkmanager`, accepting SDK licenses).

### Baseline precondition (STOP if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect 603869e6cf111957083042ce2b2dd4ce6ec2e1cf
git status --short                         # expect empty
echo "$ANDROID_HOME"; ls "$ANDROID_HOME/platforms"   # SDK present
```

### Scope (this step only)
1. **Make Gradle 8.11.1 available** (system `gradle` is absent). Either install it
   (e.g. SDKMAN, or download the distribution named in
   `android/gradle/wrapper/gradle-wrapper.properties`), or bootstrap from that
   distribution — your choice per docs. Then generate the wrapper:
   ```bash
   cd /home/israel/Documents/Development/PlantApp/android
   gradle wrapper --gradle-version 8.11.1 --distribution-type bin
   ```
   This writes `gradlew`, `gradlew.bat`, `gradle/wrapper/gradle-wrapper.jar`.
2. **Assemble the skeleton:**
   ```bash
   cd /home/israel/Documents/Development/PlantApp/android
   ./gradlew :app:assembleDebug
   ```
   The first run downloads AGP/Kotlin/Compose/etc. (slow — expected) and may require an
   SDK component (e.g. a `platforms;android-NN` matching the app's `compileSdk`, or a
   `build-tools` version). If so, install it with the SDK's `sdkmanager`
   (`$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager`) and accept licenses, then retry.
   If a build error needs a **minimal** config fix in the existing Gradle files
   (e.g. a `compileSdk`/version-catalog tweak to match installed components), make the
   smallest such change and note it. If it would need a forbidden dependency or a
   non-trivial redesign, STOP and report (blocker).

### Forbidden
- Do NOT add Kotlin/Compose **feature code** yet (no screens/ViewModels/tests — that's a2).
- Do NOT add dependencies outside the existing `libs.versions.toml` stack, and especially
  none of: CameraX, Firebase/FCM, WorkManager, any AI/LLM SDK, or a `:care-engine` Android
  module (Slice 1 exclusions; D-09/D-11/D-12). Keep the 6-module set.
- Do NOT touch `backend/**`, `shared-schemas/**`, or `supabase/**`.
- `android/local.properties`, `android/.gradle/`, `android/**/build/` stay git-ignored
  (don't commit them). Commit `gradlew`, `gradlew.bat`, `gradle/wrapper/gradle-wrapper.jar`.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
./gradlew :app:assembleDebug    # expect: BUILD SUCCESSFUL (debug APK produced)
```
Build success on the empty-but-configured skeleton proves the toolchain + wrapper +
module wiring. (No unit/UI tests yet — a2 adds those.) Backend suites are unaffected;
don't re-run them.

### Commits (one logical change each)
1. `chore(android): generate Gradle wrapper` — `gradlew`, `gradlew.bat`,
   `gradle/wrapper/gradle-wrapper.jar`.
2. *(only if minimal fixes were needed to assemble)* `chore(android): make skeleton
   modules assemble` — the smallest Gradle/version fixes, described in the report.
Push after each.

### Final report
1. How you provided Gradle (install method) + the wrapper files committed.
2. Any SDK components installed via `sdkmanager` (names) + the app's `compileSdk`.
3. Any minimal Gradle/version fixes made (diff summary) — or "none".
4. `./gradlew :app:assembleDebug` result (BUILD SUCCESSFUL); commit hashes + titles;
   final `origin/master` SHA.
5. Confirm no feature code / forbidden deps added and `backend/**` untouched.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after a1 lands
Verify the wrapper is committed + `:app:assembleDebug` succeeds. Then **a2**: the Slice 1
Compose screens in `:feature-inventory` (add-plant form, plant list, plant detail showing
the water task with rationale/engineVersion/dueAt) wired to `:network` (Retrofit DTOs for
the backend `/plants` API), with Compose UI tests #21–#24 — run on the JVM via
**Robolectric** if feasible (avoids needing a running emulator), else an emulator/AVD.
Decompose a2 (DTOs/network first, then screens, then tests); vision-check a2 (it has real
product surface); stop to ask the owner only on a real blocker.
