# Next Implementation Prompt — backlog (3b-network): Android `:network` list calls + `PlantProfileDto`

**Backlog item (3) UX follow-ups, step 3b — part 1 of 3 (network layer).** The add-plant form
selectors (3b-ui) need the three backend list endpoints landed in `0019`
(`GET /plant-profiles`, `GET /garden-spaces`, `GET /containers`). This step wires them into
the Android `:network` module only: add `PlantProfileDto`, add the three `GET` calls to
`PlantAppApi`, and prove the new DTO validates against `plant-profile.schema.json` (D-06).
**No `:data`, no `:feature-inventory`, no UI** — those are the next two handoffs (3b-data, 3b-ui).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`c7b8c54fa70163c3e974d50bec5d9fa9f4f3464d` == `origin/master`, clean. `:network` already has
`GardenSpaceDto`, `ContainerDto`, `PlantInstanceDto`, `CareTaskDto`, `AdvisoryDto` and the
`PlantAppApi` Retrofit interface (POST garden-spaces/containers/plants; GET
plants, plants/{id}, plants/{id}/tasks, plants/{id}/advisories; DELETE). `:network` tests use
kotlinx + networknt schema validation (`TestSupport.validateAgainstSchema`, `DtoFixtures`).
There is **no** `PlantProfileDto` and **no** list call for profiles/spaces/containers yet.

Single logical change (the `:network` layer for the list endpoints) → one commit. Red-first.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the
`:network` layer for the three list endpoints. **Consult kotlinx-serialization + Retrofit docs**
if needed. Red-first: write the schema-validation test/fixture first.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect c7b8c54fa70163c3e974d50bec5d9fa9f4f3464d
git status --short                         # expect empty
```

### Scope — `:network` module only
1. **`android/network/src/main/kotlin/dev/plantapp/network/Dtos.kt`** — add `PlantProfileDto`
   mirroring `shared-schemas/plant-profile.schema.json` (camelCase). Use the existing module
   `Json` conventions (nullable optionals with `= null` default). Model the required scalar
   fields as typed properties and the nested objects as `kotlinx.serialization.json.JsonObject`
   (precedent: `AdvisoryDto.details`), since the selector only consumes the scalar fields:
   - Required (non-null): `id: String`, `scientificName: String`, `commonNames: List<String>`,
     `category: String`, `growthHabit: String`, `wateringProfile: JsonObject`,
     `feedingProfile: JsonObject`, `containerProfile: JsonObject`, `lightProfile: JsonObject`,
     `temperatureProfile: JsonObject`, `version: Int`.
   - Optional (`= null`): `requiresSupport: Boolean?`, `selfFruitful: Boolean?`,
     `pollinationPartnersRequired: Int?`, `seasonality: JsonObject?`,
     `commonIssues: List<String>?`, `verticalSuitability: Double?`,
     `source: kotlinx.serialization.json.JsonArray?`, `lastReviewedAt: String?`.
2. **`android/network/src/main/kotlin/dev/plantapp/network/PlantAppApi.kt`** — add three
   suspend GET calls (reuse the existing `GardenSpaceDto`/`ContainerDto` for the latter two):
   ```kotlin
   @GET("plant-profiles") suspend fun getPlantProfiles(): List<PlantProfileDto>
   @GET("garden-spaces")  suspend fun getGardenSpaces(): List<GardenSpaceDto>
   @GET("containers")     suspend fun getContainers(): List<ContainerDto>
   ```

### Tests — extend the existing `:network` test sources
- **`DtoFixtures.kt`** — add a `plantProfile` fixture that is a **complete, schema-valid**
  `PlantProfileDto` (e.g. `id = "solanum-lycopersicum"`, real `commonNames`, `category`,
  `growthHabit`, `version = 1`, and the five nested `*Profile` objects populated with the
  minimum keys their sub-schemas require — `wateringProfile` needs `baseIntervalDays`+
  `dryingTolerance`; `feedingProfile` needs `baseIntervalDays`; `containerProfile` needs
  `recommendedMinLiters`; `lightProfile` needs `targetSunHours`; `temperatureProfile` may be
  `{}`). Build the `JsonObject`s with `buildJsonObject { ... }`.
- **`SchemaValidationTest.kt`** — add `plantProfileDtoConformsToSchema()` asserting
  `TestSupport.validateAgainstSchema("plant-profile", json.encodeToString(DtoFixtures.plantProfile))`
  returns no errors. (Optionally add a round-trip assertion à la `AdvisoryDtoTest`.)

### Forbidden
- No change to `:data`, `:domain`, `:feature-inventory`, `:app`, or any backend/`shared-schemas`/
  `supabase` file. No new dependency (kotlinx + networknt already present in `:network`). No UI.
  No camera/photos/GPS/notifications/AI. Do not alter the existing DTOs or API methods.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest
```
Red-first: before `PlantProfileDto`/the fixture exist, the new test fails to compile/pass; after
implementation, `:network` unit tests pass (the new `plantProfileDtoConformsToSchema` green,
all prior `:network` tests still green). Report the test count and the new test name.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add android/network/
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(android-network): PlantProfileDto + list calls for profiles/spaces/containers"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The `PlantProfileDto` shape (which fields typed vs `JsonObject`) + the three new API calls.
2. `:network:testDebugUnitTest` result (count before→after, the new test green, prior green).
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `android/network/**` files changed.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `android/network/**`; new DTO + 3 calls; `:network` tests green;
no backend/other-module change). Then **3b-data** (handoff): `:data`
`InventoryRepository` methods exposing the three lists (over the new `:network` calls) + a
`PlantProfile` domain model in `:domain` + `:data` mapper + unit tests (MockK). Then **3b-ui**:
`:feature-inventory` add-plant **selectors** (profile dropdown; garden-space/container
select-or-create) replacing the id text fields + ViewModel + Compose UI tests. Then 3c
(magic-link sign-in → DataStore), 3d (advisory→accept→CareTask). Then (2) emulator e2e smoke;
then (4) Slice 3 (WorkManager local first; STOP for owner Firebase/FCM setup). Vision-check
each product-surface step.
