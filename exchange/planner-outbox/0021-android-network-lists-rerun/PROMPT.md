# Next Implementation Prompt — 3b-network RE-RUN (`0021`, supersedes blocked `0020`)

**Why a re-run:** `0020` was implemented correctly but **BLOCKED at the gate** — the Android SDK
sits on an external Drive that was unmounted after a session restart, so
`:network:testDebugUnitTest` could not run. **The owner has now re-mounted the Drive** (verified
by the planner: `~/Android/Sdk/platforms` resolves → `android-34/35/36`; `~/.gradle` + `~/.npm`
restored). The prior attempt left its four `:network` edits **uncommitted in the working tree**
(verified by the planner: only `android/network/**`, +64 lines, scope-correct). This handoff runs
the gate and commits them.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`c7b8c54fa70163c3e974d50bec5d9fa9f4f3464d` == `origin/master`. The working tree is **not clean** —
it contains exactly these four modified files from the blocked `0020` attempt (and a git-ignored
`android/local.properties` SDK pointer):
```
 M android/network/src/main/kotlin/dev/plantapp/network/Dtos.kt
 M android/network/src/main/kotlin/dev/plantapp/network/PlantAppApi.kt
 M android/network/src/test/kotlin/dev/plantapp/network/DtoFixtures.kt
 M android/network/src/test/kotlin/dev/plantapp/network/SchemaValidationTest.kt
```

Single logical change (the `:network` layer for the list endpoints) → one commit.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). The Drive is
re-mounted and your prior `:network` edits are already in the working tree. Verify the SDK,
confirm the working tree matches the expected scope, run the gate, and commit.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD     # expect c7b8c54fa70163c3e974d50bec5d9fa9f4f3464d == origin/master
ls /home/israel/Android/Sdk/platforms      # expect android-34/35/36 (SDK resolves — Drive mounted)
git status --short                          # expect EXACTLY the 4 android/network/** files above, nothing else
```
- If `git status` shows **any file outside `android/network/**`** modified/added (other than the
  git-ignored `android/local.properties`), **STOP and report** — do not commit.
- If the SDK still does not resolve, **STOP and report** (Drive not mounted).

### What must be in the tree (the implemented scope — re-create only if missing)
The four files should already contain, per the original `0020`:
- `Dtos.kt`: `PlantProfileDto` — scalars typed (`id`, `scientificName`, `commonNames: List<String>`,
  `category`, `growthHabit`, `version: Int`); nested `wateringProfile`/`feedingProfile`/
  `containerProfile`/`lightProfile`/`temperatureProfile` as `JsonObject`; optionals
  `requiresSupport: Boolean?`, `selfFruitful: Boolean?`, `pollinationPartnersRequired: Int?`,
  `seasonality: JsonObject?`, `commonIssues: List<String>?`, `verticalSuitability: Double?`,
  `source: JsonArray?`, `lastReviewedAt: String?`, all `= null`.
- `PlantAppApi.kt`: `getPlantProfiles(): List<PlantProfileDto>`, `getGardenSpaces(): List<GardenSpaceDto>`,
  `getContainers(): List<ContainerDto>`.
- `DtoFixtures.kt`: a complete, schema-valid `plantProfile` fixture (`buildJsonObject` nested profiles).
- `SchemaValidationTest.kt`: `plantProfileDtoConformsToSchema()` validating against
  `plant-profile.schema.json`.

If any of the above is absent/incorrect, finish implementing it (same scope, `:network` only).

### Forbidden
- No change to `:data`, `:domain`, `:feature-inventory`, `:app`, or any backend/`shared-schemas`/
  `supabase` file. No new dependency. No UI. No camera/photos/GPS/notifications/AI. Do not mount,
  repoint, or relocate the SDK/Drive symlinks (the owner already mounted). Do not commit
  `android/local.properties` (it is git-ignored; leave it).

### Standalone verification (the gate — now runnable)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest
```
Expected: `:network` unit tests pass — the new `plantProfileDtoConformsToSchema` green, all prior
`:network` tests still green. Report the test count + the new test name. If a test fails, fix the
`:network` code (still single-scope) until green, then commit.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/network/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-network): PlantProfileDto + list calls for profiles/spaces/containers"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. SDK-resolves confirmation; `git status` matched the expected 4 files (nothing else).
2. `:network:testDebugUnitTest` result (count, new test green, prior green).
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/network/**` files committed (not `local.properties`).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `android/network/**`; new DTO + 3 calls; `:network` tests green).
Then **3b-data**: `:domain` `PlantProfile` model + `:data` `InventoryRepository` list methods over
the new `:network` calls + mapper + MockK unit tests. Then **3b-ui**: `:feature-inventory`
add-plant **selectors** (profile dropdown; garden-space/container select-or-create) replacing the
id text fields + ViewModel + Compose UI tests. Then 3c (magic-link sign-in → DataStore), 3d
(advisory→accept→CareTask). Then (2) emulator e2e smoke; then (4) Slice 3 (WorkManager local
first; STOP for owner Firebase/FCM setup). Vision-check each product-surface step.
