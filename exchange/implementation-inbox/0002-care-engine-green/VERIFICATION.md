# VERIFICATION — handoff 0002-care-engine-green (GREEN, objective evidence)

The prompt's Standalone verification is the backend test run going red → green
with the test file unchanged.

## Command
```
cd /home/israel/Documents/Development/PlantApp/backend && npm test
```

## Before this change (state at 1d4e888)
47 tests, **8 failing** — the care-engine 8 with
`TypeError: computeInitialWaterTask is not a function`; 39 schema passing.

## After this change (state at 25f1dbb)
```
 Test Files  7 passed (7)
      Tests  47 passed (47)
```
- The 8 care-engine tests (#7–#14) now pass.
- The 39 schema tests still pass (no regression).
- `npm test` exits 0.

This is **green** verification: the same command that was red at `1d4e888` is now
green at `25f1dbb`, achieved by implementing the engine only — the gate test file
`backend/tests/care-engine/compute-initial-water-task.test.ts` is unchanged
(`git diff --quiet` → unchanged). Nothing was edited to force a pass.

## Contract coverage confirmed by the now-green tests
- #7 one water CareTask (kind/id/plantInstanceId/status).
- #8 engineVersion 0.1.0, priority normal, inputsHash string ≥8, rationale
  contains commonName + baseline, full sourceInputs shape incl. null refs.
- #9 determinism: equal inputs → byte-equal output + identical inputsHash.
- #10 container factor clamps to [0.5, 1.5] (passion 19L→0.5; tomato 100L→1.5).
- #11 later clockUtc, same baseline → different inputsHash, same dueAt.
- #12 baseline supplied → wateringBaselineAt === lastWateredAt; dueAt = +interval×factor.
- #13 baseline fallback → wateringBaselineAt === createdAt.
- #14 different lastWateredAt → different inputsHash AND different dueAt.

## Scope / integrity
- Only `backend/care-engine/index.ts` changed (`git show --stat` = 1 file).
- No dependency added (engine uses `node:crypto`).
- No schema/test/config file modified.

## Final repo state
- origin/master = `25f1dbb0ae1a45549714c0411c04145532d142de`
- local master == origin/master
- working tree clean (only untracked: git-ignored `backend/node_modules/`)
