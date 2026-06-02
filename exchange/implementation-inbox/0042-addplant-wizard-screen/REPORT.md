# DONE — handoff 0042-addplant-wizard-screen (beginner wizard H2, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** the jargon `AddPlantScreen` is replaced by a **3-step, icon-led `AddPlantWizard`** a
novice can complete (What are you growing? → Where will it live? → What's it planted in? → confirm).
Big tappable tiles, plain language, **no litres/material/drainage/growth-stage/ISO shown**; the
engine gets the technical values from the friendly choices + hidden defaults. Icons are **custom
vector drawables — no emoji**. `:feature-inventory` tests green; `:app:assembleDebug` OK. Final
`origin/master` = `5f1e7ce102a3ad219cedd38bb75c186752da4b17`.

## Baseline + unblock
- HEAD at start = `12f0dbb…` == origin/master; clean. SDK resolves.

## What was added/changed
1. **Custom vector drawables** (`:feature-inventory/src/main/res/drawable/`, original simple flat
   shapes, no emoji/raster): species `ic_species_tomato/basil/strawberry/passionfruit/tomatillo` +
   `ic_species_default`; locations `ic_loc_windowsill/balcony/backyard/indoors`; `ic_pot`.
2. **`addplant/WizardIcons.kt`** — `@DrawableRes speciesIconRes(profileId)` (5 ids → drawable, else
   default), `locationIconRes(kind)`, `potIconRes()`. Separate from the pure model (references
   `R.drawable`).
3. **Removed the emoji `categoryIcon`** from `WizardModel.kt`; replaced its assertions in
   `AddPlantWizardModelTest` with a hidden-defaults check.
4. **`addplant/AddPlantWizard.kt`** — stateless composable, same signature as the old screen
   (profiles/gardenSpaces/containers + create callbacks + onSubmit/onCancel). Internal `step` (1→2→
   3→confirm) + a "Back" affordance. Step 1: a species tile per profile (`speciesIconRes` +
   `commonNames.first()`). Step 2: location preset tiles (`LOCATION_PRESETS`, `locationIconRes`).
   Step 3: pot-size tiles (`POT_SIZES`, `potIconRes` + the size label — no litres). Confirm: plain
   summary ("Add your {Tomato} to the {Balcony}?") + big **Add**.
5. **Create/select plumbing (per the correctness requirements):** `AddPlantViewModel.create…` is
   async (appends after the network call), so the wizard (a) **reuses** a matching existing
   space/container instead of creating a duplicate (so Back→reselect doesn't orphan), and (b)
   **resolves ids by identity** via `LaunchedEffect(gardenSpaces…)` / `LaunchedEffect(containers…)`
   — never `list.last()`. The **Add** button is **disabled** until both the space and container ids
   resolve, so `onSubmit` never fires with a blank/stale id. (Read `AddPlantViewModel` first to
   confirm the append-after-create behaviour.)
6. **Tags** (`InventoryTestTags`): `WIZARD_SPECIES_TILE_PREFIX`/`WIZARD_LOCATION_TILE_PREFIX`
   (+kind)/`WIZARD_POT_TILE_PREFIX` (+label-slug via `potTileTagSuffix`)/`WIZARD_ADD_BUTTON`/
   `WIZARD_BACK_BUTTON`.
7. **Deleted `AddPlantScreen.kt`** and removed its now-stale tests from `InventoryScreensTest`
   (kept #21 list-empty + #23 detail). Updated `NavSmokeTest` + `:app MainActivity` `Routes.ADD` to
   host `AddPlantWizard` (same VM wiring).
   - (Used `TextButton("Back")` rather than a Material-Icons back arrow — the icons artifact isn't a
     `:feature-inventory` dep, and plain "Back" is beginner-friendly anyway.)

## Tests (the gate)
```
$ cd android && GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :feature-inventory:testDebugUnitTest :app:assembleDebug
BUILD SUCCESSFUL in 56s
```
- **`AddPlantWizardTest`** (new, Robolectric, 2) — driven via a **stateful host** that mirrors the
  VM (create callbacks append to the re-supplied lists):
  - `walkTomatoBalconyFiveGallonBucketThenAddSubmitsResolvedForm` — step-1 shows a tile per
    profile; Tomato → Balcony (asserts `onCreateGardenSpace` called) → "5-gallon bucket" (asserts
    `onCreateContainer` called with `volumeLiters == 19.0`) → **Add** → `onSubmit` got
    `profileId = "solanum-lycopersicum"`, `growthStage = "seedling"`, `lastWateredAt == null`, and
    **non-blank** containerId + gardenSpaceId resolved from the re-supplied lists.
  - `backThenReselectSameLocationDoesNotCreateDuplicate` — pick location, Back, pick same →
    `onCreateGardenSpace` called **once** (reuse, no duplicate).
- `:feature-inventory` total **25 → 20** (removed 7 old AddPlantScreen tests; AddPlantWizardModelTest
  3, AddPlantWizardTest 2, InventoryScreensTest 2, NavSmokeTest 2, NotificationPermissionTest 4,
  PlantDetailAdvisoriesTest 4, SignInScreenTest 3). All green.
- **`:app:assembleDebug` BUILD SUCCESSFUL** (the wizard route wiring type-checks).
- **No emoji** in any changed source (`grep -P` for emoji ranges over `:feature-inventory`/`:app`
  src → none).

## Commit
- `5f1e7ce` — feat(android-inventory): beginner add-plant wizard (3-step, custom icons) replacing the jargon form
- `git show --stat HEAD`: 21 files, +516 −474 — only `android/feature-inventory/**` (wizard, icons,
  11 drawables, model/tags/tests; `AddPlantScreen.kt` deleted) + `android/app/**` (MainActivity).
  `local.properties` NOT committed (grep 0).

## Compliance
- No emoji anywhere (icons via `WizardIcons`, summary copy is plain text). Vectors only (no raster).
  No `:network`/`:data`/`:domain`/backend/schema change (reused existing repo/VM methods). No new
  dependency. No litres/material/drainage/growth-stage/ISO surfaced. No camera/photos/GPS/AI.
  SDK/Drive untouched.

Final `origin/master` SHA: `5f1e7ce102a3ad219cedd38bb75c186752da4b17`

## Note for the planner / owner
The vector icons are intentionally **simple placeholders** (geometric, original — no licensing
concern); final icon look is the owner's on-device call. Refinement is an easy follow-up.

## Next (per planner follow-up)
Device review: rebuild the LAN-debug APK + reinstall so the owner can eyeball the wizard + icons on
the phone (offer to re-stand-up the backend for a full run). Then the copy sweep (friendly sign-in/
list/detail + advisory wording).
