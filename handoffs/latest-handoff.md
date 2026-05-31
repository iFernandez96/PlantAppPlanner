# Latest Handoff

**From:** Option-A-verification + Option-B-prep session · **Date:** 2026-05-31

## One-line status
Option A landed and is planner-verified (`b2836ca`, comment-only). Option B
(care-engine red-first tests) is **ready as a two-commit prompt** — owner approved
`npm install` (PD-04), and the test was hardened to use a **dynamic import** so the
red is per-test (not a suite load error). PlantApp still has **no production behavior**.

## What this session did
- Verified Option A on `origin/master` independently (`git show`/`diff`): one file,
  comment-only, fixture + assertions intact.
- Grounded the Option B test spec against the real schemas + existing fixtures.
- Asked the owner about `npm install`; they chose **"Install + commit lockfile."**
  Recorded as PD-04.
- Rewrote `prompts/next-implementation-prompt.md` as the **two-commit** Option B
  (install+lockfile, then tests-run-red). Confirmed `node_modules/` is git-ignored
  so the lockfile commit stays clean.
- Updated `state/current-state.md`, `state/known-history.md`,
  `github-checks/latest-github-check.md`, `reviews/latest-repo-review.md`,
  `decisions/planner-decisions.md` (PD-03 planner remote, PD-04 install).
- Committed + pushed the planner repo to its new remote
  (`git@github.com:iFernandez96/PlantAppPlanner.git`).
- **Hardening pass:** fixed the Option B test to load the engine via a dynamic
  import (a static named import of the missing export would abort the suite at
  collection rather than failing per-test). Commit `chore: tighten Option B prompt
  for predictable red failure`.

## What the OWNER does next
Paste the two-commit Option B prompt from `prompts/next-implementation-prompt.md`
into the implementation Claude. It will: `npm install` in backend/ → run `npm test`
(baseline) → commit lockfile → add the care-engine test file → run `npm test` →
confirm the 8 tests fail red → commit → push (two commits total).

## What the NEXT planner session does
1. Re-read `state/current-state.md` + this handoff; `git -C PlantApp fetch origin`
   and compare HEAD vs `origin/master` (expect `b2836ca` until Option B lands; then
   two new commits: a `chore(backend)` lockfile commit + a `test(care-engine)` commit).
2. Verify red-first intact: engine still `export {};`; the 8 tests present and (per
   the impl report) failing with `is not a function`.
3. **Record the first-ever test-run result** — did the pre-existing schema tests
   pass? Note it in `state/current-state.md` (this was their first real execution).
4. Write the **green** prompt: `feat(care-engine): implement computeInitialWaterTask`
   (sha256 + canonical-JSON of `sourceInputs`, D-10 formula, schema-valid `CareTask`).
   The test file needs no change for green — its dynamic import resolves to the real
   function once exported.

## Open questions for the owner
- None blocking. (Install decision resolved → PD-04.) Future gate: builds/migrations
  still need separate approval when a slice needs them.

## Tripwires / do-not-assume
- Re-verify SHAs every session; don't assume `b2836ca` is still HEAD.
- This is vitest's first run in PlantApp — pre-existing schema tests have never
  actually executed. Treat any pre-existing failure as a real finding, not noise.
- Keep `care-engine/index.ts` a placeholder during Option B; implementing it is the
  separate green commit.
- No CI on GitHub; PlantApp commits go straight to `master`.
- Planner repo: commit **and push** to its remote (PD-03).
