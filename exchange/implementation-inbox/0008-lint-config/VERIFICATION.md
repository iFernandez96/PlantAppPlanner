# VERIFICATION — handoff 0008-lint-config (config hygiene)

Gate: `npm run lint` goes from failing to clean, with typecheck + unit unaffected.

## Before (HEAD 8f588af)
```
$ cd backend && npm run lint
✖ 16 problems (16 errors, 0 warnings)
```
All 16 are `0:0 Parsing error: <file> ... not found in ... project` for
`tests/**/*.ts`, `eslint.config.js`, `vitest.config.ts`, `vitest.integration.config.ts`.

## After (HEAD 603869e)
```
$ cd backend && npm run lint
> eslint .
(no output)            # exit 0
$ npm run lint >/dev/null 2>&1 && echo LINT OK   -> LINT OK (exit 0)
```
Zero errors. The ~16 parse errors are gone — every linted file now resolves to the
`tsconfig.eslint.json` program.

## Unaffected
```
$ npm run typecheck   -> clean (tsc --noEmit; build tsconfig scope unchanged)
$ npm test            -> Test Files 8 passed (8); Tests 50 passed (50)
```

## How it was fixed (no behavior change)
- New `backend/tsconfig.eslint.json` extends the build tsconfig, widens `include` to
  tests + config files + this config (`allowJs`), overrides `exclude` so `*.test.ts`
  aren't dropped, and sets `noEmit`. Lint-only; not part of the build.
- `backend/eslint.config.js` points `parserOptions.project` at `tsconfig.eslint.json`
  (+ `tsconfigRootDir`).
- Build `backend/tsconfig.json` untouched → `typecheck`/`build` emit scope identical.

## Scope / integrity
- `git diff --quiet HEAD` confirms no change under `backend/src/**`,
  `backend/care-engine/**`, `shared-schemas/**`, `supabase/migrations/**`, or the build
  `backend/tsconfig.json`.
- No lint rule disabled/weakened; no test assertion changed; no dependency added.

## Final repo state
- origin/master = `603869e6cf111957083042ce2b2dd4ce6ec2e1cf`; local == origin; clean.
