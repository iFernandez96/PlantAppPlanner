# Slice 1 — Retro (one page)

**Date:** 2026-06-02 · **Final `origin/master`:** `a568a4d` · **Status:** engineering
DOD #1–#24 green; owner device-acceptance pending.

## Goal (recap)
"Add a `PlantInstance` in a `Container` in a `GardenSpace`, then generate one deterministic
`water` `CareTask`." Excludes weather/feedback/advisories/feeding/AI/notifications/photos/
camera/precise-location.

## What shipped (all green)
**Backend** — schema-validation tests (#1–#6); deterministic care-engine
`computeInitialWaterTask` (D-10, #7–#14); seed `PlantProfile` catalog (your 5 plants); full
Supabase Postgres schema + RLS (`garden_spaces`, `plant_profiles`, `containers`,
`plant_instances`, `care_tasks`); Fastify API (`POST /garden-spaces|/containers|/plants`,
`GET /plants[/:id][/tasks]`, `DELETE /plants/:id`) with Supabase-JWT auth → RLS;
add-plant→CareTask flow (#15–#18); RLS isolation (#19); delete cascade (#20); **all
responses conform to the camelCase shared-schemas, Ajv-validated**.
**Android** — `:network` Retrofit DTOs (schema-validated via networknt, D-06); `:domain`
models + `:data` repository over `:network` (DTO↔domain, DataStore, Hilt); `:feature-inventory`
Compose add/list/detail screens + ViewModels + `:app` NavHost; Compose UI tests #21–#24
(Robolectric).

## Test status
Backend: unit **50/50**, integration **21/21**, lint clean, typecheck clean.
Android: `:network` 10/10, `:domain` 2/2, `:data` 5/5, `:feature-inventory` UI 4/4;
`:app:assembleDebug` BUILD SUCCESSFUL.

## Decisions made during implementation
- **ADR-0005** Fastify (web framework; D-01 left it unpinned). **ADR-0006** API auth =
  Supabase-JWT forwarding → RLS authoritative (D-05).
- **API wire contract = camelCase shared-schemas** (responses mapped + Ajv-locked) — a
  contract inconsistency was caught by the vision gate and fixed before the Android client.
- **Room deferred** (Slice 1 reads live from the backend; offline/Room belongs with the
  Slice 3 reminders). **`tsconfig.eslint.json`** so `npm run lint` passes.
- Planner decisions PD-01..PD-06 (control-tower role, no-mutation, planner remote, install
  approval, standalone-verification gate, exchange protocol) + the vision-alignment gate.

## Process notes
13 handoffs over the autonomous in-session ping-pong (planner ↔ implementation Claude via
the `exchange/` watchers), every one red→green and planner-verified against real git, with
each prompt vision-checked against `ChatHistory.md`. **No regressions.** Environment
blockers, all host-specific and resolved without repo changes: npm/npx cache + `~/.gradle`
on an unmounted/slow external Drive (fixed via mounting + `npm_config_cache`/`GRADLE_USER_HOME=/tmp`).

## Deferrals / shortcuts (follow-up backlog)
- Add-plant form uses **id text fields**, not catalog/owned-entity selectors — real pickers
  TBD. Optional `nickname`/`placement` fields not in the form yet.
- **No sign-in UI** — auth token is read from DataStore; a Supabase magic-link sign-in
  screen (D-05) is a later slice.
- **No on-device run yet** — verified via Robolectric + `assembleDebug`, not a real device.
- Detail VM uses `getPlants().first{}` (no single-plant GET in the port); ViewModels not
  unit-tested; CI not configured.

## DOD remaining (owner)
- **Device acceptance:** owner adds the 5 real plants on a physical device and sees one
  initial water task per plant (the plan's exit criterion) — needs the API reachable from
  the device (local Supabase + base URL, or a deploy).
- Confirm ADR pins; (optionally) place this retro in PlantApp `docs/` (planner can't write
  the app repo — would be a tiny doc-only handoff).

## Recommended next (owner decides)
1. **Device-acceptance run** of the 5 real plants (closes the human DOD).
2. **UX follow-ups** — real selectors + optional fields; sign-in screen.
3. **Slice 2** — container-size / support / pollination advisories (roadmap).
4. **CI** — wire `npm test`/`test:int` + Android tests so green is enforced on GitHub.
