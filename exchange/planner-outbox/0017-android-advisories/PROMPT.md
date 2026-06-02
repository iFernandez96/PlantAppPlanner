# Next Implementation Prompt — S2.3: Android advisory display (closes Slice 2)

**Slice 2, step S2.3 — closes the slice.** Surface the backend advisories on the Android
plant-detail screen: `:network` DTO + API method, `:data` repository method, and the
`:feature-inventory` detail UI (severity-styled), with tests. Advisories are **displayed as
informational** (backend-computed, opaque) — the app does **not** compute them or turn them
into tasks.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `8d3e813` == `origin/master`,
clean. Backend `GET /plants/:id/advisories` returns schema-conformant `Advisory[]`
(`advisory.schema.json`: `kind` container-size|support|pollination, `severity`
low|medium|high, `plantInstanceId`, `profileId`, `title`, `message`, optional `details`,
`createdAt`). Android `:network`/`:domain`/`:data`/`:feature-inventory` exist from Slice 1.
Build with `GRADLE_USER_HOME=/tmp/plantapp-gradle-home`, no concurrent gradlew runs.

Two commits: (1) red tests; (2) green DTO/repo/UI.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the
advisory display end-to-end on Android. **Consult the official Compose/Hilt/Retrofit docs.**

### Baseline precondition (STOP if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect 8d3e813cc35f37f6b2cbf592dfbfb47bd072b096
git status --short                         # expect empty
```

### Scope
- **`:network`** — `AdvisoryDto` (`@Serializable`, camelCase, matching `advisory.schema.json`:
  kind, severity, plantInstanceId, profileId, title, message, optional details/createdAt) +
  `PlantAppApi.getAdvisories(@Path("id") id: String): List<AdvisoryDto>`
  (`GET plants/{id}/advisories`).
- **`:domain`** — an `Advisory` domain model (kind/severity as enums or strings, title,
  message, …) + `InventoryRepository.getAdvisories(plantId): List<Advisory>`.
- **`:data`** — `InventoryRepositoryImpl.getAdvisories` calls the API and maps
  `AdvisoryDto`→domain (DtoMappers).
- **`:feature-inventory`** — `PlantDetailViewModel` also loads advisories; `PlantDetailScreen`
  renders an **advisories section** (each: title + message, with a severity indicator —
  e.g. high styled distinctly). Empty/none → no section (or a subtle "no advisories"). Use
  stable test tags.
- Advisories are **informational**: do NOT add any "accept → create task" action in this
  step, and the app must not compute advisories locally (it reads them from the backend).

### Tests (red-first)
- `:network` JVM test: `AdvisoryDto` round-trips and validates against
  `advisory.schema.json` via networknt (the existing D-06 helper).
- `:data` JVM test: `getAdvisories` maps a fake API's `List<AdvisoryDto>`→domain (fake
  `PlantAppApi`).
- `:feature-inventory` Compose UI test (Robolectric): PlantDetailScreen with a fixture
  plant + one water task + a `container-size` (high) advisory renders the advisory's title
  and message (and shows it's high-severity). A detail with no advisories renders no
  advisory rows.

### Forbidden
- No backend/schema/migration/`:network`-engine changes beyond the new DTO + API method.
  Don't modify `computeAdvisories`, `advisory.schema.json`, the API, or other modules'
  unrelated source. No CameraX/FCM/WorkManager/AI/Ktor/Room/`:care-engine` module. No new
  production deps beyond the catalog (test-only as needed). No on-device care/advisory
  computation; no "create task from advisory" yet.

### Verify (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/android
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :network:testDebugUnitTest :data:testDebugUnitTest :feature-inventory:testDebugUnitTest --no-daemon
GRADLE_USER_HOME=/tmp/plantapp-gradle-home ./gradlew :app:assembleDebug --no-daemon
```
All green incl. the new advisory tests; `:app:assembleDebug` BUILD SUCCESSFUL. Red-first:
write the tests first (red — DTO/repo/UI absent), then implement → green.

### Commits
1. `test(android-advisories): add Slice 2 advisory DTO/repo/UI tests` (RED)
2. `feat(android-advisories): surface plant advisories on the detail screen (Slice 2)` (GREEN)
Push after each.

### Final report
1. Commit hashes + titles; final `origin/master` SHA.
2. Per-module test RED→GREEN counts; `:app:assembleDebug` OK.
3. `git show --stat` per commit; files added per module; confirm no backend/schema/migration
   changes, no forbidden deps, no on-device advisory computation, no advisory→task action.
4. How the advisory severity is shown (for the Slice 2 retro).

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after S2.3 lands
Verify the advisory display tests + build. That completes **Slice 2 (#@slice-2 scenarios
end-to-end: backend engine + API + Android display)**. Then STOP and report to the owner
with a short Slice 2 wrap + the remaining backlog (the `validate-schemas` tooling fix; the
Slice 1 on-device acceptance run; UX follow-ups), and ask the next direction (Slice 3
reminders, etc.) — do not auto-start the next slice.
