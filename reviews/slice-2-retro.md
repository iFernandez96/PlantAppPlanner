# Slice 2 — Retro (one page)

**Date:** 2026-06-02 · **Final `origin/master`:** `c4e4396` · **Status:** Slice 2
(advisories) complete end-to-end; all 5 `@slice-2` scenarios exercised.

## Goal
Deterministic, profile-driven advisories surfaced in the UI — **never auto-creating
CareTasks** (the `@slice-2 @invariant`). Your differentiators: "this passion fruit needs a
bigger pot", "your lone tomatillo needs a partner."

## What shipped (all green)
- **Contract:** `shared-schemas/advisory.schema.json` (kinds container-size/support/
  pollination; severity low/medium/high) + `docs/slice-02-implementation-plan.md`.
- **Engine:** `backend/care-engine/advisories.ts` `computeAdvisories` — pure, field-driven:
  container-size (high) when volume < `recommendedMinLiters` (cites recommended + ideal
  range, suggests sizes not brands); support when `requiresSupport && !supportRecorded`;
  pollination when `selfFruitful === false && count < pollinationPartnersRequired` (clears
  when a partner is added). Returns `Advisory[]` only — never a CareTask.
- **API:** `GET /plants/:id/advisories` — RLS-scoped, computed-on-read, schema-conformant,
  persists nothing. Migration `0004` + seed enriched profiles with `idealMin/MaxLiters`
  (passion fruit 95/190, etc.).
- **Android:** `:network` `AdvisoryDto` (schema-validated, D-06) + `getAdvisories`; `:domain`
  `Advisory` + port; `:data` mapping; `:feature-inventory` plant-detail advisory section
  (severity-styled) — informational, no "accept → task" action.

## Tests
Backend: unit **67/67**, integration **25/25** (incl. all 5 `@slice-2` BDD scenarios:
container-size cites 95/190, support, lone-tomatillo pollination, second-tomatillo clears,
RLS 404). Android: `:network`, `:data`, `:feature-inventory` advisory tests green;
`:app:assembleDebug` OK. typecheck + lint clean.

## Decisions / notes
- Advisories are **computed-on-read, stateless** (no `advisories` table) — clearing is
  inherent (recompute returns nothing once satisfied). Honors the no-auto-task invariant.
- Severity→color mapping on Android (`high → errorContainer`, `medium → tertiaryContainer`).
- Ideal container ranges added as **data** (migration 0004 jsonb merge + seed) — no
  species-specific code (data-driven doctrine).

## Process
4 handoffs (`0014`–`0017`), each red→green, planner-verified against real git, each
vision-checked against `ChatHistory.md` (all ALIGNED). No regressions. 17 handoffs total
across Slices 1–2.

## Backlog (owner to direct; not started)
- **`validate-schemas` tooling fix** — `npm run validate-schemas` has been red for all 8
  schemas since day one (ajv-cli lacks `ajv-formats`; one `strictTypes` nit in
  diagnosis-result). Redundant/broken gate (the real gate `npm test` validates schemas with
  ajv-formats and is green). One small handoff fixes it.
- **On-device acceptance run** (Slice 1 + 2) on a real device/emulator (API reachable).
- **UX follow-ups:** real profile/container/space selectors (add-plant form uses id text
  fields); sign-in UI to set the auth token; advisory "accept → create task" flow (a real
  later feature — would route through the engine, not auto-create).
- **Next slice:** Slice 3 — deterministic watering reminders + notifications (FCM/WorkManager).

## Recommended next
Either a quick **`validate-schemas` hygiene fix** (cheap, makes that gate real), or the
**on-device acceptance run**, or proceed to **Slice 3**. Owner's call.
