# VERIFICATION — handoff 0001-option-b (red-first, objective evidence)

The prompt's Standalone verification is the backend test run at each commit.

## Commit 1 (`ce141da`) — schema baseline GREEN
Command:
```
cd /home/israel/Documents/Development/PlantApp/backend && npm test
```
Result (first-ever vitest execution after `npm install`):
```
 Test Files  6 passed (6)
      Tests  39 passed (39)
```
All pre-existing schema tests pass. No regression, no pre-existing failure to
flag to the planner.

Tracked change at this commit = lockfile only:
```
git show --stat ce141da  ->  backend/package-lock.json | 3213 insertions(+); 1 file changed
git diff backend/package.json  ->  (none; UNCHANGED)
git check-ignore backend/node_modules  ->  backend/node_modules (ignored, untracked)
```

## Commit 2 (`1d4e888`) — 8 new care-engine tests RED, schema still GREEN
Command:
```
cd /home/israel/Documents/Development/PlantApp/backend && npm test
```
Result:
```
 Test Files  1 failed | 6 passed (7)
      Tests  8 failed | 39 passed (47)
```
Each of the 8 new tests (#7–#14) failed individually with:
```
TypeError: computeInitialWaterTask is not a function
```
Key red-first qualities confirmed:
- The suite **loaded** (dynamic `import()` in `beforeAll` succeeded) — these are
  per-test failures, NOT a collection/module-link error.
- The 39 schema tests remained green (no regression).
- `npm test` exited non-zero — the desired red.

Engine still a placeholder (red-first intact):
```
tail -1 backend/care-engine/index.ts  ->  export {};
git diff backend/care-engine/index.ts ->  (none; UNCHANGED)
```

Tracked change at this commit = the new test file only:
```
git show --stat 1d4e888  ->  backend/tests/care-engine/compute-initial-water-task.test.ts | 167 insertions(+); 1 file changed
```

## Green path for the planner's next prompt
The same command (`npm test`) must go fully green once
`feat(care-engine): implement computeInitialWaterTask` exports the function
(sha256 + canonical-JSON of `sourceInputs`, D-10 formula, schema-valid CareTask)
— with **no change to this test file** (the dynamic import binds to the real
export the moment it exists).

## Final repo state
- origin/master = `1d4e888769f4f982e0368ed41e723416b1b91dea`
- local master == origin/master
- working tree clean (only untracked: `backend/node_modules/`, git-ignored)
