# DONE — handoff 0001-option-b (Option B, two commits)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** Both commits landed and pushed. Final `origin/master` =
`1d4e888769f4f982e0368ed41e723416b1b91dea`.

Earlier blocker (broken `~/.npm` cache symlink → unmounted Drive) is resolved:
`/home/israel/.npm` now resolves (`CACHE_DIR_OK`). Re-ran the handoff from the
verified baseline `b2836ca`.

## Baseline precondition — matched

- branch = master
- HEAD = `b2836ca7ff4d65020f1d385d38940cf8652db459` == origin/master
- `git status --short` = empty
- `backend/care-engine/index.ts` = placeholder comment + `export {};`

## Commit 1 — `chore(backend): install dependencies and commit lockfile`

- Hash: `ce141da6d05a36bab29a2838db37c343218529d6`
- `npm install` (plain, no package args) succeeded: **added 176 packages, audited
  177**. No package.json edit. (npm printed deprecation warnings for transitive
  `inflight`/`glob` and a `7 vulnerabilities` audit advisory — informational only;
  no `npm audit fix` was run, per scope.)
- First-ever `npm test` baseline: **6 files / 39 tests, all passed.** The
  pre-existing schema tests are green on their first real execution. No
  pre-existing failure to report.
- `git status --short` showed exactly `?? backend/package-lock.json`.
  `package.json` UNCHANGED. `backend/node_modules` confirmed git-ignored
  (`git check-ignore` → `backend/node_modules`).
- `git show --stat`: **1 file changed**, `backend/package-lock.json` (+3213).
- Pushed `b2836ca..ce141da`.

## Commit 2 — `test(care-engine): add Slice 1 watering-engine failing tests`

- Hash: `1d4e888769f4f982e0368ed41e723416b1b91dea`
- Added exactly one file:
  `backend/tests/care-engine/compute-initial-water-task.test.ts` (167 lines),
  byte-for-byte the file specified in the prompt (dynamic `import()` in
  `beforeAll` preserved; not converted to a static named import).
- `npm test` after adding the file: **7 files (1 failed | 6 passed), 47 tests
  (8 failed | 39 passed).** The 8 new `computeInitialWaterTask` tests fail
  **individually** with `TypeError: computeInitialWaterTask is not a function`
  — the suite loaded cleanly (no collection/load error), which is the intended
  red. The 39 schema tests still pass. `npm test` exited non-zero (desired red).
- Engine NOT implemented: `backend/care-engine/index.ts` still ends in
  `export {};` and `git diff` reports it UNCHANGED.
- `git show --stat`: **1 file changed**, the new test file (+167).
- Pushed `ce141da..1d4e888`.

## Global-forbidden compliance

- Did not implement `computeInitialWaterTask` (placeholder untouched).
- Did not convert the dynamic import to a static named import.
- Did not modify any schema, existing test, `package.json`, `vitest.config.ts`,
  `tsconfig.json`, or `_helpers.ts`.
- Did not commit `node_modules/` (git-ignored; never appeared in `git status`).
- Did not add dependencies beyond `package.json` (plain `npm install`).
- Ran only `npm install`, `npm test`, and read-only/commit/push git. No builds,
  migrations, Supabase/DB/Gradle commands. No `npm audit fix`.

## Commit hashes + titles

1. `ce141da` — chore(backend): install dependencies and commit lockfile
2. `1d4e888` — test(care-engine): add Slice 1 watering-engine failing tests

Final `origin/master` SHA: `1d4e888769f4f982e0368ed41e723416b1b91dea`

## Red-first state for the planner's green follow-up

The 8 tests pin the D-10 contract and will turn green when
`feat(care-engine): implement computeInitialWaterTask` exports the function from
`backend/care-engine/index.ts` (sha256 + canonical-JSON of `sourceInputs`, D-10
formula, schema-valid CareTask). The test file needs **no change** for green —
the dynamic import resolves to the real export once it exists.
