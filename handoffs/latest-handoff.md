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

## Standing policy update (2026-06-01) — PD-05
- **New policy:** every future feature prompt must include a **standalone
  verification** section (independently runnable, objective pass/fail). Encoded in
  CLAUDE.md, `.claude/rules/prompt-contract.md`, the `implementation-prompt-writer`
  skill, and the `prompt-writer` / `slice-planner` agents.
- The next implementation prompt should **still be Option B** — it now carries a
  Standalone verification section, so it satisfies the gate. Only revise it if that
  section were missing.

## File exchange protocol added (2026-06-01) — PD-06
- Planner ↔ implementation handoffs now go through `exchange/` (immutable
  `READY.json` message dirs; `scripts/exchange-*.sh`; spec `exchange/README.md`).
- Current Option B is published at `exchange/planner-outbox/0001-option-b/`.
- **Owner action:** either paste `prompts/next-implementation-prompt.md` as before,
  or point the implementation Claude at the exchange (it runs
  `scripts/exchange-read-latest-prompt.sh`).
- Implementation returns results via
  `scripts/exchange-create-implementation-report.sh <id> <src-dir>` (add `--blocked`
  with a `BLOCKED.md` if it needs an owner decision).

## Autonomous in-session ping-pong (2026-06-01)
- Planner (this session) and the implementation Claude run as two **live** sessions,
  each with a `run_in_background` watcher that wakes it when the other publishes to
  the exchange. **Not** a detached daemon; both windows must stay open.
- Impl side launches with `--dangerously-skip-permissions`; bootstrap prompt:
  `prompts/impl-claude-autonomy-bootstrap.md`. Planner stays on normal permissions.
- First handoff in flight: `0001-option-b` (two-commit Option B; the npm-cache
  blocker was resolved by mounting the external Drive). Planner posts a short update
  to the owner after each round and only stops to ask on a real blocker.
- **Round 1 done (2026-06-02):** impl Claude completed `0001-option-b` (commits
  `ce141da` + `1d4e888`, pushed; 8 care-engine tests red, 39 schema green). Planner
  verified against real git and published the green handoff `0002-care-engine-green`
  (implement `computeInitialWaterTask`). Watcher re-armed for the `0002` report.
- **Round 2 done (2026-06-02):** impl Claude completed `0002-care-engine-green`
  (`25f1dbb`, `npm test` 47/47; test file unchanged). care-engine #7–#14 complete.
  Planner **paused the loop** to ask the owner the next milestone — A: Postgres-gated
  API tests #15–#20 (needs approval); B: approval-free seed `PlantProfile` catalog +
  schema-valid-CareTask test (recommended); C: Android UI #21–#24; D: pause.
- **Owner chose "B, then A" (2026-06-02).** Round 3: published `0003-seed-catalog`
  (red→green seed catalog + schema-valid-CareTask test) and re-armed the watcher.
  **A is pre-approved** (local Postgres for API tests #15–#20) — planner proceeds to it
  after B without re-asking, stopping only if the DB environment isn't available.
- **Round 3 done (2026-06-02):** B landed (`7a4e19b` red + `b32e7a4` green; `npm test`
  50/50; planner-verified, only 2 new files). Toward A the planner found the **DB env
  not ready** (Supabase CLI not installed — Docker is up; no web framework chosen) and
  **paused to ask the owner**: (1) DB approach — Supabase CLI (D-03) vs. Dockerized
  plain Postgres + `pg` vs. defer; (2) web framework (planner can pick + ADR). Plan:
  decompose A into A1 (migrations: tables + RLS + apply test) then A2 (server +
  endpoints + integration #15–#20). No prompt pending / no watcher armed until answered.
