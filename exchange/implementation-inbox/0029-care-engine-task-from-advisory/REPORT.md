# DONE — handoff 0029-care-engine-task-from-advisory (3d-engine, red→green)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** pure deterministic `computeTaskFromAdvisory` added to the care engine — turns an
*accepted* advisory into a schema-valid `CareTask`. **Not wired to any endpoint** (that is 3d-api);
it computes a task object and persists nothing. Backend gate green. Final `origin/master` =
`e4ffe4b5430870877c41327f73679b7813fe7032`.

## Baseline + unblock
- HEAD at start = `e76ff8d…` == origin/master; clean.

## The function (`backend/care-engine/task-from-advisory.ts`, new)
Pure (no I/O, no `Date.now`, no randomness), mirroring `computeInitialWaterTask`'s determinism.
- **kind mapping:** `container-size → 'repot'`, `support → 'support'`. `'pollination'` (and any
  unknown kind) **throws** `Error('unsupported advisory kind: <kind>')` — pollination is "grow
  another plant", not a single actionable task; 3d-api will map the throw to HTTP 400.
- **priority** from severity: `low→'low'`, `medium→'normal'`, `high→'high'`.
- **dueAt** = `clockUtc` (actionable immediately on acceptance).
- **rationale** = `` `${advisory.title}: ${advisory.message}` ``.
- **rationaleMetadata** = `{ acceptedAdvisoryKind: advisory.kind }` (schema allows
  `additionalProperties: true`).
- **sourceInputs** = `{ plantInstanceId, profileId, profileVersion, containerId, gardenSpaceId,
  clockUtc, wateringBaselineAt: clockUtc, weatherWindowRef: null, feedbackWindowRef: null }` —
  `sourceInputs` is water-centric but schema-required for every task; `wateringBaselineAt` is set
  to `clockUtc` as the required placeholder (commented as such).
- **inputsHash** = `sha256(canonicalJson({ kind, sourceInputs }))` — hashes `{kind, sourceInputs}`
  (not `sourceInputs` alone like the water engine) so different advisory kinds for the same
  plant+clock yield distinct hashes (commented as an intentional difference). `canonicalJson` is a
  private local copy of the helper in `index.ts` (commented; `index.ts` untouched).
- **engineVersion** = `'0.1.0'`; **status** = `'pending'`.
- (Typecheck-only nuance: `priority` lookup falls back to `'normal'` to satisfy
  `noUncheckedIndexedAccess`; the input type already constrains severity to the three keys.)

## Tests (the gate) — `backend/tests/care-engine/task-from-advisory.test.ts` (new)
Mirrors `compute-initial-water-task.test.ts`: dynamic `import('../../care-engine/task-from-advisory.js')`
in `beforeAll`; validates output with `compileSchema('care-task')` from `../schema/_helpers.js`
(the same helper `seed-catalog.test.ts` uses). **5 tests:**
- container-size (high) → `kind==='repot'`, `priority==='high'`, `dueAt===clockUtc`, rationale
  contains the message, `sourceInputs.plantInstanceId===plant.id`, **validates** against
  care-task.schema.json.
- support (medium) → `kind==='support'`, `priority==='normal'`; validates.
- determinism: identical input → deep-equal incl. identical `inputsHash`.
- different advisory kinds (same plant+clock) → **different** `inputsHash`.
- pollination (and any other kind) → **throws** `unsupported advisory kind`.

```
$ cd backend && npm test
 Test Files  11 passed (11)
      Tests  72 passed (72)
$ npm run validate-schemas   # all schemas valid (no schema change)
$ npm run typecheck          # clean
$ npm run lint               # clean
```
- `npm test` count **67 → 72** (+5, the new file). All 11 files pass.

## Commit
- `e4ffe4b` — feat(care-engine): deterministic computeTaskFromAdvisory (accepted advisory -> CareTask)
- `git show --stat HEAD`: 2 files, +239 — only `backend/care-engine/task-from-advisory.ts` +
  `backend/tests/care-engine/task-from-advisory.test.ts`.

## Compliance
- No change to `care-engine/index.ts`, `advisories.ts`, `src/**`, migrations, schemas, Android, or
  any other test. No new dependency. No I/O / `Date.now` / randomness. Not wired to any endpoint.
  Determinism preserved (invariant: advisories never *auto*-create tasks — this only runs on
  explicit acceptance via the future endpoint).

Final `origin/master` SHA: `e4ffe4b5430870877c41327f73679b7813fe7032`

## Next (3d-api, per planner follow-up)
`POST /plants/:id/advisories/accept` (body `{ kind }`): recompute advisories (RLS-scoped, 404 if
not owned), find the matching currently-applicable advisory (400 if absent/unsupported), call
`computeTaskFromAdvisory`, **persist** a `care_tasks` row, return the created CareTask; integration
tests incl. GET-advisories-creates-nothing + RLS + pollination/absent → 400. Then the Android
accept action.
