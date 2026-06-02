# Next Implementation Prompt — Slice 1 seed PlantProfile catalog (red→green)

**Chosen:** add the 5 Slice 1 seed `PlantProfile` records + a red-first integration
test that each validates against `plant-profile.schema.json` **and** that
`computeInitialWaterTask` emits a `CareTask` that validates against
`care-task.schema.json` for each. Approval-free (Ajv + `node` only; no DB, no new deps).

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `25f1dbb` ==
`origin/master`, clean; deps installed; `npm test` = 47/47 green. Engine
(`computeInitialWaterTask`) is implemented and exported.

This is a **two-commit** handoff: (1) red — placeholder catalog + the test (fails);
(2) green — fill the catalog (passes).

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are working in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, branch
`master`). Add the Slice 1 seed plant catalog and its red-first test.

### Baseline precondition (STOP if it doesn't match)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin
git rev-parse HEAD            # expect 25f1dbb0ae1a45549714c0411c04145532d142de
git rev-parse origin/master   # expect same
git status --short            # expect empty
test -d backend/node_modules && echo deps-present || echo DEPS-MISSING
```

### Forbidden — do NOT
- Do not modify `backend/care-engine/index.ts` (the engine), any schema, any existing
  test, `backend/tests/schema/_helpers.ts`, `package.json`, `vitest.config.ts`, or
  `tsconfig.json`.
- Do not add dependencies. Do not touch any other file.
- Two new files only: `backend/care-engine/seed-profiles.ts` and
  `backend/tests/care-engine/seed-catalog.test.ts`.

---

### COMMIT 1 (red) — `test(care-engine): add Slice 1 seed-catalog failing tests`

Create `backend/care-engine/seed-profiles.ts` as an empty placeholder:
```ts
// Slice 1 seed PlantProfile catalog. Placeholder — the 5 profiles land in the
// green commit. Shape mirrors shared-schemas/plant-profile.schema.json (subset used
// by the engine + the seed-catalog test).
export interface SeedPlantProfile {
  id: string;
  scientificName: string;
  commonNames: string[];
  category: string;
  growthHabit: string;
  requiresSupport?: boolean;
  selfFruitful?: boolean | null;
  pollinationPartnersRequired?: number;
  wateringProfile: { baseIntervalDays: number; dryingTolerance: string };
  feedingProfile: { baseIntervalDays: number; fruitingIntervalDays?: number; postHarvestIntervalDays?: number };
  containerProfile: { recommendedMinLiters: number };
  lightProfile: { targetSunHours: number };
  temperatureProfile: { frostSensitive: boolean };
  version: number;
}

export const seedProfiles: SeedPlantProfile[] = [];
```

Create `backend/tests/care-engine/seed-catalog.test.ts`:
```ts
// Slice 1 seed-catalog integration test. RED-FIRST: seed-profiles.ts starts empty,
// so "contains the 5 seed profiles" fails until the catalog is filled (green commit).
// Loads modules via dynamic import so a missing export can't abort suite collection.
import { describe, it, expect, beforeAll } from 'vitest';
import type { ValidateFunction } from 'ajv';
import { compileSchema } from '../schema/_helpers.js';

interface SeedProfile {
  id: string;
  version: number;
  commonNames: string[];
  wateringProfile: { baseIntervalDays: number };
  containerProfile: { recommendedMinLiters: number };
  [k: string]: unknown;
}
type WaterEngine = (input: unknown) => Record<string, unknown>;

let seedProfiles: SeedProfile[];
let computeInitialWaterTask: WaterEngine;
let validateProfile: ValidateFunction;
let validateCareTask: ValidateFunction;

beforeAll(async () => {
  seedProfiles = ((await import('../../care-engine/seed-profiles.js')) as { seedProfiles: SeedProfile[] }).seedProfiles;
  computeInitialWaterTask = ((await import('../../care-engine/index.js')) as { computeInitialWaterTask: WaterEngine }).computeInitialWaterTask;
  validateProfile = compileSchema('plant-profile');
  validateCareTask = compileSchema('care-task');
});

const PLANT_ID = '00000000-0000-4000-8000-000000000001';
const CONTAINER_ID = '00000000-0000-4000-8000-000000000002';
const SPACE_ID = '00000000-0000-4000-8000-000000000003';
const TASK_ID = '00000000-0000-4000-8000-0000000000aa';
const CLOCK = '2026-05-26T07:00:00.000Z';

const EXPECTED_IDS = [
  'fragaria-x-ananassa',
  'ocimum-basilicum',
  'passiflora-edulis',
  'physalis-philadelphica',
  'solanum-lycopersicum',
];

describe('Slice 1 seed catalog', () => {
  it('contains the 5 Slice 1 seed profiles', () => {
    expect(seedProfiles).toHaveLength(5);
    expect(seedProfiles.map((p) => p.id).sort()).toEqual([...EXPECTED_IDS].sort());
  });

  it('each seed profile validates against plant-profile.schema.json', () => {
    for (const p of seedProfiles) {
      const ok = validateProfile(p);
      expect(validateProfile.errors ?? []).toEqual([]);
      expect(ok).toBe(true);
    }
  });

  it('computeInitialWaterTask emits a schema-valid CareTask for each seed profile', () => {
    for (const p of seedProfiles) {
      const task = computeInitialWaterTask({
        id: TASK_ID,
        clockUtc: CLOCK,
        plant: {
          id: PLANT_ID,
          profileId: p.id,
          containerId: CONTAINER_ID,
          gardenSpaceId: SPACE_ID,
          createdAt: CLOCK,
          lastWateredAt: CLOCK,
        },
        profile: p,
        container: { id: CONTAINER_ID, volumeLiters: 19 },
        gardenSpace: { id: SPACE_ID },
      });
      const ok = validateCareTask(task);
      expect(validateCareTask.errors ?? []).toEqual([]);
      expect(ok).toBe(true);
    }
  });
});
```

Run it and confirm RED:
```bash
cd /home/israel/Documents/Development/PlantApp/backend && npm test
```
Expected: the new `seed-catalog` test FAILS on "contains the 5 seed profiles"
(`seedProfiles` is empty); the other 47 tests still pass. `npm test` exits non-zero.

Commit + push:
```bash
git -C /home/israel/Documents/Development/PlantApp add backend/care-engine/seed-profiles.ts backend/tests/care-engine/seed-catalog.test.ts
git -C /home/israel/Documents/Development/PlantApp commit -m "test(care-engine): add Slice 1 seed-catalog failing tests"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

