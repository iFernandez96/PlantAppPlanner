# DONE — handoff 0008-lint-config (single commit)

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** `npm run lint` now passes (16 parse errors → 0); typecheck clean; unit 50/50.
Config-only; no product behavior changed.
Final `origin/master` = `603869e6cf111957083042ce2b2dd4ce6ec2e1cf`.

## Baseline precondition — matched
- HEAD = `8f588af90c69b569db1abdeceb5d97020b56b6f6` == origin/master; clean.
- `npm run lint` FAILED at baseline: **16 problems** (parse errors — files not in the TS
  project: all `tests/**`, `eslint.config.js`, `vitest.config.ts`,
  `vitest.integration.config.ts`).

## Fix approach
Chose the **`tsconfig.eslint.json`** option (the `projectService: true` attempt still
rejected tsconfig-excluded files with "was not found by the project service", because
the build tsconfig explicitly `exclude`s `**/*.test.ts`).

Files changed (2):
- **`backend/tsconfig.eslint.json`** (new) — `extends ./tsconfig.json`, sets
  `compilerOptions.noEmit: true` + `allowJs: true`, `include`s
  `care-engine/**`, `src/**`, `scripts/**`, `tests/**`, `*.config.ts`, `eslint.config.js`,
  and overrides `exclude` to just `["node_modules","dist"]` so it does **not** re-drop
  `*.test.ts`. This is a lint-only project; it never participates in the build.
- **`backend/eslint.config.js`** — `parserOptions.project` changed from
  `['./tsconfig.json']` to `['./tsconfig.eslint.json']`, plus
  `tsconfigRootDir: import.meta.dirname`. (Comment updated.)

The **build** `backend/tsconfig.json` is unchanged — its emitted scope
(`care-engine`/`src`/`scripts`, excluding tests) is exactly as before, so
`npm run build`/`typecheck` output is unaffected.

## Verification (the gate)
```
npm run lint       BEFORE: 16 problems (16 errors)  →  AFTER: exit 0, no errors
npm run typecheck  clean (tsc --noEmit)
npm test           Test Files 8 passed (8); Tests 50 passed (50)
```
(Integration tests not re-run — a lint-config change can't affect them; unchanged at
20/20 from 0007.)

## Compliance
- No logic changed in `backend/src/**`, `backend/care-engine/**`, `shared-schemas/**`,
  or `supabase/migrations/**` (`git diff --quiet HEAD` confirmed for those paths).
- `backend/tsconfig.json` (build) unchanged.
- No test assertions changed; no lint rules weakened/disabled — the fix is purely making
  every linted file resolve to a TS project, so typed linting runs repo-wide. No genuine
  lint violations surfaced in production code.
- No new runtime deps (no dependency added at all; `typescript-eslint` already present).

## git show --stat HEAD
```
chore(backend): fix ESLint TypeScript project config so lint passes
 backend/eslint.config.js     |  6 +++++-
 backend/tsconfig.eslint.json | 17 +++++++++++++++++
 2 files changed, 22 insertions(+), 1 deletion(-)
```

Commit: `603869e6cf111957083042ce2b2dd4ce6ec2e1cf` —
chore(backend): fix ESLint TypeScript project config so lint passes
Final `origin/master` SHA: `603869e6cf111957083042ce2b2dd4ce6ec2e1cf`

## Next (per planner follow-up)
Owner pre-approved "b, then a": next is the **Android UI slice (#21–#24)**, starting at
a1 — generate the (uncommitted) Gradle wrapper and confirm the existing 6-module skeleton
assembles (env: Java 21, `ANDROID_HOME=~/Android/Sdk`, `adb`), before Compose screens +
UI tests.
