# Planner Decisions

Planner-level decisions (PD-NN). These are decisions the **control tower** makes
about *how to plan / what to recommend next* — distinct from the app's
architecture decisions (D-01…D-12, which live in PlantApp's
`docs/slice-01-decision-log.md`).

---

## PD-01 — Next step is Option A (stale-comment cleanup), not Option B

**Date:** 2026-05-31 · **Status:** Decided → **Landed `b2836ca`** (2026-05-31, planner-verified comment-only)

**Decision:** Recommend the tiny test-comment cleanup (Option A) as the next
implementation prompt, deferring the red-first care-engine tests (Option B) to
the step after.

**Why:** The prior session left a branch in the plan: *if* the stale
`GardenSpace.name` minLength comment still exists → do Option A; *else* → do
Option B. Verified on 2026-05-31 at `52c9d77`:
- `backend/tests/schema/garden-space.test.ts:4-8` **still carries** the stale
  "does not yet enforce a minLength … fails red" note.
- `shared-schemas/garden-space.schema.json:12` **already enforces** `minLength: 1`.
- `backend/tests/schema/_helpers.ts:15` **already** uses `strict: true`.

So the documented condition for Option A is met. Cleaning the stale comment is a
zero-risk, single-file, comment-only change that removes a now-false claim before
new test code is layered on top.

**Evidence:** `reviews/latest-repo-review.md`, `state/current-state.md`,
`github-checks/latest-github-check.md` (all dated 2026-05-31).

**Reversal condition:** If a future planner session re-fetches PlantApp and finds
the comment already gone (someone fixed it out-of-band) or HEAD moved past
`52c9d77`, skip Option A and go straight to Option B.

---

## PD-02 — Planner repo never mutates PlantApp; all impl work goes through prompts

**Date:** 2026-05-31 · **Status:** Standing

**Decision:** This repo only ever produces prompts, reviews, and durable state.
It performs read-only inspection of PlantApp and emits copy/paste prompts for a
separate implementation Claude. It never edits/commits/pushes PlantApp and never
runs installs/builds/migrations there.

**Why:** Owner's explicit boundary; keeps the planner auditable and prevents the
control tower and the implementer from racing on the same working tree.

**Evidence:** `CLAUDE.md` (this repo), `.claude/rules/no-plantapp-mutation.md`.

---

## PD-03 — Planner repo has a GitHub remote; planner pushes its own commits

**Date:** 2026-05-31 · **Status:** Standing

**Decision:** The owner created `origin =
git@github.com:iFernandez96/PlantAppPlanner.git` for THIS planner repo and pushed
`master`. Going forward, the planner commits its updates and **pushes them to that
remote** to keep the GitHub copy in sync. (This is the planner repo only — the
no-mutation boundary on the *app* repo PlantApp is unchanged; see PD-02.)

**Why:** The owner explicitly established and used the remote, signaling the
planner repo should live on GitHub and stay synced. CLAUDE.md previously said
"push the planner repo only if/when the owner adds a remote" — that condition is
now met.

**How to apply:** after each planner commit, `git push origin master` for the
planner repo. If the owner later says stop, record the reversal here.

**Evidence:** session bash log 2026-05-31 (`git remote add origin …PlantAppPlanner.git`;
`git push origin master` → `* [new branch] master -> master`).

---

## PD-04 — npm install approved for Option B (care-engine tests run for real)

**Date:** 2026-05-31 · **Status:** Decided

**Decision:** The owner approved running `npm install` in `backend/` so the
red-first care-engine tests execute. Option B is therefore a two-commit sequence:
(1) `chore(backend): install dependencies and commit lockfile`, (2)
`test(care-engine): add Slice 1 watering-engine failing tests` (run to confirm red).
`package-lock.json` is committed; `node_modules/` stays git-ignored.

**Why:** Executed red-first beats structural red — it proves the 8 tests fail for
the right reason before the green implementation, and the next (green) step needs
deps installed anyway. Owner chose "Install + commit lockfile" when asked
(`AskUserQuestion`, 2026-05-31).

**Scope:** This approval is for a dependency install (`npm install`) in `backend/`
only. It does NOT extend to builds, migrations, or DB commands — those still need
separate approval. Per-change approval discipline (PD-02) otherwise stands.

---

## PD-05 — Standalone verification required for feature completion

**Date:** 2026-06-01 · **Status:** Standing

**Decision:** Every future feature must include independently runnable verification
before it can be called done.

**Why:** Claude self-report and manual review are not enough. PlantApp needs
objective proof that behavior works end-to-end or slice-end-to-end.

**Scope:** Applies to feature work, green implementation commits, slice completion,
and future AI features. Documentation-only, prompt-only, and red-first test-only
commits may use a narrower verification statement, but must explicitly say why.

**Examples:**
- Backend care-engine: `npm test -- tests/care-engine/...`
- Backend API: integration test against local Postgres/Supabase.
- Android UI: Compose UI or instrumented test.
- Database migration: migration apply/reset plus schema/RLS verification command.
- AI: eval runner with fixed fixtures and schema validation + a pass/fail threshold.
- Full slice: `just verify-slice-N`.

**Enforcement:** `.claude/rules/prompt-contract.md` (section 7 + the Standalone
verification subsection), the `implementation-prompt-writer` skill, and the
`prompt-writer` / `slice-planner` agents all require/justify a standalone
verification section; the planner rejects or revises prompts that lack one.
