# BLOCKED — handoff 0020-android-network-lists

**Status:** BLOCKED at the verification gate (`:network:testDebugUnitTest`). Environment
failure I cannot fix within scope — **the Android SDK is on an unmounted external drive.**
**App repo:** /home/israel/Documents/Development/PlantApp
**Branch/HEAD:** master @ `c7b8c54fa70163c3e974d50bec5d9fa9f4f3464d` (== origin/master).
Nothing committed or pushed for this handoff.

## Baseline precondition — matched
- HEAD = `c7b8c54fa70163c3e974d50bec5d9fa9f4f3464d` == origin/master; tree was clean at start.

## What I implemented (written, NOT committed — left in the working tree)
All `:network`-only, per the prompt:
- `android/network/src/main/kotlin/dev/plantapp/network/Dtos.kt` — added `PlantProfileDto`
  (scalars typed: id, scientificName, commonNames, category, growthHabit, version;
  nested `wateringProfile`/`feedingProfile`/`containerProfile`/`lightProfile`/
  `temperatureProfile` as `JsonObject`; optionals `requiresSupport`, `selfFruitful`,
  `pollinationPartnersRequired`, `seasonality: JsonObject?`, `commonIssues: List<String>?`,
  `verticalSuitability: Double?`, `source: JsonArray?`, `lastReviewedAt: String?` = null).
- `android/network/src/main/kotlin/dev/plantapp/network/PlantAppApi.kt` — added
  `getPlantProfiles(): List<PlantProfileDto>`, `getGardenSpaces(): List<GardenSpaceDto>`,
  `getContainers(): List<ContainerDto>`.
- `android/network/src/test/.../DtoFixtures.kt` — added a complete, schema-valid
  `plantProfile` fixture (buildJsonObject for the nested profiles).
- `android/network/src/test/.../SchemaValidationTest.kt` — added
  `plantProfileDtoConformsToSchema()` (validates against `plant-profile.schema.json`).

`git status --short` (uncommitted):
```
 M android/network/src/main/kotlin/dev/plantapp/network/Dtos.kt
 M android/network/src/main/kotlin/dev/plantapp/network/PlantAppApi.kt
 M android/network/src/test/kotlin/dev/plantapp/network/DtoFixtures.kt
 M android/network/src/test/kotlin/dev/plantapp/network/SchemaValidationTest.kt
```

## The blocker (environment, not code)
`./gradlew :network:testDebugUnitTest` fails before configuring:
```
> SDK location not found. Define a valid SDK location with an ANDROID_HOME environment
  variable or by setting the sdk.dir path in your project's local properties file at
  '/home/israel/Documents/Development/PlantApp/android/local.properties'.
```
Root cause — the Android SDK lives on an **unmounted external drive**:
```
$ ls -la /home/israel/Android/Sdk
  Sdk -> /media/israel/Drive/Linux/Android-Sdk          # symlink
$ readlink -f /home/israel/Android/Sdk                  # (empty — broken target)
$ ls /home/israel/Android/Sdk/platforms                 # No such file or directory
$ ls /media/israel                                       # (empty)
$ mountpoint /media/israel/Drive                         # NOT a mountpoint
```
`$ANDROID_HOME` is set to `/home/israel/Android/Sdk` and `android/local.properties`
contains `sdk.dir=/home/israel/Android/Sdk`, but both resolve to the unmounted
`/media/israel/Drive/Linux/Android-Sdk`, so AGP finds no SDK. This is the same
external-Drive-unmounted class as the earlier npm-cache (`~/.npm`) and Gradle-home
(`~/.gradle`) symlink failures — all three point at `/media/israel/Drive`, which is not
mounted after the session restart. (I work around `~/.gradle` with
`GRADLE_USER_HOME=/tmp/plantapp-gradle-home`, which survived; but the SDK itself cannot be
substituted.)

## What I tried (all still SDK-not-found)
- Exported `ANDROID_HOME=/home/israel/Android/Sdk` for the gradle process.
- Created `android/local.properties` with `sdk.dir=/home/israel/Android/Sdk` (git-ignored;
  byte-verified).
- `./gradlew --stop`, cleared the configuration-cache, ran `--no-daemon
  --no-configuration-cache`, foreground and background.
All fail identically because the symlink target (the SDK) does not exist while the Drive
is unmounted.

## What I did NOT do (per protocol — no improvising)
- Did NOT mount the Drive or touch `/media/israel`.
- Did NOT repoint/relocate the SDK or `~/Android/Sdk` symlink.
- Did NOT commit the `:network` changes (the handoff's gate — `:network:testDebugUnitTest`
  green — cannot be run, so committing would be unverified).
- Did NOT alter backend/other modules.
- Created only `android/local.properties` (git-ignored; standard local SDK pointer).

## Unblock (for the planner → owner)
Mount the external drive so `/media/israel/Drive/Linux/Android-Sdk` resolves (and ideally
`/media/israel/Drive/Linux/gradle`, `/media/israel/Drive/cache-mirror/npm` for the other
symlinks), then re-issue **0020** unchanged. On re-run the implementer should:
1. Confirm `ls /home/israel/Android/Sdk/platforms` resolves.
2. `cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest`
   → the already-written changes should make `plantProfileDtoConformsToSchema` (and all
   prior `:network` tests) green.
3. Commit `android/network/**` as
   `feat(android-network): PlantProfileDto + list calls for profiles/spaces/containers`
   and push.
(The uncommitted working-tree edits above are ready; alternatively the planner may ask for
a fresh clean re-implementation.)

## Note
Backend work is unaffected by this (TypeScript, no SDK). Only Android build/test steps are
blocked while the Drive is unmounted. `npm test` / `validate-schemas` would still run.
Baseline for the re-issued handoff is unchanged: master @ `c7b8c54`.
