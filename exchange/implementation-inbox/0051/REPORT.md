# Implementation report — 0051-wizard-location-kinds-hotfix

## Status: DONE

## What was done
UI-side mapping hotfix (no migration): the wizard's location presets now send DB-allowed
`garden_spaces.kind` values; labels unchanged:
- "Windowsill" → `window-ledge` (was `windowsill`)
- "Balcony" → `balcony` (unchanged)
- "Backyard" → `other` (was `yard`)
- "Indoors" → `indoor-room` (was `indoor`)

Files (exactly the 4 from §3):
1. `WizardModel.kt` — `LOCATION_PRESETS` kinds remapped; a 2-line comment added noting the
   constraint coupling (supabase/migrations/0002) and why Backyard → `other`.
2. `WizardIcons.kt` — `locationIcon` keys remapped (`window-ledge`→WbSunny, `other`→Cottage,
   `indoor-room`→Home); `balcony` and the `else` branch unchanged.
3. `AddPlantWizardTest.kt` — lines 119/126 tile tag `"windowsill"` → `"window-ledge"`
   (line 88 `"balcony"` untouched).
4. `AddPlantWizardModelTest.kt` — expected label→kind pairs updated + NEW red-first constraint
   test (verbatim from the prompt) asserting every preset kind is in the DB-allowed set.

No error-surfacing work added (separate follow-up slice per the prompt).

## Red-first evidence (§5 step 1: only the new test added, suite run)
```
AddPlantWizardModelTest > location preset kinds are accepted by the garden_spaces DB constraint FAILED
    java.lang.IllegalStateException at AddPlantWizardModelTest.kt:47
26 tests completed, 1 failed
```
Failure message from the JUnit XML (verbatim):
```
java.lang.IllegalStateException: preset 'Windowsill' sends invalid kind 'windowsill'
```
Exactly the predicted red; no other failure in step 1.

## Green evidence (§5 step 2)
- `:feature-inventory:testDebugUnitTest` → BUILD SUCCESSFUL; JUnit XML aggregate
  **tests=26 failures+errors=0** (25 from 0050 + 1 new constraint test).
- `:app:assembleDebug` → BUILD SUCCESSFUL.

## Baseline precondition
- HEAD before work: `cbe520ba263c197e3609c3bf6f939f539f77cac2` ✓
- Tree clean except untracked `android/.kotlin/` (left alone) ✓

## Commit + push
- New commit: `e72607095ad2d5636a744501a4c002bc18fc09b0`
- Title (exact): `fix(wizard): map location presets to DB-allowed garden-space kinds (silent Add-button brick)`
- Pushed: `cbe520b..e726070  master -> master`; new `origin/master` =
  `e72607095ad2d5636a744501a4c002bc18fc09b0`

### git show --stat HEAD
```
 .../plantapp/feature/inventory/addplant/WizardIcons.kt  |  6 +++---
 .../plantapp/feature/inventory/addplant/WizardModel.kt  |  8 +++++---
 .../feature/inventory/AddPlantWizardModelTest.kt        | 17 ++++++++++++++---
 .../plantapp/feature/inventory/AddPlantWizardTest.kt    |  4 ++--
 4 files changed, 24 insertions(+), 11 deletions(-)
```
Exactly the 4 files. ✓

## Scope confirmation
- No supabase/backend/schema changes (constraint untouched); preset labels, tile layout, icon
  visual choices, and all other wizard logic unchanged; no new dependencies;
  `android/.kotlin/` left untracked.
