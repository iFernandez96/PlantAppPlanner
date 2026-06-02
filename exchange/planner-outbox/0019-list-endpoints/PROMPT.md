# Next Implementation Prompt — backlog (3a): GET list endpoints for the add-plant selectors

**Backlog item (3) UX follow-ups, step 3a.** The Android add-plant form currently takes raw
id text fields. Before it can show real **selectors** (3b), the backend must expose the three
lists the form needs:
- `GET /plant-profiles` — the read-only species catalog (profile dropdown source).
- `GET /garden-spaces` — the caller's garden spaces (RLS-scoped).
- `GET /containers` — the caller's containers (RLS-scoped).

All three return arrays of objects conforming to the existing `shared-schemas/*` (camelCase),
reusing the existing response mappers; `plant-profiles` needs one new `toPlantProfile` mapper.
No schema change, no migration, no new dependency, no AI. Read-only endpoints only.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`392ba8640aea98f4091e8a61c4180495c4bbf0f9` == `origin/master`, clean. Existing endpoints:
`POST /garden-spaces`, `POST /containers`, `POST /plants`, `GET /plants`, `GET /plants/:id`,
`GET /plants/:id/tasks`, `GET /plants/:id/advisories`, `DELETE /plants/:id` (none list
profiles/spaces/containers). `plant_profiles` is a read-only catalog (`select to authenticated
using (true)`, migration `0003`); `garden_spaces`/`containers` have `*_select_own` RLS.
`npm test` 67/67, `npm run test:int` 25/25, `npm run validate-schemas` green.

Single logical change (the three list endpoints feeding the selectors) → one commit.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add three
read-only list endpoints and their integration tests. **Red-first:** write the failing
integration test first, then implement until green.

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect 392ba8640aea98f4091e8a61c4180495c4bbf0f9
git status --short                         # expect empty
```

### Scope — exactly these three endpoints
1. **`GET /plant-profiles`** — `onRequest: requireAuth`. Select all rows from
   `plant_profiles` (ordered by `id` ascending), map each through a **new** `toPlantProfile`
   mapper, return `200` with the array. The catalog is global (RLS allows all authenticated
   reads) — do NOT filter by user.
2. **`GET /garden-spaces`** — `onRequest: requireAuth`. Select `*` from `garden_spaces`
   ordered by `created_at` ascending; map each through the existing `toGardenSpace`; return
   `200` with the array. RLS already scopes rows to the caller — do NOT add a manual
   `user_id` filter (mirror the existing `GET /plants` handler exactly).
3. **`GET /containers`** — `onRequest: requireAuth`. Same shape, `containers` table, existing
   `toContainer` mapper.

### The new mapper — `backend/src/mappers.ts`
Add `toPlantProfile(row)` next to the others, using the same `put()` helper (omit
null/undefined optionals). Map snake_case columns → the camelCase keys in
`shared-schemas/plant-profile.schema.json`. The `*_profile`/`seasonality`/`source` jsonb
columns are already stored camelCase internally — pass them through unchanged. Required keys
(always present): `id`, `scientificName`←`scientific_name`, `commonNames`←`common_names`,
`category`, `growthHabit`←`growth_habit`, `requiresSupport`←`requires_support`,
`pollinationPartnersRequired`←`pollination_partners_required`, `wateringProfile`←
`watering_profile`, `feedingProfile`←`feeding_profile`, `containerProfile`←`container_profile`,
`lightProfile`←`light_profile`, `temperatureProfile`←`temperature_profile`, `version`.
Optional via `put()`: `selfFruitful`←`self_fruitful`, `seasonality`, `commonIssues`←
`common_issues`, `verticalSuitability`←`vertical_suitability`, `source`, `lastReviewedAt`←
`last_reviewed_at`. **Coerce `vertical_suitability` with `Number(...)` when present** (pg
`numeric` deserializes as a string and the schema requires `number` — same pattern as
`volumeLiters` in `toContainer`). Invent no field beyond the schema.

### Tests — new file `backend/tests/integration/lists-api.integration.test.ts`
Follow the harness in `tests/integration/advisories-api.integration.test.ts` (provision two
users via the service role + anon sign-in; `app.inject`; `compileSchema(...)` to Ajv-validate
responses). Cover:
- `GET /plant-profiles` returns `200`, a **non-empty** array (the seed catalog is loaded), and
  **every** element validates against `plant-profile.schema.json` (`compileSchema('plant-profile')`).
- `GET /garden-spaces` / `GET /containers`: user A creates one of each (reuse the
  `POST /garden-spaces` + `POST /containers` helpers), then `GET` returns exactly that row and
  it validates against `garden-space.schema.json` / `container.schema.json`. **RLS isolation:**
  user B's `GET` does NOT include user A's row.
- All three without an `authorization` header return `401`.

### Forbidden
- No schema change, no migration, no seed change, no change to the engines, the POST handlers,
  `auth.ts`/`config.ts`, or Android. No new dependency. No write/insert/update/delete in the
  new endpoints (they are strictly read-only). Do NOT add a manual `user_id` filter to the
  RLS-scoped lists — rely on RLS (matching `GET /plants`). No AI, no photos/GPS fields.

### Standalone verification (the gate)
```bash
cd /home/israel/Documents/Development/PlantApp/backend
set -a; eval "$(npx supabase status -o env)"; set +a   # local stack env for integration tests
npm run test:int        # NEW lists-api tests pass; total > 25 (was 25/25)
npm test                 # unit still 67/67
npm run validate-schemas # still green (exit 0, 8 schemas)
npm run typecheck && npm run lint   # clean
```
Red-first: the new test file fails before the endpoints/mapper exist, then passes. If the
local Supabase stack is not running, integration tests fail to connect — that is an
*environment* failure (start it with `npx supabase start`), NOT a code regression; the unit
suite (`npm test`) and `validate-schemas` must pass regardless.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add backend/src/app.ts backend/src/mappers.ts backend/tests/integration/lists-api.integration.test.ts
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(api): list endpoints for plant-profiles, garden-spaces, containers"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The three handlers (paths + that profiles is unscoped catalog, spaces/containers are
   RLS-scoped, all read-only) and the new `toPlantProfile` mapper.
2. `npm run test:int` before (25) → after (new count, listing the new test names); `npm test`
   67/67; `validate-schemas` green; typecheck + lint clean.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only those 3
   files changed.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved, only the 3 files, RLS isolation asserted in the new test, no manual
user_id filter, `npm test` 67/67, validate-schemas green). Then **3b**: Android add-plant
**selectors** — profile dropdown sourced from `GET /plant-profiles`; garden-space/container
**select-or-create** sourced from the new lists — replacing the id text fields, with
`:network` DTOs + `:data` calls + `:feature-inventory` Compose UI tests. Then 3c (Supabase
magic-link sign-in → DataStore token), 3d (advisory→accept→CareTask, routed through the
engine). Then (2) emulator e2e smoke; then (4) Slice 3 (WorkManager local first; STOP for
owner Firebase/FCM setup). Vision-check each product-surface step.
