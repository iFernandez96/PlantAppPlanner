# Next Implementation Prompt

**Chosen:** Option B — red-first care-engine unit tests for `computeInitialWaterTask`
(Slice 1 plan tests #7–#14; formula D-10). Option A (`b2836ca`) is landed +
planner-verified.

**Red-first discipline:** these tests are added **before** the engine exists.
`backend/care-engine/index.ts` stays the placeholder `export {};` — the tests
import a not-yet-implemented `computeInitialWaterTask`, so they fail red. The
engine implementation is a **separate later commit** (`feat(care-engine): …`), not
this one.

**Verified baseline (2026-05-31):** PlantApp on `master`, HEAD `b2836ca` ==
`origin/master`, clean. Field names grounded against the real schemas:
`profile.wateringProfile.baseIntervalDays`, `profile.containerProfile.recommendedMinLiters`,
`container.volumeLiters`, `plant.createdAt`/`lastWateredAt`, CareTask `sourceInputs`
(incl. `wateringBaselineAt`).

> ⚠️ **OPEN DECISION — read first.** This pasteable prompt is the **no-install**
> variant: it adds the failing test file but does **not** run it (`npm test` would
> say `vitest: not found` because `node_modules` is absent and `npm install` is not
> approved). The "red" is therefore *structural* — `computeInitialWaterTask` is
> `undefined` at runtime. If you want a **true executed red** (recommended), see
> **"Install variant"** at the bottom; the planner will reissue a two-commit prompt.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are working in the **PlantApp** repo: `/home/israel/Documents/Development/PlantApp`
(branch `master`, GitHub `iFernandez96/PlantApp`).

Add **red-first** unit tests for the Slice 1 deterministic watering engine
function `computeInitialWaterTask`. The function does **not** exist yet — these
tests define its contract and must fail. Do **not** implement the function in this
commit.

### Scope (exactly one logical change)
- Add **one new test file**: `backend/tests/care-engine/compute-initial-water-task.test.ts`.
- Nothing else.

### Forbidden — do NOT
- Do **not** implement `computeInitialWaterTask`. Leave `backend/care-engine/index.ts`
  exactly as it is (`export {};`). The failing import IS the intended red.
- Do **not** modify any schema, any existing test, `_helpers.ts`, `package.json`,
  `vitest.config.ts`, or any other file.
- Do **not** run `npm install` / `npm test` / `vitest` / builds / migrations.
  (No deps are installed; running is out of scope for this commit — see "Expected
  failure mode" below.)
- Do **not** add new dependencies.

### Baseline precondition (STOP if it doesn't match)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin
git rev-parse --abbrev-ref HEAD     # expect: master
git rev-parse HEAD                   # expect: b2836ca7ff4d65020f1d385d38940cf8652db459
git rev-parse origin/master          # expect: same
git status --short                   # expect: empty
cat backend/care-engine/index.ts     # expect: comment + `export {};` (placeholder)
```
If HEAD is not `b2836ca`, the tree is dirty, or `care-engine/index.ts` is no longer
a placeholder, STOP and report — this prompt is stale.

### The contract these tests pin
`computeInitialWaterTask` is a **pure function**. The caller supplies the task `id`
and the clock, so output is fully deterministic (no internal randomness/`Date.now`):

```ts
interface ComputeInitialWaterTaskInput {
  id: string;            // CareTask.id (uuid), caller-supplied
  clockUtc: string;      // ISO-8601 date-time — the engine's "now"
  plant: {
    id: string;          // PlantInstance.id (uuid)
    profileId: string;
    containerId: string;
    gardenSpaceId: string;
    createdAt: string;        // ISO-8601 date-time
    lastWateredAt?: string;   // optional ISO-8601 date-time (onboarding baseline)
  };
  profile: {
    id: string;
    version: number;          // integer >= 1 → sourceInputs.profileVersion
    commonNames: string[];    // commonNames[0] used in the rationale
    wateringProfile: { baseIntervalDays: number };
    containerProfile: { recommendedMinLiters: number };
  };
  container: { id: string; volumeLiters: number };
  gardenSpace: { id: string };
}
// export function computeInitialWaterTask(input: ComputeInitialWaterTaskInput): CareTask
```

D-10 formula the tests encode (interval × factor is in **days**):
```
wateringBaselineAt = plant.lastWateredAt ?? plant.createdAt
containerFactor    = clamp(container.volumeLiters / profile.containerProfile.recommendedMinLiters, 0.5, 1.5)
dueAt              = wateringBaselineAt + (profile.wateringProfile.baseIntervalDays × containerFactor) days
priority           = "normal"     engineVersion = "0.1.0"     status = "pending"
sourceInputs       = { plantInstanceId, profileId, profileVersion, containerId,
                       gardenSpaceId, clockUtc, wateringBaselineAt,
                       weatherWindowRef: null, feedbackWindowRef: null }
inputsHash         = sha256(canonical-json(sourceInputs))
rationale          = "<commonNames[0]>: base interval <baseIntervalDays>d adjusted by container factor <containerFactor>; baseline <wateringBaselineAt>"
```

### Create exactly this file
`backend/tests/care-engine/compute-initial-water-task.test.ts` with the following
content (you may keep it verbatim; it is the deliverable):

```ts
// Care-engine red-first tests (per docs/slice-01-implementation-plan.md tests #7–#14,
// formula D-10 in docs/slice-01-decision-log.md).
//
// RED-FIRST: computeInitialWaterTask is intentionally NOT implemented yet.
// backend/care-engine/index.ts is still `export {};`, so the import below is
// undefined and these tests fail. The engine implementation is a separate,
// later commit — do not implement it here to make these pass.
import { describe, it, expect } from 'vitest';
// @ts-expect-error — not implemented yet (red-first); export lands in a later commit.
import { computeInitialWaterTask } from '../../care-engine/index.js';

const DAY_MS = 86_400_000;

const tomatoProfile = {
  id: 'solanum-lycopersicum',
  version: 1,
  commonNames: ['Tomato'],
  wateringProfile: { baseIntervalDays: 2 },
  containerProfile: { recommendedMinLiters: 19 },
};
const passionProfile = {
  id: 'passiflora-edulis',
  version: 1,
  commonNames: ['Passion fruit'],
  wateringProfile: { baseIntervalDays: 3 },
  containerProfile: { recommendedMinLiters: 95 },
};

const container19 = { id: '00000000-0000-4000-8000-000000000002', volumeLiters: 19 };   // tomato ratio 1.0 → factor 1.0
const containerBig = { id: '00000000-0000-4000-8000-000000000002', volumeLiters: 100 };  // tomato ratio 5.26 → clamp 1.5
const gardenSpace = { id: '00000000-0000-4000-8000-000000000003' };

const basePlant = {
  id: '00000000-0000-4000-8000-000000000001',
  profileId: 'solanum-lycopersicum',
  containerId: container19.id,
  gardenSpaceId: gardenSpace.id,
  createdAt: '2026-05-26T07:00:00.000Z',
};

const baseline = '2026-05-26T07:00:00.000Z';

function tomatoInput(overrides = {}) {
  return {
    id: 'task-1',
    clockUtc: baseline,
    plant: { ...basePlant, lastWateredAt: baseline },
    profile: tomatoProfile,
    container: container19,
    gardenSpace,
    ...overrides,
  };
}

describe('computeInitialWaterTask — Slice 1 (red-first)', () => {
  it('#7 returns one water CareTask', () => {
    const task = computeInitialWaterTask(tomatoInput());
    expect(task.kind).toBe('water');
    expect(task.id).toBe('task-1');
    expect(task.plantInstanceId).toBe(basePlant.id);
    expect(task.status).toBe('pending');
  });

  it('#8 carries engineVersion, inputsHash, sourceInputs, rationale, dueAt, priority', () => {
    const task = computeInitialWaterTask(tomatoInput());
    expect(task.engineVersion).toBe('0.1.0');
    expect(task.priority).toBe('normal');
    expect(typeof task.inputsHash).toBe('string');
    expect(task.inputsHash.length).toBeGreaterThanOrEqual(8);
    expect(task.rationale).toContain('Tomato');
    expect(task.rationale).toContain(baseline);
    expect(task.sourceInputs).toMatchObject({
      plantInstanceId: basePlant.id,
      profileId: 'solanum-lycopersicum',
      profileVersion: 1,
      containerId: container19.id,
      gardenSpaceId: gardenSpace.id,
      clockUtc: baseline,
      wateringBaselineAt: baseline,
      weatherWindowRef: null,
      feedbackWindowRef: null,
    });
    expect(typeof task.dueAt).toBe('string');
  });

  it('#9 is deterministic: equal inputs → byte-equal output and identical inputsHash', () => {
    const a = computeInitialWaterTask(tomatoInput());
    const b = computeInitialWaterTask(JSON.parse(JSON.stringify(tomatoInput())));
    expect(b).toEqual(a);
    expect(JSON.stringify(b)).toBe(JSON.stringify(a));
    expect(b.inputsHash).toBe(a.inputsHash);
  });

  it('#10 clamps container factor to [0.5, 1.5]', () => {
    // below 0.5: passion fruit (recMin 95) in a 19 L container → 0.2 → clamp 0.5
    const low = computeInitialWaterTask({
      id: 't', clockUtc: baseline,
      plant: { ...basePlant, profileId: passionProfile.id, lastWateredAt: baseline },
      profile: passionProfile, container: container19, gardenSpace,
    });
    expect(new Date(low.dueAt).getTime() - new Date(baseline).getTime()).toBe(3 * 0.5 * DAY_MS);

    // above 1.5: tomato (recMin 19) in a 100 L container → 5.26 → clamp 1.5
    const high = computeInitialWaterTask(tomatoInput({ container: containerBig }));
    expect(new Date(high.dueAt).getTime() - new Date(baseline).getTime()).toBe(2 * 1.5 * DAY_MS);
  });

  it('#11 later clockUtc (same baseline) → different inputsHash but SAME dueAt', () => {
    const early = computeInitialWaterTask(tomatoInput({ clockUtc: '2026-05-26T07:00:00.000Z' }));
    const later = computeInitialWaterTask(tomatoInput({ clockUtc: '2026-05-27T09:30:00.000Z' }));
    expect(later.dueAt).toBe(early.dueAt);                 // anchored on wateringBaselineAt, not the clock
    expect(later.inputsHash).not.toBe(early.inputsHash);   // clockUtc is part of sourceInputs
  });

  it('#12 baseline supplied: wateringBaselineAt === lastWateredAt; dueAt = lastWateredAt + interval×factor', () => {
    const lw = '2026-05-20T12:00:00.000Z';
    const task = computeInitialWaterTask(tomatoInput({ plant: { ...basePlant, lastWateredAt: lw } }));
    expect(task.sourceInputs.wateringBaselineAt).toBe(lw);
    expect(new Date(task.dueAt).getTime() - new Date(lw).getTime()).toBe(2 * 1.0 * DAY_MS);
  });

  it('#13 baseline fallback: no lastWateredAt → wateringBaselineAt === createdAt', () => {
    const plantNoLW = { ...basePlant }; // createdAt = baseline; no lastWateredAt
    const task = computeInitialWaterTask({
      id: 't', clockUtc: '2026-05-30T00:00:00.000Z',
      plant: plantNoLW, profile: tomatoProfile, container: container19, gardenSpace,
    });
    expect(task.sourceInputs.wateringBaselineAt).toBe(plantNoLW.createdAt);
    expect(new Date(task.dueAt).getTime() - new Date(plantNoLW.createdAt).getTime()).toBe(2 * 1.0 * DAY_MS);
  });

  it('#14 different lastWateredAt → different inputsHash AND different dueAt', () => {
    const t1 = computeInitialWaterTask(tomatoInput({ plant: { ...basePlant, lastWateredAt: '2026-05-20T12:00:00.000Z' } }));
    const t2 = computeInitialWaterTask(tomatoInput({ plant: { ...basePlant, lastWateredAt: '2026-05-22T12:00:00.000Z' } }));
    expect(t2.inputsHash).not.toBe(t1.inputsHash);
    expect(t2.dueAt).not.toBe(t1.dueAt);
  });
});
```

### Expected failure mode (this is success for a red-first commit)
- `npm test` is **not run** and would print `vitest: not found` (deps not installed;
  installing is out of scope). Do not try to make it runnable.
- The test exists, imports the unimplemented `computeInitialWaterTask`, and would
  fail (the import is `undefined` → calling it throws). The `@ts-expect-error` marks
  the intentionally-missing export so a typecheck wouldn't flag it as an unexpected
  error. This is the intended red state.

### Commit (exact title)
```bash
git -C /home/israel/Documents/Development/PlantApp add backend/tests/care-engine/compute-initial-water-task.test.ts
git -C /home/israel/Documents/Development/PlantApp commit -m "test(care-engine): add Slice 1 watering-engine failing tests"
```

### Push (required)
```bash
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report back to the owner
1. The new file path + full contents committed.
2. `git show --stat HEAD` (expect **1 file changed**, only the new test file).
3. Confirmation that `backend/care-engine/index.ts` is unchanged (still `export {};`)
   and no other file was touched.
4. New commit hash + title; new `origin/master` SHA after push.
5. Confirmation that no install/build/test/migration command was run.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Install variant (if the owner approves `npm install`)

If the owner approves installing backend deps so the tests truly execute red, the
planner will reissue this as **two commits**:
1. `chore(backend): install dependencies and commit lockfile` — run
   `npm install` in `backend/` (creates `node_modules`, already git-ignored; commit
   `package-lock.json`). After this, `npm test` runs.
2. `test(care-engine): add Slice 1 watering-engine failing tests` — add the file
   above, run `cd backend && npm test` to **confirm it fails red** (8 failing tests,
   `computeInitialWaterTask is not a function`), then commit.
   Remove the `@ts-expect-error` only if it causes an "unused directive" error under
   the runner; otherwise leave it.

## Planner follow-up after Option B lands
1. Re-fetch PlantApp; confirm the new test file is on `origin/master` and the engine
   is still a placeholder (red-first intact).
2. Update `state/*`, `reviews/latest-repo-review.md`, `github-checks/…`.
3. Write the **green** prompt: `feat(care-engine): implement computeInitialWaterTask`
   (sha256 + canonical-JSON of `sourceInputs`, the D-10 formula, returning a
   schema-valid `CareTask`) so these 8 tests pass.
