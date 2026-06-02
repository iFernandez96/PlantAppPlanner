# VERIFICATION — handoff 0014-slice2-foundation (S2.0, red→green)

Gate: `cd backend && npm test` red→green on the advisory schema test.

## Commit 1 (`5e77801`) — RED
```
 FAIL  tests/schema/advisory.test.ts   (Error: ENOENT ... advisory.schema.json)
 Test Files  1 failed | 8 passed (9)
      Tests  50 passed | 11 skipped (61)
```
The advisory schema file doesn't exist yet → `compileSchema('advisory')` throws in
beforeAll. The other 50 tests pass. Intended red.

## Commit 2 (`06f581d`) — GREEN
```
 Test Files  9 passed (9)
      Tests  61 passed (61)
```
`advisory.schema.json` added; the advisory test (accepts container-size/support/
pollination; rejects unknown kind, unknown severity, each missing required field) passes;
prior 50 unchanged.

## validate-schemas (pre-existing finding — see REPORT.md)
```
$ npm run validate-schemas ; echo $?
1
```
All 8 schemas flagged ("unknown format uuid/uri ignored" under `--strict=true` because the
ajv-cli invocation lacks `ajv-formats`; diagnosis-result also trips strictTypes). This is
pre-existing and script-wide — the advisory schema is flagged for the same `uuid` reason
as every other schema and is otherwise valid (it compiles + validates under the Ajv test
helper that adds ajv-formats; `npm test` is 61 green). Not caused by this change; a full
fix needs `package.json` + the forbidden `diagnosis-result.schema.json`, so it is reported
for a dedicated hygiene handoff rather than fixed here.

## Scope / integrity
- Added only: `docs/slice-02-implementation-plan.md`, `backend/tests/schema/advisory.test.ts`,
  `shared-schemas/advisory.schema.json`.
- `backend/care-engine/**`, `backend/src/**`, `supabase/**`, other shared schemas,
  migrations, and existing tests unchanged (`git diff --quiet HEAD`). No new deps. No
  `.feature` changes.

## Final repo state
- origin/master = `06f581d029e191992214a1cd3ee0da0514c345e9`; local == origin; clean.
- Backend `npm test` 61/61. (No engine/API/UI work in this step.)
