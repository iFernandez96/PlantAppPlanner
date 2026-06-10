# Wave 2 — Massive App Overhaul (PLAN, owner approval required before any prompt ships)

**Date:** 2026-06-02 · **Status:** PROPOSED (owner chose "plan first")
**Owner scope decisions (2026-06-02):** all four pillars — catalog live in-app · Today/care
dashboard · spaces-first navigation · AI garden assistant — **plus** beginner copy-polish folded
in, **plus** a full visual redesign pass (every screen up for rework, Codex-generated directions
like the theme pick). Device access re-verified (SM-S928U1 paired over wifi-adb mDNS).

## Operating doctrine (unchanged)
One logical change → one ten-section prompt → impl Claude → verify vs real git → next. Vision +
guardian gates on every prompt. Red-first where testable. Planner never mutates PlantApp.
Estimated total: **~45–60 implementation handoffs** across 6 stages.

---

## Stage W0 — Prerequisites (before any redesign work)
1. **0046 lands** (dark-mode contentColor fix, already published) + planner device re-verify.
2. **Catalog Phase 2 completes**: run the 21 missing profiles (session limit resets 5:30pm),
   re-validate **75/75** vs `plant-profile.schema.json`, owner reviews a sample profile.
3. **Codex redesign directions**: generate 3 full-redesign directions (navigation model, screen
   inventory, component language — building on Verdant Glasshouse or replacing it) → **owner picks
   one** (Decision Gate A).

## Stage W1 — Redesign foundation (~8–12 handoffs)
- **Navigation architecture**: bottom navigation bar with tabs **Today · My Garden · Spaces ·
  Assistant** (Assistant tab hidden until W5 ships). NavHost restructure + per-tab state.
- **Design-system expansion** per the chosen direction: hero cards, task chips/checkmarks,
  section headers, list-item patterns, motion/transition specs.
- Re-skin existing screens (list/detail/wizard/sign-in) into the new language — copy polish
  applied as each screen is touched (kill `solanum-lycopersicum` slugs, raw engine rationale,
  ISO timestamps, "engine v0.1.0" badge; friendlier sign-in; confirm echoes pot choice).
- **Stage exit:** full device walk (light+dark) screenshotted; owner sign-off.

## Stage W2 — Catalog live in-app (~10–14 handoffs)
- **Decision Gate B (schema):** `houseplant` category — extend the schema enum + DB check
  constraint (cleaner; small migration) **vs** map to `other` (no migration). Planner recommends
  **extend** — beginner UX wants "Houseplants" as a browsable group.
- **Decision Gate C (icons, Phase 3):** at 75 plants — per-species icons (sourced CC0 / Codex
  generated to match theme) **vs** category icons + the existing 5 species icons. Cost/effort
  comparison delivered with the gate.
- Slices: seed migration in batches (75 cited profiles; the 5 existing become `version 2`) →
  backend already serves `GET /plant-profiles` → wizard species step gains **search + category
  chips** (75 items can't be one flat list) → icon wiring → detail screen shows the new profile
  richness in plain language (sun, water, pot size "as sold", common issues).
- **Stage exit:** add-a-plant from all 8 categories on-device; profiles render beginner-clean.

## Stage W3 — Today / care dashboard (~8–10 handoffs)
- Backend: `GET /care-tasks?status=pending` across the user's plants (RLS) +
  `PATCH /care-tasks/:id` complete/skip (engine stays sole task-creator — D-09 intact).
- Domain: due/overdue/today grouping (pure functions, red-first).
- Android: **Today tab becomes home** — today's tasks with plant name + photo/icon,
  tap-to-complete with feedback options, overdue section, empty state ("Nothing to do —
  your plants are happy"). Reminder sync points at the same data.
- **Stage exit:** create plant → task appears on Today → complete it on-device → reminder count
  matches.

## Stage W4 — Spaces-first navigation (~6–8 handoffs)
- Spaces tab: spaces as cards (indoor/outdoor, plant count) → space detail (plants grouped,
  conditions) → move-plant-between-spaces flow → space management (rename, add, delete-with-guard).
- Vision alignment: this is the container/space-first model; vertical-planning fields surface
  read-only where data exists (no new planner features yet).
- **Stage exit:** browse garden by space on-device; move a plant; advisories still correct.

## Stage W5 — AI features: assistant + photo plant-ID (~12–15 handoffs, GATED)
- **Decision Gate D (hard gate):** owner provides OpenAI API key (server env only, never
  committed, never on Android — D-11/D-12) **and** explicitly consents that garden data is sent
  to OpenAI. Model + monthly budget choice included in the gate.
- Backend: `POST /assistant/chat` — RAG (retrieve user's plants, profiles, tasks, advisories as
  context), deterministic engine remains the source of truth, assistant **explains and suggests,
  never creates tasks**. Strict prompt-injection + citation discipline (cited profiles are the
  ground truth).
- Android: Assistant tab chat UI (plain-language, beginner tone), privacy explainer on first use.
- **Photo plant-ID (PD-11):** wizard entry "Identify from a photo" → camera/gallery → backend
  `POST /identify` → **Pl@ntNet API** → candidates matched to our catalog profiles → confirm
  screen ("Is this Basil?") → wizard pre-filled. Photo: opt-in save to Supabase storage after
  confirm, else discarded. Needs camera permission + Pl@ntNet consent (Gate D′).
- **Stage exit:** on-device chat answers "why does my tomato need water today?" citing the
  user's actual task + profile data; photo of a basil plant identifies + adds end-to-end.

## Decision gates summary (planner stops and asks)
| Gate | What | When |
|---|---|---|
| A | Pick 1 of 3 Codex redesign directions | end of W0 |
| B | `houseplant` schema enum vs map-to-other | start of W2 |
| C | Per-species vs category icons at 75 scale | start of W2 |
| D′ | OpenAI key+consent · Pl@ntNet consent · camera permission · photo-save consent (PD-11) | start of W5 |
| (parked) | FCM server push | unchanged, owner-gated |

## Risks / mitigations
- **Redesign churn breaks tests** → re-skin slices update Robolectric tests in the same prompt;
  semantics/test-tags kept stable.
- **Seed migration size** → batch the 75 inserts; idempotent `on conflict do update` for the 5
  enriched rows; integration test asserts row count + a spot profile.
- **Session limits mid-wave** → every stage is resumable from files (this plan + state/).
- **AI cost/privacy** → hard gate D; backend-only; no key in repo; logged consent.
- **Scope explosion** → stages ship in order, each with a device-verified exit; owner can stop
  the wave at any stage boundary with a coherent app.

## Standing verification
Per-slice standalone verification (tests/grep/build) per the prompt contract, plus an on-device
screenshot review at every stage exit (wifi-adb, light+dark), shots into `reviews/device-evidence/`.
