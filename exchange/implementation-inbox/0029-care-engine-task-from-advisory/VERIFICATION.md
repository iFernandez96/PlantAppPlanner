# VERIFICATION — handoff 0029-care-engine-task-from-advisory (3d-engine, red→green)

Gate: backend `npm test` + `validate-schemas` + `typecheck` + `lint`.

## RED driver
`task-from-advisory.test.ts` loads `computeTaskFromAdvisory` via dynamic import in `beforeAll`;
before the function file exists the export is `undefined` → each test fails with
"computeTaskFromAdvisory is not a function" (per-test red, not a suite-load abort).

## GREEN
```
$ cd backend && npm test
 ✓ tests/care-engine/task-from-advisory.test.ts (5 tests)
 Test Files  11 passed (11)
      Tests  72 passed (72)
$ npm run validate-schemas   # garden-space/plant-instance/plant-profile/space-plan/... all valid
$ npm run typecheck          # tsc --noEmit, no errors
$ npm run lint               # eslint ., no errors
```
- New `task-from-advisory.test.ts` — 5 tests, all pass:
  - container-size (high) → repot / high / dueAt===clockUtc / rationale contains message /
    sourceInputs.plantInstanceId===plant.id / **schema-valid**.
  - support (medium) → support / normal / schema-valid.
  - determinism: identical input → deep-equal incl. identical inputsHash.
  - different advisory kinds (same plant+clock) → different inputsHash.
  - pollination/unknown → throws /unsupported advisory kind/.
- `npm test` count 67 → 72 (+5). All prior tests still green. No schema change → validate-schemas
  unchanged-green.

## Scope / integrity
- `git show --stat`: 2 files, +239 — only `backend/care-engine/task-from-advisory.ts` (new) +
  `backend/tests/care-engine/task-from-advisory.test.ts` (new). No change to
  `index.ts`/`advisories.ts`/`src/**`/migrations/schemas/Android/other tests. No new dependency.
  Pure function (no I/O, no Date.now, no randomness). Not wired to any endpoint.

## Final repo state
- origin/master = `e4ffe4b5430870877c41327f73679b7813fe7032`; local == origin.
- Working tree clean except git-ignored `android/local.properties`.
