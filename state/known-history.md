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
- `52c9d77` test(schema): make Slice 1 schema contract assertions consistent ← **HEAD / origin/master**

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
