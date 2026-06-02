# VERIFICATION — handoff 0015-advisory-engine (S2.1, red→green)

Gate: `cd backend && npm test` red→green on the advisory-engine tests, with each advisory
validated against `advisory.schema.json`.

## Commit 1 (`1077764`) — RED
```
 FAIL  tests/care-engine/compute-advisories.test.ts
 Test Files  1 failed | 9 passed (10)
      Tests  61 passed | 6 skipped (67)
```
`computeAdvisories` not implemented → dynamic import in beforeAll fails → the 6 advisory
tests are skipped/failed; prior 61 pass. Intended red.

## Commit 2 (`4f3d76a`) — GREEN
```
 Test Files  10 passed (10)
      Tests  67 passed (67)
$ npm run typecheck   -> clean
$ npm run lint        -> LINT OK
```
Proven by the now-green tests:
- container-size: 19 L vs recommended 95 (ideal 95–190) → one `high` advisory, message
  contains 95 and 190, schema-valid; 95 L → none.
- support: requiresSupport && !supportRecorded → one; supportRecorded → none.
- pollination: selfFruitful=false & count 1 < 2 → one (message mentions "self-fruitful");
  count 2 → none.
- well-provisioned self-fruitful plant → `[]`.
- invariant/determinism: returns `Advisory[]` (no engineVersion/inputsHash/dueAt — never a
  CareTask); equal inputs → equal output; every advisory validates against the schema.

## Scope / integrity
- Only added: `backend/tests/care-engine/compute-advisories.test.ts` (c1),
  `backend/care-engine/advisories.ts` (c2).
- `backend/care-engine/index.ts`, `shared-schemas/**`, `supabase/**`, `backend/src/**`,
  and existing tests unchanged (`git diff --quiet HEAD`). No new deps.

## Final repo state
- origin/master = `4f3d76a6d8c85b6f847e01b690590c0e54a98861`; local == origin; clean.
- Backend `npm test` 67/67, typecheck + lint clean. (Pre-existing `validate-schemas` CLI
  failure unchanged — out of scope; previously flagged for a hygiene handoff.)
