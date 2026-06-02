# DONE — handoff 0021-android-network-lists-rerun (supersedes blocked 0020)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** the `0020` `:network` edits (PlantProfileDto + 3 list GET calls + fixture +
schema test) are now gate-verified and committed. The blocker (Android SDK on an unmounted
Drive) is resolved — owner re-mounted the Drive.
Final `origin/master` = `ce59e5e416faa64f1da07505372e0aa043960e6a`.

## Baseline + unblock confirmation
- HEAD at start = `c7b8c54fa70163c3e974d50bec5d9fa9f4f3464d` == origin/master.
- SDK resolves again: `ls ~/Android/Sdk/platforms` → `android-34/35/36/36.1`;
  `/media/israel/Drive` is a mountpoint (re-mounted by the owner). Re-checked mid-run:
  Drive MOUNTED, SDK OK.
- `git status --short` matched **exactly** the four `android/network/**` files from the
  blocked `0020` attempt (plus the git-ignored `android/local.properties`); nothing else.

## Scope (carried from 0020, verified present)
- `Dtos.kt` — `PlantProfileDto`: scalars typed (id, scientificName, commonNames, category,
  growthHabit, version); nested wateringProfile/feedingProfile/containerProfile/
  lightProfile/temperatureProfile as `JsonObject`; optionals requiresSupport, selfFruitful,
  pollinationPartnersRequired, seasonality (JsonObject?), commonIssues (List<String>?),
  verticalSuitability (Double?), source (JsonArray?), lastReviewedAt — all `= null`.
- `PlantAppApi.kt` — `getPlantProfiles(): List<PlantProfileDto>`, `getGardenSpaces():
  List<GardenSpaceDto>`, `getContainers(): List<ContainerDto>`.
- `DtoFixtures.kt` — complete schema-valid `plantProfile` fixture (buildJsonObject nested
  profiles).
- `SchemaValidationTest.kt` — `plantProfileDtoConformsToSchema()` (validates against
  `plant-profile.schema.json` via networknt, D-06).

## Gate (now runnable)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest
BUILD SUCCESSFUL in 31s
```
- `SchemaValidationTest`: **5 tests, 0 failures** (was 4; the new
  `plantProfileDtoConformsToSchema` is the 5th and is green).
- No failing result files across `:network` (AdvisoryDtoTest, DtoSerializationTest,
  SchemaValidationTest all green).

## Commit
- `ce59e5e` — feat(android-network): PlantProfileDto + list calls for profiles/spaces/containers
- `git show --stat HEAD`: 4 files changed, +64 — only `android/network/**`
  (`Dtos.kt` +27, `PlantAppApi.kt` +9, `DtoFixtures.kt` +22, `SchemaValidationTest.kt` +6).
- `android/local.properties` NOT committed (git-ignored; grep count 0 in the commit).

## Compliance
- Only `android/network/**` changed/committed. No `:data`/`:domain`/`:feature-inventory`/
  `:app`/backend/`shared-schemas`/`supabase` change. No new deps, no UI, no
  camera/photos/GPS/AI. Did not mount/repoint the SDK or Drive (owner already mounted);
  left the git-ignored `local.properties` in place.

Final `origin/master` SHA: `ce59e5e416faa64f1da07505372e0aa043960e6a`

## Next (3b-data, per planner follow-up)
`:domain` `PlantProfile` model + `:data` `InventoryRepository` list methods over the new
`:network` calls (getPlantProfiles/getGardenSpaces/getContainers) + mapper + MockK unit
tests. Then 3b-ui (add-plant selectors). Backend remains unaffected by the Drive episode.
