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

---

## PD-06 — Atomic file exchange protocol for planner/implementation handoffs

**Date:** 2026-06-01 · **Status:** Standing

**Decision:** Planner and implementation Claude communicate via immutable `exchange/`
message directories marked by `READY.json`, not live shared files.

**Why:** Avoid partial reads, race conditions, and ambiguous ownership. Only `READY`
messages are readable; `.writing/` is never read. Only the planner asks the owner for
decisions.

**Rules:**
- Planner writes `planner-outbox/` (prompts); reads `implementation-inbox/` (reports).
- Implementation reads `planner-outbox/` (READY only); writes `implementation-inbox/`.
- Implementation does not edit planner `state/`/`reviews/`/`decisions/`/`prompts/`/outbox.
- Blockers are written as `BLOCKED.md` reports; the implementation then stops.
- The planner consumes blockers and is the only instance that asks the owner.
- Published `<handoff-id>/` directories are immutable; supersede with a new id.

**Mechanics:** atomic build-in-`.writing/` → write `READY.json` last → rename into
place → `.tmp`+`mv` pointer update. Scripts: `scripts/exchange-*.sh`. Spec:
`exchange/README.md`. The current Option B prompt is published as
`exchange/planner-outbox/0001-option-b/`; `prompts/next-implementation-prompt.md`
remains the human-readable mirror.

## PD-08 — Wave 2 overhaul approved (2026-06-10)
Owner approved `plans/wave2-overhaul-plan.md` as written (all 4 pillars + folded polish + full
redesign pass, stages W0–W5, ~45–60 handoffs). Standing instruction: **"Show me when gated"** —
planner runs the wave continuously and surfaces to the owner ONLY at decision gates A (redesign
direction), B (houseplant enum), C (icon strategy), D (OpenAI key+consent), or on BLOCKED/regression.

## PD-09 — Gate A: Wave 2 redesign direction = GARDEN HEARTH (2026-06-10)
Owner picked **Garden Hearth** (evolve Verdant Glasshouse: warm kitchen-table planner; cream/green
kept, glass calmed to warm opaque cards, Fraunces headlines only, body 17sp for novice/elderly
readability). Full spec: `reviews/redesign-directions-wave2.md` §1. Cost M, lowest-risk direction.

## PD-10 — Per-slice device checks (2026-06-10)
Owner asked for frequent on-device checks. Standing practice for Wave 2: after EVERY verified
UI-affecting slice, rebuild the LAN debug APK, install on the owner's phone (wifi-adb), walk the
affected screens light+dark via a device agent, save shots to reviews/device-evidence/, and send
the key shots to the owner. Local stack (Supabase+Fastify) stays up during the wave.

## PD-11 — Photo plant-ID feature approved for W5 (2026-06-10)
Owner wants identify-by-photo → confirm → add-to-garden. Decisions:
- **Provider: Pl@ntNet API** (backend-only call; no provider key on Android; candidates matched
  against our own catalog profiles so we only suggest plants we have cited care data for).
- **Ships in W5** alongside the AI assistant (one consent/AI stage).
- **Photo handling: offer to save** — opt-in per photo after confirm, stored in our Supabase
  storage; otherwise discarded after the ID call. Requires: camera/photo permission (amends the
  no-camera posture — owner-approved here), Pl@ntNet data-sharing consent copy, storage+deletion
  story. Gate D expands to D′: OpenAI key+consent (assistant) + Pl@ntNet consent + camera
  permission + photo-storage consent copy — all surfaced together at W5 start.

## PD-12 — Orphan garden-space rows: keep create-on-the-spot; manage in W4 (2026-06-11)
**Context:** device testing found that abandoning the add-plant wizard after creating a garden
space (or container) leaves the row in the DB — it reappears in the wizard's pickers later.
**Decision (planner-decided, not a gate):** keep the wizard's immediate create-on-the-spot
behavior. Rationale: the product vision is container/space-FIRST — a space the user named and
typed in is a legitimate first-class entity even with zero plants (you set up your balcony
before adding plants to it). Deferring creation to final submit would need a multi-step
transactional flow for marginal benefit and risks the working wizard. The UX concern
(unexpected reappearing spaces) is resolved by **W4 space management** (rename / add /
delete-with-guard — already in the wave2 plan), which makes these rows visible and deletable.
No cleanup job (a daemon deleting "unused" spaces would fight the vision and the owner's
no-daemon stance). NO implementation slice needed now.

## PD-13 — (note) Raw-401/raw-error polish on wizard + detail deferred to early W2 (2026-06-11)
After 0057, `authed{}` maps 401 → `SessionExpiredException` everywhere, but only the LIST screen
routes it to sign-in; the wizard/detail/add VMs still surface raw `e.message` (exception text,
LAN IPs) in their error states. 0058 fixes sign-in's copy. **Deferred decision:** one early-W2
slice ("friendly errors everywhere") converts the remaining `e.message` surfaces (AddPlantViewModel
×4, PlantListUiState.Error, PlantDetailUiState.Error) to plain-language copy + routes
SessionExpiredException to sign-in from any screen. Tracked so W1-exit review doesn't flag it as
unknown.

## PD-14 — Gate B RESOLVED: extend category enum with "houseplant" (owner, 2026-06-11)
The 9 catalog profiles currently in "other" (pothos, monstera, snake plant, peace lily, ZZ,
spider plant, rubber plant, Chinese evergreen, heartleaf philodendron) are all houseplants.
Owner approved adding `"houseplant"` to `plant-profile.schema.json`'s category enum and
recategorizing those 9. Ripple (one W2 slice): schema + backend Ajv/schema tests + the 9
scratch profiles (planner-side update before the seed migration) + species-picker chip.

## PD-15 — Gate C RESOLVED: hybrid icons (owner, 2026-06-11)
Per-species CC0 vectors where quality assets exist; category fallback icons (~10, incl. the
new houseplant category) otherwise. Matches the existing `WizardIcons.speciesIconRes()`
mapping+fallback pattern. Planner stages icon sourcing in scratch/catalog/icons/ (cited
sources/licenses); impl wires drawables in W2.

## Note — W1-EXIT device review DEFERRED (owner: "work without the phone for now", 2026-06-11)
W1 is code-complete (0047–0058). The full light+dark device walk + owner sign-off runs as soon
as wireless debugging is re-enabled; W2 proceeds in parallel by owner direction. Per-slice
device checks (PD-10) queue up while the phone is offline and run as a batch on reconnect.
