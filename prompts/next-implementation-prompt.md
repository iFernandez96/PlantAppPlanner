# Next Implementation Prompt

**Chosen:** Option B — red-first care-engine tests for `computeInitialWaterTask`
(Slice 1 plan tests #7–#14; formula D-10). **Install approved** by owner on
2026-05-31 ("Install + commit lockfile"), so this is the **two-commit** variant:
(1) install deps + commit lockfile, (2) add the failing tests and run them to
confirm a true executed red.

**Red-first discipline:** the engine does not exist yet. `backend/care-engine/index.ts`
stays the placeholder `export {};`. The tests import the unimplemented
`computeInitialWaterTask`, so they must fail. Implementing the engine is a
**separate later commit** (`feat(care-engine): …`), not this one.

**Verified baseline (2026-05-31):** PlantApp on `master`, HEAD `b2836ca` ==
`origin/master`, clean. `node_modules/` is git-ignored (`backend/.gitignore:1`),
so installing produces only `backend/package-lock.json` as a new tracked file.
Field names grounded against the real schemas (`wateringProfile.baseIntervalDays`,
`containerProfile.recommendedMinLiters`, `container.volumeLiters`,
`plant.createdAt`/`lastWateredAt`, CareTask `sourceInputs`).

> ⚠️ **First-ever test run.** `vitest` has never been installed, so the existing
> schema tests have **never actually executed** — they were only committed
> red-first and "aligned" by inspection. Commit 1 below runs them for the first
> time to establish a green baseline. If any pre-existing test fails, **report it**
> (do not fix it here) — it's a separate finding for the planner.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are working in the **PlantApp** repo: `/home/israel/Documents/Development/PlantApp`
(branch `master`, GitHub `iFernandez96/PlantApp`).

This is **two commits**: (1) install backend dependencies and commit the lockfile,
(2) add red-first unit tests for the Slice 1 watering engine `computeInitialWaterTask`
and run them to confirm they fail red. **Do not implement the engine.**

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
If any of these don't match, STOP and report — this prompt is stale.

### Global forbidden — do NOT (applies to both commits)
- Do **not** implement `computeInitialWaterTask`. Leave `backend/care-engine/index.ts`
  exactly `export {};`. The failing import IS the intended red.
- Do **not** modify any schema, any existing test, `package.json`, `vitest.config.ts`,
  `tsconfig.json`, or `_helpers.ts`.
- Do **not** commit `node_modules/` (it is git-ignored — verify it does not appear
  in `git status`).
- Do **not** add dependencies beyond what `package.json` already declares — run a
  plain `npm install` (no `npm install <pkg>`), which must leave `package.json`
  unchanged.
- Do **not** run builds, migrations, or Supabase/DB/Gradle commands. The only
  commands you run are `npm install` and `npm test` (and read-only git).

---

### COMMIT 1 — `chore(backend): install dependencies and commit lockfile`

```bash
cd /home/israel/Documents/Development/PlantApp/backend
npm install
```
If `npm install` fails (e.g. no registry/network access), STOP and report the
error verbatim — do not proceed or fabricate.

Then establish the pre-existing-tests baseline (first ever run of vitest here):
```bash
cd /home/israel/Documents/Development/PlantApp/backend
npm test
```
Expected: the existing schema tests (`tests/schema/*.test.ts`) **pass**. Capture the
summary. If any pre-existing test fails, **record the output and report it** — do
not fix it in this commit (it's a separate planner finding).

Verify the only tracked change is the lockfile, then commit + push:
```bash
git -C /home/israel/Documents/Development/PlantApp status --short
# expect exactly: "?? backend/package-lock.json"  (node_modules NOT shown — ignored)
# package.json must be UNCHANGED. If it changed, STOP and report.
git -C /home/israel/Documents/Development/PlantApp add backend/package-lock.json
git -C /home/israel/Documents/Development/PlantApp commit -m "chore(backend): install dependencies and commit lockfile"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

---

### COMMIT 2 — `test(care-engine): add Slice 1 watering-engine failing tests`

#### The contract these tests pin
`computeInitialWaterTask` is a **pure function**; the caller supplies the task `id`
and clock, so output is fully deterministic (no internal randomness/`Date.now`):

```ts
interface ComputeInitialWaterTaskInput {
  id: string;            // CareTask.id (uuid), caller-supplied
  clockUtc: string;      // ISO-8601 date-time — the engine's "now"
  plant: {
    id: string; profileId: string; containerId: string; gardenSpaceId: string;
    createdAt: string;        // ISO-8601 date-time
    lastWateredAt?: string;   // optional ISO-8601 date-time (onboarding baseline)
  };
  profile: {
    id: string; version: number; commonNames: string[];
    wateringProfile: { baseIntervalDays: number };
    containerProfile: { recommendedMinLiters: number };
  };
  container: { id: string; volumeLiters: number };
  gardenSpace: { id: string };
}
// export function computeInitialWaterTask(input: ComputeInitialWaterTaskInput): CareTask
```

D-10 formula (interval × factor is in **days**):
```
wateringBaselineAt = plant.lastWateredAt ?? plant.createdAt
containerFactor    = clamp(container.volumeLiters / profile.containerProfile.recommendedMinLiters, 0.5, 1.5)
dueAt              = wateringBaselineAt + (baseIntervalDays × containerFactor) days
priority="normal"  engineVersion="0.1.0"  status="pending"
sourceInputs       = { plantInstanceId, profileId, profileVersion, containerId,
                       gardenSpaceId, clockUtc, wateringBaselineAt,
                       weatherWindowRef: null, feedbackWindowRef: null }
inputsHash         = sha256(canonical-json(sourceInputs))
rationale          = "<commonNames[0]>: base interval <baseIntervalDays>d adjusted by container factor <containerFactor>; baseline <wateringBaselineAt>"
```

#### Create exactly this file: `backend/tests/care-engine/compute-initial-water-task.test.ts`
```ts
// Care-engine red-first tests (per docs/slice-01-implementation-plan.md tests #7–#14,
// formula D-10 in docs/slice-01-decision-log.md).
//
// RED-FIRST: computeInitialWaterTask is intentionally NOT implemented yet.
// backend/care-engine/index.ts is still `export {};`, so the import below is
// undefined and these tests fail (computeInitialWaterTask is not a function).
// The engine implementation is a separate, later commit — do not implement it
// here to make these pass.
import { describe, it, expect } from 'vitest';
// @ts-expect-error — not implemented yet (red-first); the export lands in a later commit.
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

#### Run the tests — confirm RED
```bash
cd /home/israel/Documents/Development/PlantApp/backend
npm test
```
Expected: the **8 new** `computeInitialWaterTask` tests **FAIL** with
`TypeError: computeInitialWaterTask is not a function` (because the engine is still
`export {};`). `npm test` exits non-zero — that is the **desired red**. The
pre-existing schema tests should still pass. Do **not** implement the engine to make
the 8 pass. Confirm `backend/care-engine/index.ts` is still `export {};`.

#### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add backend/tests/care-engine/compute-initial-water-task.test.ts
git -C /home/israel/Documents/Development/PlantApp commit -m "test(care-engine): add Slice 1 watering-engine failing tests"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report back to the owner
1. **Commit 1:** the `npm test` baseline summary (did all pre-existing schema tests
   pass?); `git show --stat` for the lockfile commit (expect only
   `backend/package-lock.json`); confirmation `package.json` is unchanged and
   `node_modules/` is untracked.
2. **Commit 2:** the `npm test` output proving the 8 new tests fail red (with the
   `is not a function` error) and the rest pass; `git show --stat` (expect only the
   new test file); confirmation `care-engine/index.ts` is still `export {};`.
3. Both new commit hashes + titles; the final `origin/master` SHA.
4. Confirmation no other files changed and no forbidden command was run.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after Option B lands
1. Re-fetch PlantApp; confirm both commits on `origin/master`; confirm the engine is
   still a placeholder (red-first intact) and the 8 tests are present.
2. Note the now-verified state of the pre-existing schema tests (this is the first
   time they ran — record pass/fail in `state/current-state.md`).
3. Update `state/*`, `reviews/latest-repo-review.md`, `github-checks/…`.
4. Write the **green** prompt: `feat(care-engine): implement computeInitialWaterTask`
   (sha256 + canonical-JSON of `sourceInputs`, the D-10 formula, returning a
   schema-valid `CareTask`) so all 8 tests pass — and remove the `@ts-expect-error`
   line in the test (it becomes an unused directive once the export exists).
