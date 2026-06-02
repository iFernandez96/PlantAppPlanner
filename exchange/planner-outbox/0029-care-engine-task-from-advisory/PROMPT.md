# Next Implementation Prompt — backlog (3d-engine): deterministic `computeTaskFromAdvisory`

**Backlog item (3) UX follow-ups, step 3d (advisory → accept → CareTask), part 1 of N (engine).**
Add a **pure, deterministic** care-engine function that turns an *accepted* advisory into a
`CareTask` — the deterministic core for the accept flow. **This function is not wired to any
endpoint in this step** (the accept API is 3d-api). It computes a task object; it persists
nothing. The invariant ("advisories never *auto*-create CareTasks") is preserved: a task is only
ever produced when the future endpoint calls this on **explicit user acceptance**.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`e76ff8d9ce916bda6a7754cc400a2e7211000678` == `origin/master`, clean. `care-engine/index.ts` has
`computeInitialWaterTask` (the deterministic stamping pattern: `canonicalJson` + `sha256`
`inputsHash`, `ENGINE_VERSION = '0.1.0'`, no `Date.now`/randomness). `care-engine/advisories.ts`
`Advisory.kind ∈ {container-size, support, pollination}`. `shared-schemas/care-task.schema.json`
`kind` enum already includes `repot` and `support` (no schema change needed); `sourceInputs`
requires `plantInstanceId, profileId, profileVersion, containerId, gardenSpaceId, clockUtc,
wateringBaselineAt`. Care-engine tests live in `backend/tests/care-engine/` and use a **dynamic
import in `beforeAll`** (red-first) + validate output against the schema. Backend unit 67/67,
`validate-schemas` green.

Single logical change (the pure engine function) → one commit. Red-first.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add a pure
deterministic engine function `computeTaskFromAdvisory`. Red-first: write the test first
(dynamic import, so the suite doesn't abort at link time).

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect e76ff8d9ce916bda6a7754cc400a2e7211000678 == origin/master
git status --short                         # expect empty
```

### Scope — one new engine file
**`backend/care-engine/task-from-advisory.ts`** (new). A pure function (no I/O, no `Date.now`, no
randomness) mirroring `computeInitialWaterTask`'s determinism:
```ts
export interface ComputeTaskFromAdvisoryInput {
  id: string;                 // caller-supplied uuid for the new task
  clockUtc: string;           // ISO; the acceptance moment
  advisory: {
    kind: 'container-size' | 'support' | 'pollination';
    severity: 'low' | 'medium' | 'high';
    title: string;
    message: string;
  };
  plant: { id: string; profileId: string; containerId: string; gardenSpaceId: string };
  profile: { id: string; version: number };
}
export interface AdvisoryCareTask { /* conforms to care-task.schema.json */ ... }
export function computeTaskFromAdvisory(input: ComputeTaskFromAdvisoryInput): AdvisoryCareTask
```
Rules (deterministic):
- **kind mapping:** `container-size → 'repot'`, `support → 'support'`. For `'pollination'` (and any
  other), **throw** `new Error('unsupported advisory kind: <kind>')` — pollination is "grow another
  plant", not a single actionable CareTask; the 3d-api endpoint will translate the throw into HTTP 400.
- **priority** from severity: `low→'low'`, `medium→'normal'`, `high→'high'`.
- **dueAt** = `clockUtc` (actionable immediately on acceptance).
- **rationale** = `` `${advisory.title}: ${advisory.message}` `` (≤2000 chars).
- **rationaleMetadata** = `{ acceptedAdvisoryKind: advisory.kind }` (schema allows
  `additionalProperties: true`).
- **sourceInputs** = `{ plantInstanceId: plant.id, profileId: profile.id, profileVersion:
  profile.version, containerId: plant.containerId, gardenSpaceId: plant.gardenSpaceId, clockUtc,
  wateringBaselineAt: clockUtc, weatherWindowRef: null, feedbackWindowRef: null }`. (`sourceInputs`
  is water-centric but schema-required for every task; set `wateringBaselineAt = clockUtc` as the
  required placeholder and add a code comment saying so.)
- **inputsHash** = `sha256(canonicalJson({ kind, sourceInputs }))` — note this hashes `{kind,
  sourceInputs}` (not `sourceInputs` alone like the water engine) so accepting different advisory
  kinds for the same plant+clock yields distinct hashes; add a comment noting the intentional
  difference. Reuse a local `canonicalJson` copied from `index.ts` (with a comment pointing to it)
  — do **not** modify `index.ts`.
- **engineVersion** = `'0.1.0'`; **status** = `'pending'`.

### Tests — `backend/tests/care-engine/task-from-advisory.test.ts` (new)
Mirror `compute-initial-water-task.test.ts`: dynamic `import('../../care-engine/task-from-advisory.js')`
in `beforeAll`; validate output against `care-task.schema.json` using **`compileSchema('care-task')`
from `../schema/_helpers.ts`** — this is the same helper `tests/care-engine/seed-catalog.test.ts`
already uses from this exact directory (it resolves the repo-root `shared-schemas/`), so use it
directly; do not hand-roll a separate Ajv path. Cases:
- container-size (severity high) → `kind === 'repot'`, `priority === 'high'`, `dueAt === clockUtc`,
  `rationale` contains the message, `sourceInputs.plantInstanceId === plant.id`, and the result
  **validates** against `care-task.schema.json`.
- support (severity medium) → `kind === 'support'`, `priority === 'normal'`; validates.
- **determinism**: calling twice with identical input returns deep-equal objects incl. identical
  `inputsHash`; and the two task kinds for the same plant+clock produce **different** `inputsHash`.
- pollination (or any other kind) → **throws** `unsupported advisory kind`.

### Forbidden
- No change to `care-engine/index.ts`, `advisories.ts`, the API (`src/**`), migrations, schemas,
  Android, or any other test. No new dependency. No I/O / `Date.now` / randomness in the function.
  Do not wire this to any endpoint (that is 3d-api). Don't relax determinism.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/backend
npm test                     # new task-from-advisory tests pass; total > 67
npm run validate-schemas     # still green (no schema change)
npm run typecheck && npm run lint   # clean
```
Red→green: the new test fails before the function exists (dynamic import → `undefined` → per-test
failure), then passes. Report the before/after unit count + the new test names.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add backend/care-engine/task-from-advisory.ts backend/tests/care-engine/task-from-advisory.test.ts
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(care-engine): deterministic computeTaskFromAdvisory (accepted advisory -> CareTask)"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The function (kind/priority mapping, dueAt, sourceInputs/inputsHash decisions, the
   pollination-throws behavior).
2. `npm test` before→after count + new test names; `validate-schemas` green; typecheck + lint clean.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only the 2 new files
   changed.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only the 2 engine files; deterministic; pollination throws; output
schema-valid; `npm test` up, validate-schemas green). Then **3d-api**: `POST
/plants/:id/advisories/accept` (body `{ kind }`) — recompute advisories for the plant (RLS-scoped,
404 if not owned), find the matching currently-applicable advisory (400 if absent/unsupported),
call `computeTaskFromAdvisory`, **persist** a `care_tasks` row (like the add-plant flow), return the
created CareTask; integration tests incl. **GET advisories still creates nothing** (invariant) +
RLS + pollination/absent → 400. Then the **Android** accept action (`:network` `acceptAdvisory` +
`:data` + a detail-screen "Accept" button → shows the created task). Then (2) emulator e2e smoke;
then (4) Slice 3 (WorkManager local first; STOP for owner Firebase/FCM setup). Vision-check each
product-surface step.
