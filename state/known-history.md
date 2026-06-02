# PlantApp — Known History

Commit + decision timeline for the real app repo
(`github.com/iFernandez96/PlantApp`, branch `master`). Oldest → newest.
Verified from `git log --oneline` on 2026-05-31. The full history is 20 commits;
`52c9d77` is HEAD and matches `origin/master`.

## Phase 0 — Brainstorm & strategy
- `62b3ad5` docs: add initial brainstorm and product-strategy notes

## Phase 1 — Foundation & architecture
- `1300fa7` chore: establish project foundation, architecture, and Slice 1 plan
- `d2d7514` chore: add BDD feature files, shared JSON schemas, AI prompts, and eval scaffolds
- `fcf0742` chore: tighten repo foundation before Slice 1 implementation

## Phase 2 — Watering baseline & Slice 1 decisions
- `9a3ae93` docs: add Slice 1 watering baseline to care formula
- `b4020cc` docs: clean up Slice 1 implementation plan numbering
- `fd11a2e` docs: accept Slice 1 decisions D-01..D-12
- `8110844` docs: sync accepted Slice 1 decisions across foundation docs
- `5dc4d87` docs: clean up final pre-scaffolding wording
- `06c1940` docs: sync Slice 1 implementation plan after accepted decisions
- `1b6140e` docs: remove stale README pre-scaffolding wording

## Phase 3 — Scaffolding
- `2c29a85` chore: scaffold backend Node.js TypeScript skeleton
- `228acd8` chore: scaffold supabase migrations
- `dc66cca` chore: scaffold android gradle multi-module skeleton
- `5d7d42b` chore: add root task runner
- `d5294a4` docs: update README after Slice 1 scaffolding

## Phase 4 — Project subagents
- `54c4c5f` chore: add project subagents for workflow reviews
- `9509a9b` docs: tighten foundation after subagent review

## Phase 5 — Schema tests (red-first) & contract alignment
- `56b1c4f` test(schema): add Slice 1 schema-validation failing tests
- `52c9d77` test(schema): make Slice 1 schema contract assertions consistent

## Phase 6 — Stale-comment cleanup (planner Option A)
- `b2836ca` test(schema): remove stale GardenSpace minLength comment — 2026-05-31; comment-only (3 ins/5 del, 1 file), planner-verified

## Phase 7 — Slice 1 care-engine (Option B, red-first)
- `ce141da` chore(backend): install dependencies and commit lockfile — 2026-06-02; first-ever `npm test` = 39 schema tests green
- `1d4e888` test(care-engine): add Slice 1 watering-engine failing tests — 2026-06-02; 8 care-engine tests red (`is not a function`), 39 green; engine still placeholder
- `25f1dbb` feat(care-engine): implement computeInitialWaterTask — 2026-06-02; engine green, `npm test` 47/47; test file unchanged; D-10 #7–#14 done
- `7a4e19b` test(care-engine): add Slice 1 seed-catalog failing tests — 2026-06-02; red (empty catalog)
- `b32e7a4` feat(care-engine): add Slice 1 seed PlantProfile catalog ← **HEAD / origin/master** — 2026-06-02; 5 profiles, `npm test` 50/50; each emits a schema-valid CareTask

## Accepted decisions (canonical record in `docs/slice-01-decision-log.md`)

All accepted 2026-05-26:

| ID | Pin |
|---|---|
| D-01 | Node.js + TypeScript API runtime |
| D-02 | Retrofit + OkHttp + kotlinx.serialization (Android) |
| D-03 | Supabase migrations CLI |
| D-04 | No background-job runner in Slice 1 (defer) |
| D-05 | Supabase Auth, email magic link only |
| D-06 | Ajv on backend; handwritten DTOs + kotlinx.serialization on Android |
| D-07 | Crash reporting deferred to Slice 3 |
| D-08 | API hosting deferred until first deploy |
| D-09 | Care-engine **backend-only** for Slice 1 (no `:care-engine` Android module) |
| D-10 | Care-engine v0.1.0 watering formula with `wateringBaselineAt` |
| D-11 | No photos in Slice 1 |
| D-12 | Postal code only; no precise location in Slice 1 |

## Slice 1 scope (locked)

"Add a `PlantInstance` in a `Container` in a `GardenSpace`, then generate one
deterministic `water` `CareTask`." Excludes weather, feedback, advisories,
feeding, AI, notifications, photos, camera, production auth flows, precise
location.

## Care-engine v0.1.0 formula (D-10, for the on-deck care-engine tests)

```
wateringBaselineAt = plant.lastWateredAt ?? plant.createdAt
containerFactor    = clamp(container.volumeLiters
                           / profile.containerProfile.recommendedMinLiters, 0.5, 1.5)
dueAt              = wateringBaselineAt + profile.wateringProfile.baseIntervalDays × containerFactor
priority           = "normal"
engineVersion      = "0.1.0"
sourceInputs       = { plantInstanceId, profileId, profileVersion, containerId,
                       gardenSpaceId, clockUtc, wateringBaselineAt,
                       weatherWindowRef: null, feedbackWindowRef: null }
inputsHash         = sha256(canonical-json(sourceInputs))
```

## Planner timeline

- **2026-05-31** — Planner control tower initialized. Verified PlantApp at
  `52c9d77`, clean, no production behavior. Recorded planner decision PD-01
  (choose Option A) in `decisions/planner-decisions.md`.
- **2026-05-31** — Option A landed (`b2836ca`) and planner-verified comment-only.
  Owner added a remote for the planner repo
  (`git@github.com:iFernandez96/PlantAppPlanner.git`) and pushed `master`.
  Next step set to Option B (care-engine red-first tests #7–#14), pending the
  `npm install` decision.
- **2026-06-02** — Autonomous in-session ping-pong adopted (planner ↔ impl Claude via
  exchange watchers; impl runs `--dangerously-skip-permissions`). Option B red-first
  landed: `ce141da` (deps+lockfile; 39 schema tests green on first run) + `1d4e888`
  (8 care-engine tests red). Planner verified and published green prompt
  `0002-care-engine-green`.
- **2026-06-02** — Green landed: `25f1dbb` implements `computeInitialWaterTask`,
  `npm test` 47/47 (planner-verified: function exported, test file unchanged).
  Care-engine #7–#14 complete. Planner **paused the loop** to ask the owner the next
  milestone (Postgres-gated API tests vs. an approval-free seed-catalog step vs. Android).
- **2026-06-02** — Owner chose "B, then A". B done: `7a4e19b` (red) + `b32e7a4`
  (green seed catalog), `npm test` 50/50, planner-verified. Toward A, planner found the
  local DB env not ready (Supabase CLI not installed; no web framework chosen) and
  **paused to ask the owner** the A approach (Supabase CLI vs. Dockerized Postgres) +
  framework, proposing A1 migrations/RLS then A2 server/endpoints.
