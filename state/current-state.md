# PlantApp — Current State

> Single source of truth for "where are we right now." Refresh from real git +
> GitHub at the start of every planner session; never trust this file blindly
> without re-verifying the SHAs.

| Field | Value |
|---|---|
| **Snapshot timestamp** | 2026-05-31 (planner init) |
| **PlantApp repo path** | `/home/israel/Documents/Development/PlantApp` |
| **GitHub** | `github.com/iFernandez96/PlantApp` (public) |
| **Branch** | `master` |
| **Default branch** | `master` (no `main`) |
| **Local HEAD** | `52c9d776d0202426c91af67d094a5330cc73f123` (`52c9d77`) |
| **origin/master** | `52c9d776d0202426c91af67d094a5330cc73f123` (`52c9d77`) |
| **Local == remote?** | ✅ YES — in sync, nothing to push/pull |
| **Working tree** | ✅ clean (`git status --short` empty) |
| **Uncommitted changes** | None |

## Last confirmed commit

```
52c9d77 test(schema): make Slice 1 schema contract assertions consistent
```
This added `minLength: 1` to `GardenSpace.name` and set the Ajv test helper to
`strict: true`. **Both verified present** (see Evidence below).

## Current phase

**Post-scaffolding, schema contract aligned, pre-business-logic.** Foundation
docs + BDD + ADRs done; D-01…D-12 accepted (2026-05-26); backend/Android/Supabase
scaffolding committed; red-first schema-validation tests added and the schema
contract aligned. No Slice 1 business logic has begun.

## Scaffolding state

- **Backend** (`backend/`): Node + TS skeleton — ESLint 9 flat config, Prettier,
  Vitest, Ajv 2020-12. `package.json` scripts: `lint`, `test` (`vitest run`),
  `test:int`, `build`, `typecheck`, `validate-schemas`. No HTTP server, no
  Supabase client, no `src/`.
- **care-engine** (`backend/care-engine/index.ts`): **placeholder only** —
  `export {};` plus a comment. No business logic.
- **Android** (`android/`): 6-module Gradle skeleton (`:app`, `:design-system`,
  `:domain`, `:data`, `:network`, `:feature-inventory`). Source dirs contain only
  `.gitkeep`. **No production Kotlin.** Wrapper jar/`gradlew` not committed.
- **Supabase** (`supabase/migrations/`): `0001_init_extensions.sql` enables
  `uuid-ossp` + `pgcrypto` only. **No tables.**
- **justfile**: thin pass-through targets to backend/Android tooling.
- **Shared schemas** (`shared-schemas/`): 7 JSON Schemas (garden-space,
  container, plant-instance, plant-profile, care-task, diagnosis-result,
  space-plan).
- **Project subagents** (`.claude/agents/` in PlantApp): 7 read-only reviewers.

## Test state

- **Schema tests** (`backend/tests/schema/`): `garden-space`, `container`,
  `plant-instance`, `plant-profile`, `care-task`, `round-trip` + `_helpers.ts`.
- **Ajv helper** uses `{ allErrors: true, strict: true }`.
- **`GardenSpace.name`** schema enforces `minLength: 1, maxLength: 80`.
- **`npm test` cannot run** — `vitest` is a devDependency but `node_modules` is
  absent; `npm install` has **not** been approved/run. Expected output:
  `vitest: not found`. This is an **expected** environmental state, not a code
  regression.
- **No care-engine unit tests exist yet** (`computeInitialWaterTask` is only
  referenced as test #7 in the Slice 1 plan; no implementation, no test file).

## Production behavior state

**NONE.** Verified absent:
- No care-engine logic (placeholder export).
- No DB tables (extensions only).
- No production Kotlin (only `.gitkeep`).
- No AI / weather / photos / notifications / auth / camera / location runtime
  code. Only docs, versioned prompt markdown, eval READMEs, and BDD `.feature`
  files describe these — none implemented.

## Known stale artifact (drives the next action)

`backend/tests/schema/garden-space.test.ts` lines 3–8 still carry a **stale
comment** claiming the schema "does not yet enforce a minLength on `name`" and
that the empty-name test "fails red." Both are now false: the schema enforces
`minLength: 1` and the test is a passing regression guard. **The comment must be
corrected.**

## Next recommended action

**Option A — tiny test-comment cleanup.**
Commit: `test(schema): remove stale GardenSpace minLength comment`.
Touch only `backend/tests/schema/garden-space.test.ts` (comment lines only).
Exact prompt: `prompts/next-implementation-prompt.md`.

**On-deck after that:** Option B — red-first care-engine unit tests for
`computeInitialWaterTask` (Slice 1 plan tests #7–#14). The planner will write
that full prompt once Option A lands and is verified on `origin/master`.

## Evidence (paths : line — fact)

- `shared-schemas/garden-space.schema.json:12` — `"name": { "type": "string", "minLength": 1, "maxLength": 80 }`
- `backend/tests/schema/_helpers.ts:15` — `new Ajv2020({ allErrors: true, strict: true })`
- `backend/tests/schema/garden-space.test.ts:4-8` — stale "does not yet enforce a minLength" note (still present)
- `backend/care-engine/index.ts:5` — `export {};` (placeholder)
- `supabase/migrations/0001_init_extensions.sql:13-14` — extensions only, no tables
- `backend/package.json:12` — `"test": "vitest run"` (vitest = devDependency, not installed)