---

### COMMIT 2 (green) — `feat(care-engine): add Slice 1 seed PlantProfile catalog`

Replace `backend/care-engine/seed-profiles.ts`'s array with the 5 seed profiles (keep
the `SeedPlantProfile` interface above it unchanged):
```ts
export const seedProfiles: SeedPlantProfile[] = [
  {
    id: 'passiflora-edulis',
    scientificName: 'Passiflora edulis',
    commonNames: ['Passion fruit', 'Maracujá'],
    category: 'fruit',
    growthHabit: 'climbing',
    requiresSupport: true,
    selfFruitful: true,
    wateringProfile: { baseIntervalDays: 3, dryingTolerance: 'medium' },
    feedingProfile: { baseIntervalDays: 14 },
    containerProfile: { recommendedMinLiters: 95 },
    lightProfile: { targetSunHours: 6 },
    temperatureProfile: { frostSensitive: true },
    version: 1,
  },
  {
    id: 'solanum-lycopersicum',
    scientificName: 'Solanum lycopersicum',
    commonNames: ['Tomato'],
    category: 'fruit',
    growthHabit: 'vine',
    requiresSupport: true,
    selfFruitful: true,
    wateringProfile: { baseIntervalDays: 2, dryingTolerance: 'low' },
    feedingProfile: { baseIntervalDays: 7, fruitingIntervalDays: 5 },
    containerProfile: { recommendedMinLiters: 19 },
    lightProfile: { targetSunHours: 8 },
    temperatureProfile: { frostSensitive: true },
    version: 1,
  },
  {
    id: 'physalis-philadelphica',
    scientificName: 'Physalis philadelphica',
    commonNames: ['Tomatillo'],
    category: 'fruit',
    growthHabit: 'bush',
    selfFruitful: false,
    pollinationPartnersRequired: 2,
    wateringProfile: { baseIntervalDays: 3, dryingTolerance: 'medium' },
    feedingProfile: { baseIntervalDays: 10 },
    containerProfile: { recommendedMinLiters: 19 },
    lightProfile: { targetSunHours: 7 },
    temperatureProfile: { frostSensitive: true },
    version: 1,
  },
  {
    id: 'fragaria-x-ananassa',
    scientificName: 'Fragaria x ananassa',
    commonNames: ['Strawberry'],
    category: 'berry',
    growthHabit: 'rosette',
    selfFruitful: true,
    wateringProfile: { baseIntervalDays: 2, dryingTolerance: 'low' },
    feedingProfile: { baseIntervalDays: 14, postHarvestIntervalDays: 21 },
    containerProfile: { recommendedMinLiters: 4 },
    lightProfile: { targetSunHours: 6 },
    temperatureProfile: { frostSensitive: false },
    version: 1,
  },
  {
    id: 'ocimum-basilicum',
    scientificName: 'Ocimum basilicum',
    commonNames: ['Basil'],
    category: 'herb',
    growthHabit: 'bush',
    selfFruitful: true,
    wateringProfile: { baseIntervalDays: 1.5, dryingTolerance: 'low' },
    feedingProfile: { baseIntervalDays: 14 },
    containerProfile: { recommendedMinLiters: 3 },
    lightProfile: { targetSunHours: 6 },
    temperatureProfile: { frostSensitive: true },
    version: 1,
  },
];
```

### Standalone verification (GREEN)
```bash
cd /home/israel/Documents/Development/PlantApp/backend && npm test
```
Expected: **all tests pass** (the 3 seed-catalog tests now green; the previous 47 still
green); `npm test` exits 0. If a seed profile fails schema validation or the CareTask
fails `care-task.schema.json`, STOP and report the Ajv errors verbatim — do not weaken
the test or the schema.

Commit + push:
```bash
git -C /home/israel/Documents/Development/PlantApp add backend/care-engine/seed-profiles.ts
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(care-engine): add Slice 1 seed PlantProfile catalog"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. Both commit hashes + titles; final `origin/master` SHA.
2. Commit 1 `npm test` output showing the seed-catalog RED; commit 2 output showing all
   GREEN (state the total test count).
3. `git show --stat` for each commit (commit 1: 2 new files; commit 2: 1 file changed).
4. Confirm no engine/schema/existing-test/`package.json` change and no new deps.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify both commits + all-green on `origin/master`, then proceed to **A** (owner
pre-approved): the repository/API integration tests #15–#20 (`POST /plants` emits the
CareTask, RLS, etc.) against a local Postgres/Supabase test DB. The planner will design
that handoff (DB-up approach via the Supabase CLI per ADR/D-03, the endpoints, red-first
tests) and only stop to ask the owner if the local DB environment isn't available.
