# Planner Decisions

Planner-level decisions (PD-NN). These are decisions the **control tower** makes
about *how to plan / what to recommend next* — distinct from the app's
architecture decisions (D-01…D-12, which live in PlantApp's
`docs/slice-01-decision-log.md`).

---

## PD-01 — Next step is Option A (stale-comment cleanup), not Option B

**Date:** 2026-05-31 · **Status:** Decided

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
