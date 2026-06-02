# Next Implementation Prompt — lint-config cleanup (make `npm run lint` pass)

**Chosen (owner: "b, then a"):** fix the pre-existing ESLint↔TypeScript-project mismatch
so `npm run lint` passes. Config-only hygiene; no product behavior. (Android UI is next.)

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD `8f588af` == `origin/master`,
clean. `npm test` 50/50, `npm run test:int` 20/20. **`npm run lint` currently FAILS**
(~15 parse errors): `backend/eslint.config.js` uses typed linting via
`parserOptions.project = tsconfig.json`, but `backend/tsconfig.json` `include` only
covers `care-engine`/`src`/`scripts`, so `tests/**`, `eslint.config.js`, and
`vitest*.config.ts` aren't in the TS project and fail to parse. Zero `src/**` errors.

Single logical change → one commit.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Make
`npm run lint` pass by fixing the ESLint TypeScript-project configuration. **Consult the
current typescript-eslint docs** for the right approach.

### Baseline precondition (STOP if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect 8f588af90c69b569db1abdeceb5d97020b56b6f6
git status --short                         # expect empty
cd backend && npm run lint                 # expect FAIL (~15 parse errors: files not in tsconfig project)
```

### The fix (config only — pick the cleanest per current typescript-eslint docs)
Make every linted file resolve to a TS project so typed linting works repo-wide. Options:
- Preferred: switch `backend/eslint.config.js` to `languageOptions.parserOptions.projectService:
  true` (+ `tsconfigRootDir`), which resolves files not in a specific tsconfig (tests,
  config files) via the TS project service; **or**
- add a `backend/tsconfig.eslint.json` that `extends ./tsconfig.json` and `include`s
  everything ESLint lints (`**/*.ts`, `tests/**`, `*.config.ts`, `eslint.config.js`), and
  point `parserOptions.project` at it.
Do **not** change `backend/tsconfig.json`'s `include` in a way that pulls `tests/**` into
the production build/typecheck output (keep the build tsconfig's emitted scope unchanged).

### Forbidden
- Do NOT change any logic in `backend/care-engine/**`, `backend/src/**`,
  `shared-schemas/**`, or `supabase/migrations/**`.
- Do NOT change test assertions or weaken lint rules to hide real problems. If a genuine
  lint violation surfaces in **production** code (`src/**`, `care-engine/**`), STOP and
  report it (don't silently edit production logic). Minor genuine violations in
  test/config files may be fixed minimally.
- No new runtime deps (a typescript-eslint/config devDependency only if strictly required
  by the chosen approach).

### Standalone verification
```bash
cd /home/israel/Documents/Development/PlantApp/backend
npm run lint        # expect: exits 0, no errors (the ~15 parse errors gone)
npm run typecheck   # expect: still clean (build tsconfig scope unchanged)
npm test            # expect: still 50/50
```
This is the gate: `npm run lint` goes from failing (~15 parse errors) to clean, with
`typecheck` and the unit suite unaffected. (Integration tests need no re-run for a lint
config change.)

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add -A
git -C /home/israel/Documents/Development/PlantApp commit -m "chore(backend): fix ESLint TypeScript project config so lint passes"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. The fix approach (projectService vs tsconfig.eslint.json) + files changed.
2. `npm run lint` before (error count) → after (0); `npm run typecheck` clean; `npm test`
   50/50.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA.
4. Confirm no `src/**`/`care-engine/**`/schema/migration logic changed.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify `npm run lint` clean + unit 50/50 + typecheck clean + no production-logic change.
Then proceed to **a (Android UI slice, #21–#24)** — owner pre-approved ("b, then a").
Step a1 will be: generate the Gradle wrapper (not committed) + confirm the existing
6-module skeleton assembles (env: Java 21, `ANDROID_HOME=~/Android/Sdk`, `adb` present),
before adding Compose screens + UI tests (#21–#24, via emulator or Robolectric). Decompose
a further; stop to ask the owner only on a real blocker (e.g. emulator/SDK component
missing).
