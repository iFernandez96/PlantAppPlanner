# Next Implementation Prompt — GREEN: implement computeInitialWaterTask

**Chosen:** `feat(care-engine): implement computeInitialWaterTask` — make the 8
red-first care-engine tests pass (Slice 1 plan #7–#14, formula D-10). Option B's
red step landed at `1d4e888` (tests fail with `is not a function`); this is the green.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `1d4e888` ==
`origin/master`, clean. `backend/care-engine/index.ts` is still `export {};`. Deps are
installed (`ce141da` committed `package-lock.json`; `node_modules` present), so
`npm test` runs: currently **47 tests, 8 failing** (the care-engine 8) + 39 schema
passing. Implementing the function turns the same command fully green with **no test
file change**.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are working in the **PlantApp** repo: `/home/israel/Documents/Development/PlantApp`
(branch `master`). Implement the Slice 1 deterministic watering engine so the
existing red-first tests pass.

### Scope (exactly one logical change)
Replace the placeholder `backend/care-engine/index.ts` (`export {};`) with an
implementation of `computeInitialWaterTask`. Nothing else.

### Forbidden — do NOT
- Do **not** modify the test file
  `backend/tests/care-engine/compute-initial-water-task.test.ts` (it is the gate;
  make it pass as-is).
- Do **not** modify any schema, other test, `_helpers.ts`, `package.json`,
  `vitest.config.ts`, or `tsconfig.json`.
- Do **not** add dependencies (use the built-in `node:crypto`).
- Do **not** touch any other file.

### Exact file to write: `backend/care-engine/index.ts`
Use this implementation (it satisfies all 8 tests and the D-10 formula; you may keep
it verbatim):

```ts
// Slice 1 deterministic watering engine (decision D-10).
// Pure function: same inputs -> byte-equal output and identical inputsHash.
import { createHash } from 'node:crypto';

export interface ComputeInitialWaterTaskInput {
  id: string;
  clockUtc: string;
  plant: {
    id: string;
    profileId: string;
    containerId: string;
    gardenSpaceId: string;
    createdAt: string;
    lastWateredAt?: string;
  };
  profile: {
    id: string;
    version: number;
    commonNames: string[];
    wateringProfile: { baseIntervalDays: number };
    containerProfile: { recommendedMinLiters: number };
  };
  container: { id: string; volumeLiters: number };
  gardenSpace: { id: string };
}

export interface CareTaskSourceInputs {
  plantInstanceId: string;
  profileId: string;
  profileVersion: number;
  containerId: string;
  gardenSpaceId: string;
  clockUtc: string;
  wateringBaselineAt: string;
  weatherWindowRef: string | null;
  feedbackWindowRef: string | null;
}

export interface CareTask {
  id: string;
  plantInstanceId: string;
  kind: 'water';
  dueAt: string;
  priority: 'normal';
  rationale: string;
  engineVersion: string;
  inputsHash: string;
  sourceInputs: CareTaskSourceInputs;
  status: 'pending';
}

const ENGINE_VERSION = '0.1.0';
const DAY_MS = 86_400_000;

function clamp(n: number, lo: number, hi: number): number {
  return Math.min(hi, Math.max(lo, n));
}

/** Deterministic canonical JSON: recursively sorted object keys. */
function canonicalJson(value: unknown): string {
  if (value === null || typeof value !== 'object') return JSON.stringify(value);
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(',')}]`;
  const obj = value as Record<string, unknown>;
  const keys = Object.keys(obj).sort();
  return `{${keys.map((k) => `${JSON.stringify(k)}:${canonicalJson(obj[k])}`).join(',')}}`;
}

export function computeInitialWaterTask(input: ComputeInitialWaterTaskInput): CareTask {
  const { id, clockUtc, plant, profile, container, gardenSpace } = input;

  const wateringBaselineAt = plant.lastWateredAt ?? plant.createdAt;
  const baseIntervalDays = profile.wateringProfile.baseIntervalDays;
  const containerFactor = clamp(
    container.volumeLiters / profile.containerProfile.recommendedMinLiters,
    0.5,
    1.5,
  );
  const dueAt = new Date(
    new Date(wateringBaselineAt).getTime() + baseIntervalDays * containerFactor * DAY_MS,
  ).toISOString();

  const sourceInputs: CareTaskSourceInputs = {
    plantInstanceId: plant.id,
    profileId: profile.id,
    profileVersion: profile.version,
    containerId: container.id,
    gardenSpaceId: gardenSpace.id,
    clockUtc,
    wateringBaselineAt,
    weatherWindowRef: null,
    feedbackWindowRef: null,
  };

  const inputsHash = createHash('sha256').update(canonicalJson(sourceInputs)).digest('hex');

  const rationale = `${profile.commonNames[0]}: base interval ${baseIntervalDays}d adjusted by container factor ${containerFactor}; baseline ${wateringBaselineAt}`;

  return {
    id,
    plantInstanceId: plant.id,
    kind: 'water',
    dueAt,
    priority: 'normal',
    rationale,
    engineVersion: ENGINE_VERSION,
    inputsHash,
    sourceInputs,
    status: 'pending',
  };
}
```

### Baseline precondition (STOP if it doesn't match)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin
git rev-parse --abbrev-ref HEAD     # expect: master
git rev-parse HEAD                   # expect: 1d4e888769f4f982e0368ed41e723416b1b91dea
git rev-parse origin/master          # expect: same
git status --short                   # expect: empty
test -d backend/node_modules && echo deps-present || echo DEPS-MISSING   # expect: deps-present
```
If HEAD isn't `1d4e888`, the tree is dirty, or deps are missing, STOP and report.

### Standalone verification (GREEN)
```bash
cd /home/israel/Documents/Development/PlantApp/backend && npm test
```
- **Before** your change: 47 tests, **8 failing** (`computeInitialWaterTask is not a
  function`).
- **After** your change: **all 47 pass** (7 files; the 8 care-engine tests now green,
  39 schema tests still green); `npm test` exits 0.
- This is **green** verification: the same command that was red is now green, with the
  test file unchanged. If anything other than the 8 turning green happens (e.g. a
  schema test breaks), STOP and report — do not edit the test to force it.

### Commit (exact title)
```bash
git -C /home/israel/Documents/Development/PlantApp add backend/care-engine/index.ts
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(care-engine): implement computeInitialWaterTask"
```

### Push (required)
```bash
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. `git show --stat HEAD` (expect **1 file changed**: `backend/care-engine/index.ts`).
2. The `npm test` summary proving all 47 pass (8 care-engine now green).
3. Confirmation the **test file is unchanged** and no other file/dep changed.
4. New commit hash + title; new `origin/master` SHA.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify all 47 green on `origin/master`, then assess Slice 1 DOD: the next steps are
the seed `PlantProfile` records + the repository/API integration tests (#15–#20) and
the Android UI tests (#21–#24) — backend-first. Write the next prompt accordingly, or
stop and ask the owner if a scope decision is needed (e.g. whether to stand up a local
Postgres for the integration tests — that would need owner approval).
