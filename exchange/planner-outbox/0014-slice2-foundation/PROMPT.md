# Next Implementation Prompt — Slice 2 foundation: plan + Advisory shared-schema (S2.0)

**Slice 2 (advisories) — step S2.0.** Establish the Slice 2 plan + the `Advisory`
cross-boundary contract before the engine. Advisories are **deterministic, profile-driven,
computed-on-read, and NEVER auto-create CareTasks** (per `features/container-health.feature`
`@slice-2`, incl. the `@invariant` scenario).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `a568a4d` == `origin/master`,
clean. Slice 1 DOD #1–#24 complete. The `@slice-2` BDD scenarios already exist in
`features/container-health.feature`. No `Advisory` schema and no `docs/slice-02-*` plan yet.
Backend unit 50/50, integration 21/21.

Two commits: (1) docs/plan + red schema test; (2) green `advisory.schema.json`.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Lay the
Slice 2 foundation: the implementation-plan doc and the `Advisory` shared JSON Schema, with
a red→green schema-validation test. **No engine/API/UI yet** (later steps).

### Baseline precondition (STOP if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect a568a4d4ac746e3d3e9942263af32d5bf75356b2
git status --short                         # expect empty
```

### COMMIT 1 — `docs(slice-02): add Slice 2 plan + advisory schema-validation test (red)`
- Add **`docs/slice-02-implementation-plan.md`** capturing (source: `docs/roadmap.md`
  Slice 2 + `features/container-health.feature` `@slice-2`):
  - Goal: deterministic, profile-driven advisories surfaced in the UI, **no auto-created
    CareTasks**.
  - The three rules: **container-size** (severity high) when
    `container.volumeLiters < profile.containerProfile.recommendedMinLiters` (cite
    recommendedMin + ideal range when present; suggest target sizes, not brands);
    **support** when `profile.requiresSupport && !plantInstance.supportRecorded`;
    **pollination** when `profile.selfFruitful === false && <count of the user's active
    instances of that profile> < profile.pollinationPartnersRequired` (clears when a
    partner is added).
  - Invariant: advisories never auto-schedule tasks (only surface; acceptance→task is a
    later concern).
  - Decomposition: S2.0 schema (this) → S2.1 deterministic `computeAdvisories` engine
    (backend TS, red-first) → S2.2 `GET /plants/:id/advisories` API + integration tests →
    S2.3 Android display. Note the **seed-data gap**: seed profiles have
    `recommendedMinLiters` but not `idealMinLiters/idealMaxLiters`; the engine step will
    enrich the seed where the advisory cites an ideal range.
  - In/out of scope + DOD (the 5 `@slice-2` scenarios green at the appropriate layers).
- Add **`backend/tests/schema/advisory.test.ts`** (mirror the existing
  `tests/schema/*.test.ts` using `_helpers.ts` `compileSchema('advisory')`): accepts a
  valid advisory of each kind (container-size/support/pollination), and rejects an unknown
  `kind`, an unknown `severity`, and a missing required field.
- Run `cd backend && npm test` → the advisory test FAILS red (schema file not found / no
  `advisory` schema to compile); the other 50 still pass. Commit + push.

### COMMIT 2 — `feat(schema): add Advisory shared schema (Slice 2 contract)`
Add **`shared-schemas/advisory.schema.json`** (2020-12, `additionalProperties:false`):
```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://plantapp.dev/schemas/advisory.schema.json",
  "title": "Advisory",
  "description": "A deterministic, profile-driven advisory surfaced for a PlantInstance. Never auto-creates a CareTask.",
  "type": "object",
  "additionalProperties": false,
  "required": ["kind", "severity", "plantInstanceId", "profileId", "title", "message"],
  "properties": {
    "kind": { "type": "string", "enum": ["container-size", "support", "pollination"] },
    "severity": { "type": "string", "enum": ["low", "medium", "high"] },
    "plantInstanceId": { "type": "string", "format": "uuid" },
    "profileId": { "type": "string" },
    "title": { "type": "string", "minLength": 1, "maxLength": 120 },
    "message": { "type": "string", "minLength": 1, "maxLength": 2000 },
    "details": { "type": "object", "additionalProperties": true },
    "createdAt": { "type": "string", "format": "date-time" }
  }
}
```
Run `cd backend && npm test` → all green (51 incl. the new advisory test). `npm run
validate-schemas` should also compile it. Commit + push.

### Forbidden
- No advisory **engine**, API endpoint, or Android code yet (S2.1–S2.3).
- Don't modify other schemas, the care-engine, migrations, existing tests, or the API.
- No new deps. Don't change the `@slice-2` `.feature` scenarios (they're the spec).

### Standalone verification
`cd backend && npm test` → RED on the advisory schema test at commit 1, GREEN (all,
incl. advisory) at commit 2; `npm run validate-schemas` passes; lint/typecheck unaffected.

### Final report
1. Two commit hashes + titles; final `origin/master` SHA.
2. `npm test` RED→GREEN counts; `npm run validate-schemas` result.
3. `git show --stat` per commit; confirm only the plan doc, the schema test, and
   `advisory.schema.json` were added; care-engine/other schemas/migrations/API untouched.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after S2.0 lands
Verify the plan doc + `advisory.schema.json` + green schema test. Then **S2.1**: the
deterministic `computeAdvisories(...)` engine (backend TS, pure; the 3 rules + the
no-auto-task invariant; pollination needs the count of the user's active instances of the
profile) — red-first unit tests covering the BDD rule cases and validating output against
`advisory.schema.json`; enrich the seed profiles with `idealMinLiters/idealMaxLiters` where
the container-size advisory cites an ideal range (e.g. passion fruit 95/190). Then S2.2 API
(`GET /plants/:id/advisories`, RLS, conformance-tested) and S2.3 Android display. Vision-check
each product-surface step.
