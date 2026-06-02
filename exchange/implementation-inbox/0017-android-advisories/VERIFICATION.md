# VERIFICATION — handoff 0017-android-advisories (S2.3, red→green) — closes Slice 2

Gate: `:network` + `:data` + `:feature-inventory` unit/UI tests red→green;
`:app:assembleDebug` BUILD SUCCESSFUL. `GRADLE_USER_HOME=/tmp/plantapp-gradle-home`.

## Commit 1 (`63440be`) — RED
```
e: Unresolved reference 'AdvisoryDto'        (:network)
e: Unresolved reference 'Advisory'           (:feature-inventory, :data via getAdvisories)
e: No parameter with name 'advisories'       (:feature-inventory)
e: Unresolved reference 'ADVISORY_SECTION'   (:feature-inventory)
BUILD FAILED
```
Compile-red: the advisory DTO/domain/repo-method/UI-state/tag don't exist yet.

## Commit 2 (`c4e4396`) — GREEN
All three modules build and test green (failures="0" across every result file):
- `:network` AdvisoryDtoTest — round-trip + `advisory.schema.json` validation (networknt).
- `:data` InventoryAdvisoriesTest — `getAdvisories` maps `List<AdvisoryDto>` → domain
  (kind/severity/title/message).
- `:feature-inventory` PlantDetailAdvisoriesTest — detail with a high `container-size`
  advisory renders the `ADVISORY_SECTION`, the title, the message, and "HIGH"; with no
  advisories the section is absent (`assertDoesNotExist`).
```
$ ./gradlew :app:assembleDebug --no-daemon
BUILD SUCCESSFUL in 49s
```

## Scope / integrity
- Informational only: app reads advisories from the backend, no local computation, no
  advisory→task action.
- `backend/**`, `shared-schemas/**`, `supabase/**` unchanged (`git diff --quiet HEAD`);
  `computeAdvisories`/`advisory.schema.json`/API untouched. No forbidden deps; no new
  production deps (only `AdvisoryDto` + `getAdvisories` added to `:network`).

## Final repo state
- origin/master = `c4e4396bde2470706abe04a29b53ed307e430028`; local == origin; clean.
- Slice 2 complete end-to-end (engine + API + Android display); all five `@slice-2` BDD
  scenarios exercised across backend integration tests + the Android UI test.
- Backend suites unaffected (not re-run here): unit 67/67, integration 25/25.
