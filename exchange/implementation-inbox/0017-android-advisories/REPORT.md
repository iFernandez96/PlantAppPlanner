# DONE — handoff 0017-android-advisories (S2.3 — closes Slice 2)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** advisories surfaced end-to-end on Android — `:network` DTO + API, `:domain`
model + port, `:data` repo mapping, `:feature-inventory` detail UI (severity-styled). All
module tests green; `:app:assembleDebug` BUILD SUCCESSFUL. **Slice 2 is complete
end-to-end** (engine + API + Android display).
Final `origin/master` = `c4e4396bde2470706abe04a29b53ed307e430028`.

## Baseline precondition — matched
- HEAD = `8d3e813cc35f37f6b2cbf592dfbfb47bd072b096` == origin/master; clean.
- All gradlew runs used `GRADLE_USER_HOME=/tmp/plantapp-gradle-home`; no concurrent runs.

## Commit 1 (RED) — `test(android-advisories): add Slice 2 advisory DTO/repo/UI tests`
- Hash: `63440be`
- `:network` `AdvisoryDtoTest` (round-trip + `advisory.schema.json` validation via the D-06
  networknt helper), `:data` `InventoryAdvisoriesTest` (getAdvisories DTO→domain mapping),
  `:feature-inventory` `PlantDetailAdvisoriesTest` (Robolectric: detail renders an
  advisory's title/message + high-severity; no advisory section when empty).
- Combined module run (RED): compile failures — `AdvisoryDto`, domain `Advisory`,
  `InventoryRepository.getAdvisories`, the `advisories` param, and `ADVISORY_SECTION` all
  absent. Intended red.
- `git show --stat`: 3 files, +138. Pushed `8d3e813..63440be`.

## Commit 2 (GREEN) — `feat(android-advisories): surface plant advisories on the detail screen (Slice 2)`
- Hash: `c4e4396`
- `:network`: `AdvisoryDto` (`@Serializable`, camelCase; `details` as `JsonObject?`) +
  `PlantAppApi.getAdvisories(id): List<AdvisoryDto>` (`GET plants/{id}/advisories`).
- `:domain`: `Advisory` model + `InventoryRepository.getAdvisories(plantId): List<Advisory>`.
- `:data`: `AdvisoryDto.toDomain()` mapper + `InventoryRepositoryImpl.getAdvisories`;
  `FakePlantAppApi` gains an advisory fixture + `getAdvisories` override (test).
- `:feature-inventory`: `PlantDetailUiState.Content` gains `advisories: List<Advisory> =
  emptyList()`; `PlantDetailViewModel.loadFor` also calls `getAdvisories`;
  `PlantDetailScreen` renders an **Advisories** section (tag `ADVISORY_SECTION`) only when
  non-empty, each row severity-styled.
- All module tests green; `:app:assembleDebug` BUILD SUCCESSFUL.
- `git show --stat`: 11 files, +100/−2. Pushed `63440be..c4e4396`.

## Test results (per module)
- `:network` → all green (AdvisoryDto round-trip + schema-valid; prior DTO/schema tests).
- `:data` → all green (InventoryRepositoryImplTest 5 + InventoryAdvisoriesTest 1).
- `:feature-inventory` → all green (InventoryScreensTest 4 + PlantDetailAdvisoriesTest 2).
- `:app:assembleDebug` → BUILD SUCCESSFUL.

## How advisory severity is shown (for the Slice 2 retro)
Each advisory renders as a `Surface` whose container color encodes severity —
`high → errorContainer`, `medium → tertiaryContainer`, else `surfaceVariant` — with a
title line `"<SEVERITY> · <title>"` (e.g. "HIGH · Container is smaller than recommended")
and the message below. The section only appears when there is at least one advisory.

## Compliance
- Advisories are **informational**: the app reads them from the backend, does **not**
  compute them locally, and provides **no** "accept → create task" action.
- No backend/schema/migration changes (`backend/**`, `shared-schemas/**`, `supabase/**`
  UNCHANGED via `git diff --quiet HEAD`); `computeAdvisories`/`advisory.schema.json`/API
  untouched. No forbidden deps (CameraX/FCM/WorkManager/AI/Ktor/Room/`:care-engine`); no
  new production deps. Only the new `AdvisoryDto` + API method were added to `:network`.

## Commit hashes + titles
1. `63440be` — test(android-advisories): add Slice 2 advisory DTO/repo/UI tests
2. `c4e4396` — feat(android-advisories): surface plant advisories on the detail screen (Slice 2)

Final `origin/master` SHA: `c4e4396bde2470706abe04a29b53ed307e430028`

## Slice 2 status (for the owner wrap)
Slice 2 (advisories) is complete end-to-end: deterministic profile-driven engine
(`computeAdvisories`), `GET /plants/:id/advisories` (RLS, schema-conformant, no CareTask),
seed/DB ideal-range enrichment, and the Android detail display. All five `@slice-2` BDD
scenarios are exercised across the backend integration tests and the Android UI test.

Remaining backlog (per the planner follow-up — owner to direct, do not auto-start):
- The small `validate-schemas` tooling fix (add `-c ajv-formats` to the ajv-cli command +
  `type:"array"` in the diagnosis-result conditional) so that gate is green again.
- The Slice 1/2 on-device acceptance run on a real device/emulator.
- UX follow-ups: real profile/container/space selectors (the add-plant form uses id text
  fields); sign-in UI to populate the auth token; advisory "accept → create task" flow.
- Next slice direction (e.g. Slice 3 deterministic watering reminders).
