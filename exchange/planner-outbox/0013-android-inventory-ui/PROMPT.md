# Next Implementation Prompt — a3b: Compose inventory screens + UI tests #21–#24 (closes Slice 1)

**Milestone a (Android UI), step a3b — closes the Slice 1 DOD.** Build the
`:feature-inventory` Compose screens (add-plant form, plant list, plant detail showing the
water task) + Hilt ViewModels + navigation, wired to `InventoryRepository`, and the four
Compose UI tests **#21–#24**. Robolectric-first (JVM) so no emulator is needed.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `a99cb75` == `origin/master`,
clean. `:network` (Retrofit DTOs) + `:domain`/`:data` (repository over `:network`,
DataStore, Hilt) exist and are JVM-tested; `:app:assembleDebug` builds. Catalog already
pins Compose BOM 2024.12.01, Material3, activity/navigation/lifecycle-compose, Hilt-
navigation-compose. Build with `GRADLE_USER_HOME=/tmp/plantapp-gradle-home`, no concurrent
gradlew runs.

Two commits: (1) red UI tests; (2) green screens + wiring.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Build the
Slice 1 Compose inventory UI + the four UI tests. **Consult the official Jetpack Compose,
Material 3, Hilt (+ hilt-navigation-compose), Navigation-Compose, and Robolectric +
compose-ui-test docs.** Build/test with `GRADLE_USER_HOME=/tmp/plantapp-gradle-home`.

### Baseline precondition (STOP if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect a99cb755ecdbb76463e394b914a395a2916dcdbf
git status --short                         # expect empty
```

### Scope
**`:feature-inventory`** (Compose, Material 3, Hilt):
- **PlantListScreen** — lists the caller's plants from `InventoryRepository.getPlants()`;
  shows an **empty state** when there are none; tapping a plant opens detail.
- **AddPlantScreen** — form: profile (selector), container (select-or-create), garden space
  (select-or-create), growth stage, optional last-watered. Submit → `addPlant(...)`. On
  success, surface the new plant id (navigate to detail). **Validation:** if container is
  missing, show a field-level error and do **not** submit/navigate.
- **PlantDetailScreen** — shows the plant + its initial water `CareTask`: `kind` "water", a
  rationale string, an **engineVersion badge**, and a formatted `dueAt`.
- `@HiltViewModel` ViewModels injecting `InventoryRepository`, exposing UI state
  (loading / empty / content / error) via `StateFlow`; coroutines for the suspend calls.
- Use semantics-friendly Composables (test tags / contentDescription) so the UI tests can
  assert reliably.

**`:app`** — wire it up to run: `@HiltAndroidApp` Application, a `MainActivity`
(`@AndroidEntryPoint`) hosting a Compose **NavHost** (list → add → detail) with the
`:design-system` Material 3 theme. Keep it minimal.

**`:design-system`** — only if needed: a minimal Material 3 theme wrapper.

### Red-first UI tests (#21–#24) — `:feature-inventory/src/test/` via Robolectric (JVM)
Test the Composables directly with a **fake `InventoryRepository`** (or fake VM state) +
`createComposeRule()` under Robolectric — do NOT require an emulator or full Hilt graph in
tests. Cover:
- **#21 empty state:** PlantListScreen with no plants renders the empty-state message.
- **#22 add-plant flow:** filling all required fields and submitting invokes the success
  path with the new plant id (assert via a nav/`onSaved` callback spy) → navigates to detail.
- **#23 detail shows the task:** PlantDetailScreen with a plant + one water `CareTask`
  renders kind "water", the rationale, the engineVersion badge, and a formatted `dueAt`.
- **#24 validation:** submitting AddPlantScreen without a container shows a field-level
  error and does **not** invoke the success/nav callback.
Add **test-only** deps to the catalog as needed: `androidx.compose.ui:ui-test-junit4`,
`org.robolectric:robolectric`, the compose-ui-test manifest helper. Configure
`testOptions { unitTests { isIncludeAndroidResources = true } }` for Robolectric in
`:feature-inventory`.

### Forbidden
- No CameraX, photos, location/GPS, Firebase/FCM, WorkManager, AI/LLM SDK, Ktor, Room, or a
  `:care-engine` module (Slice 1 exclusions; D-09/D-11/D-12). No care-scheduling logic on
  device — render the backend `CareTask` as-is. No new **production** deps beyond the
  existing catalog (Compose/Material3/Hilt/nav).
- Don't touch `backend/**`, `shared-schemas/**`, `supabase/**`, `:network`/`:domain`/`:data`
  source (consume them as-is).

### Verify (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest --no-daemon  # #21–#24 green
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug --no-daemon                      # BUILD SUCCESSFUL
```
Red-first: write #21–#24 first (red — screens don't exist), then implement → green. If
Robolectric+Compose can't be made to run on the JVM after a reasonable effort, STOP and
report (don't silently switch to requiring an emulator — flag it as a decision).

### Commits
1. `test(android-inventory): add Slice 1 Compose UI tests (#21–#24)` (RED)
2. `feat(android-inventory): add add-plant/list/detail screens + nav (Slice 1 UI)` (GREEN)
Push after each.

### Final report
1. Commit hashes + titles; final `origin/master` SHA.
2. `:feature-inventory:testDebugUnitTest` RED→GREEN counts (the 4 tests); `:app:assembleDebug` OK.
3. `git show --stat` per commit; modules/files added; how the UI tests run (Robolectric, fake
   repo) and any test-only deps added; confirm no forbidden deps, no `backend/**`/`:network`/
   `:domain`/`:data` source changes.
4. Note anything deferred or any UX shortcut taken (for the Slice 1 retro).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after a3b lands
Verify #21–#24 green + `:app:assembleDebug`. That completes the **Slice 1 DOD (#1–#24)**.
Then STOP and report to the owner with a consolidated Slice 1 retro (per the plan's DOD:
a one-page retro) and the decision on what's next (Slice 2 advisories, the on-device
manual run on a real device, etc.) — do not auto-start Slice 2.
