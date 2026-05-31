---
name: slice-state-review
description: Planner-only. Produce the evidence-backed PlantApp repo review — files reviewed, local-vs-GitHub comparison, blockers, nice-to-fix, and the exact next action — mapped onto the Slice 1 plan. Read-only; never mutates PlantApp.
---

# Skill: slice-state-review

**Planner-only. PlantApp is READ-ONLY.** Inspect and report; never edit/commit/
push/install/build/migrate.

## When to use
On every working session, and whenever PlantApp's HEAD moves. Output feeds the
prompt decision.

## Reference docs (read in PlantApp)
- `docs/slice-01-implementation-plan.md` (scope, red-first tests #1–#24, DOD)
- `docs/slice-01-decision-log.md` (D-01…D-12)
- `docs/domain-model.md`, `docs/roadmap.md`

## Checklist
1. Confirm HEAD + cleanliness (delegate to `repo-state-auditor` if helpful).
2. Read the verification-critical files and record `path:line` evidence:
   - `shared-schemas/garden-space.schema.json` — `minLength` on `name`?
   - `backend/tests/schema/_helpers.ts` — `strict: true`?
   - `backend/tests/schema/garden-space.test.ts` — stale minLength comment?
   - `backend/care-engine/index.ts` — still placeholder?
   - `supabase/migrations/*` — tables yet?
   - Android `src/main/kotlin` — only `.gitkeep`?
3. Confirm "no production behavior" still holds (engine/tables/Kotlin/AI/weather/
   photos/notifications/auth).
4. Identify the smallest next red-first step; honor Slice 1 exclusions + D-09.
5. List blockers vs nice-to-fix. Note expected test failure mode (deps absent).

## Output format → write to `reviews/latest-repo-review.md`
- Date, repo, HEAD, one-line verdict.
- "Files reviewed" table (finding + `path:line`).
- "Local vs GitHub comparison".
- "Blockers" / "Nice-to-fix" / "Exact next action".
- "Tooling note": record any bundled Claude Code skills/agents used (e.g.
  `/code-review`) or explain why direct inspection was used instead.

## Guardrails
Cite `path:line` for every claim. Never recommend work outside the locked Slice 1
scope without flagging it as out-of-scope.
