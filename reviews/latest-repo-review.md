# PlantApp — Repo Review

**Date:** 2026-05-31 · **Reviewer:** PlantAppPlanner control tower
**Repo:** `/home/israel/Documents/Development/PlantApp` @ `52c9d77` (`master`)
**Verdict:** Clean. One stale comment to fix. No production behavior. Safe to
proceed with the tiny cleanup (Option A).

## Files reviewed (with evidence)

| File | Finding |
|---|---|
| `shared-schemas/garden-space.schema.json` | `name` has `minLength: 1, maxLength: 80` (line 12). Contract present. ✅ |
| `shared-schemas/care-task.schema.json` | Full CareTask contract incl. `sourceInputs` (with `wateringBaselineAt`), `engineVersion`, `inputsHash`. Matches D-10. ✅ |
| `backend/tests/schema/_helpers.ts` | Ajv 2020 `{ allErrors: true, strict: true }` (line 15). ✅ |
| `backend/tests/schema/garden-space.test.ts` | **Stale comment, lines 3–8** — claims schema "does not yet enforce a minLength" and the empty-name test "fails red." Both false now. ⚠️ |
| `backend/care-engine/index.ts` | Placeholder `export {};` (line 5). No logic. ✅ |
| `backend/package.json` | `test` = `vitest run`; vitest is devDependency, not installed. ✅ (expected) |
| `backend/vitest.config.ts` | `include: ['**/*.test.ts']`, excludes integration; coverage targets `care-engine/**`, `src/**`. ✅ |
| `supabase/migrations/0001_init_extensions.sql` | Extensions only (`uuid-ossp`, `pgcrypto`); explicitly no tables (lines 3–6). ✅ |
| `justfile` | Thin pass-through targets; no DB/install side effects baked in. ✅ |
| `docs/slice-01-implementation-plan.md` | Slice 1 scope + formula + red-first test list (#1–#24) + DOD. NOT-YET-APPROVED banner present. ✅ |
| `docs/slice-01-decision-log.md` | D-01…D-12 accepted 2026-05-26. ✅ |
| `docs/domain-model.md` | Entities match schemas; `lastWateredAt` = onboarding baseline only. ✅ |
| `docs/roadmap.md` | 9 slices; Slice 1 matches the plan. ✅ |
| `README.md` / `CLAUDE.md` (app) | Both state "foundation + scaffolding only, no production behavior." Consistent with reality. ✅ |

## Local vs GitHub comparison

- Local HEAD `52c9d77` **==** `origin/master` `52c9d77`. In sync.
- Working tree clean; no uncommitted changes; no untracked/ignored noise.
- `git fetch origin` succeeded; only remote branch is `origin/master`.
- See `github-checks/latest-github-check.md` for PRs/issues/checks detail
  (all zero — no CI configured).

## Blockers

**None** for the Option A cleanup. (The inability to run `npm test` is expected —
deps not installed, install not approved — and does not block a comment-only edit.)

## Nice-to-fix (not now; track, don't act without approval)

- The stale comment is the only code-hygiene item; Option A handles it.
- After Option A: add red-first care-engine tests (#7–#14) — that is the on-deck
  Option B prompt, written by the planner once Option A lands.
- App `CLAUDE.md` "Commands" section still says "placeholders until code lands";
  fine for now, revisit when the first runnable code lands. (No action.)

## Exact next action

**Option A.** Implementation Claude edits **only**
`backend/tests/schema/garden-space.test.ts` (comment lines 3–8), correcting the
stale minLength claim. Commit `test(schema): remove stale GardenSpace minLength
comment`, push to `origin/master`. Full prompt:
`prompts/next-implementation-prompt.md`.

## Tooling note (bundled skills/agents used)

- This review used **direct read-only inspection** (Read + `git` + `grep` via
  Bash) and the **`gh` CLI** for GitHub state. No bundled Claude Code review
  skill (e.g. `/code-review`, `/security-review`) was invoked — they target a
  working diff/branch in the *current* repo, whereas this is a read-only audit of
  a *separate* repo. Planner-side reasoning is encoded in
  `.claude/skills/` and `.claude/agents/` for repeatability.
