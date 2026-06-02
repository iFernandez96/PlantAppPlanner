# Next Implementation Prompt — S2.1: computeAdvisories engine (red→green)

**Slice 2, step S2.1.** The deterministic, profile-driven `computeAdvisories` engine
(backend TS, pure) — container-size / support / pollination — with red-first unit tests
covering the `@slice-2` rule cases, output validated against `advisory.schema.json`.
**Advisories never create CareTasks** (the `@invariant`). No API/Android/seed/migration
changes (S2.2+).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `06f581d` == `origin/master`,
clean. `advisory.schema.json` + the Slice 2 plan exist; `npm test` 61/61. The engine
`backend/care-engine/index.ts` (`computeInitialWaterTask`) is unrelated and untouched.

Two commits: (1) red engine tests; (2) green `computeAdvisories`.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add the
deterministic advisory engine. Pure function; no I/O, no `Date.now`/random.

### Baseline precondition (STOP if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect 06f581d029e191992214a1cd3ee0da0514c345e9
git status --short                         # expect empty
```

### Contract these tests pin
```ts
interface ComputeAdvisoriesInput {
  plant: { id: string; profileId: string; supportRecorded?: boolean };
  profile: {
    id: string;
    commonNames: string[];
    requiresSupport?: boolean;
    selfFruitful?: boolean | null;
    pollinationPartnersRequired?: number;
    containerProfile: { recommendedMinLiters: number; idealMinLiters?: number; idealMaxLiters?: number };
  };
  container: { volumeLiters: number };
  profileInstanceCount: number; // # of the caller's active instances of this profile
}
// export function computeAdvisories(input): Advisory[]   // 0..3 advisories
```
Rules (each emitted advisory must validate against `shared-schemas/advisory.schema.json`):
- **container-size** (`severity: "high"`): when `container.volumeLiters <
  profile.containerProfile.recommendedMinLiters`. Message cites the recommended minimum and
  the ideal range **when present**, and suggests target **sizes, not a brand**. `details`:
  currentVolumeLiters, recommendedMinLiters, ideal min/max if present.
- **support** (`severity: "medium"`): when `profile.requiresSupport === true &&
  plant.supportRecorded !== true`.
- **pollination** (`severity: "medium"`): when `profile.selfFruitful === false &&
  profileInstanceCount < (profile.pollinationPartnersRequired ?? 0)`. Message explains it's
  not self-fruitful and recommends a second compatible plant; cleared (not emitted) when
  the count meets the requirement.
- **Invariant:** the function returns `Advisory[]` only — it must never create or reference
  a `CareTask`.

### COMMIT 1 (RED) — `test(care-engine): add Slice 2 advisory-engine failing tests`
Create `backend/tests/care-engine/compute-advisories.test.ts`. Load the engine via a
**dynamic import in `beforeAll`** (so a missing export fails per-test, not at collection —
same pattern as the watering-engine tests). Compile the advisory schema via
`compileSchema('advisory')` from `../schema/_helpers.js`. Cover:
- container-size: passion-fruit-like profile (`recommendedMinLiters: 95, idealMinLiters: 95,
  idealMaxLiters: 190`) in a 19 L container → exactly one `container-size` advisory,
  `severity: "high"`, message contains `95` and `190`, and the advisory **validates against
  the schema**; a 95 L (or larger) container → no container-size advisory.
- support: `requiresSupport: true` + no `supportRecorded` → one `support` advisory;
  `supportRecorded: true` → none.
- pollination: tomatillo-like (`selfFruitful: false, pollinationPartnersRequired: 2`) with
  `profileInstanceCount: 1` → one `pollination` advisory (message mentions not self-fruitful);
  `profileInstanceCount: 2` → none (cleared).
- invariant/determinism: result is an array of advisories (no CareTask shape), equal inputs
  → equal output; every advisory validates against `advisory.schema.json`.
Run `cd backend && npm test` → the new tests fail red (`computeAdvisories is not a function`);
the prior 61 pass. Commit + push.

### COMMIT 2 (GREEN) — `feat(care-engine): add deterministic advisory engine (Slice 2)`
Create `backend/care-engine/advisories.ts` exporting `Advisory`,
`ComputeAdvisoriesInput`, and `computeAdvisories(input): Advisory[]` implementing the three
rules above (pure; `commonNames[0] ?? profile.id` for the display name; omit absent optional
`details` keys). Then `cd backend && npm test` → all green (61 + new). Commit + push.

### Forbidden
- No API endpoint, Android, or seed/migration changes (S2.2 does the `GET
  /plants/:id/advisories` endpoint + enriches the seed/DB with `idealMin/MaxLiters`).
- Don't modify `computeInitialWaterTask`, `advisory.schema.json`, other schemas, migrations,
  the API, or existing tests. No new deps. Don't touch the `@slice-2` `.feature` files.
- Do NOT make the engine create/return CareTasks (invariant).

### Standalone verification
`cd backend && npm test` → RED on the advisory-engine tests at commit 1, GREEN (all) at
commit 2. Lint/typecheck unaffected.

### Final report
1. Two commit hashes + titles; final `origin/master` SHA.
2. `npm test` RED→GREEN counts; confirm each advisory validates against the schema in tests.
3. `git show --stat` per commit; confirm only the new engine + test files; care-engine
   `index.ts`/schemas/migrations/API/seed untouched.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after S2.1 lands
Verify the engine + schema-valid advisories. Then **S2.2**: `GET /plants/:id/advisories`
(loads the plant/profile/container + the caller's instance count for the profile, calls
`computeAdvisories`, returns schema-conformant `Advisory[]`; RLS-scoped) + integration tests
mapping the BDD scenarios (passion fruit → container-size high; lone tomatillo →
pollination; second tomatillo → cleared; support); enrich the seed catalog + a new
migration adding `idealMinLiters/idealMaxLiters` to `plant_profiles` (e.g. passion fruit
95/190). Then S2.3 Android display. Also: a small `validate-schemas` tooling-hygiene
handoff (add `-c ajv-formats` + `type:"array"` in diagnosis-result) to make that gate green.
