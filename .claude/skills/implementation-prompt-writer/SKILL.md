---
name: implementation-prompt-writer
description: Planner-only. Write the exact, conservative, copy/paste prompt for the separate implementation Claude Code instance that edits PlantApp. Grounds every path/line/SHA by reading the real repo. Read-only; the planner writes the prompt into prompts/, never into PlantApp.
---

# Skill: implementation-prompt-writer

**Planner-only. PlantApp is READ-ONLY for the planner.** This skill writes a
prompt *for someone else* (the implementation Claude) — it does not itself touch
PlantApp.

## When to use
After `slice-state-review` and `github-repo-audit` have confirmed the next step
and the baseline SHA.

## Mandatory sections of every prompt (omit none)
1. **Scope** — exactly one logical change.
2. **Forbidden changes** — explicit "do NOT" list.
3. **Exact files/dirs to touch** — repo-relative or absolute; prefer exact
   old→new text blocks so the edit is deterministic.
4. **Baseline precondition** — branch + expected HEAD SHA + clean tree, with a
   **STOP-and-report** instruction if they don't match (prevents applying a stale
   prompt to a moved tree).
5. **Exact commands** — copy/paste ready, using `git -C <abs path> …`.
6. **Expected failure mode** — what "still failing" looks like and must be
   ignored (e.g. `npm test` → `vitest: not found`, because deps aren't installed
   and installing is out of scope). Separate *expected* from *regression*.
7. **Standalone verification** — an independently runnable command that produces
   objective pass/fail evidence: the exact command, what it proves, expected
   pass/fail, whether it is red/green/regression verification, and what output the
   implementer must report. Doc-only/prompt-only commits state "not applicable —
   documentation/prompt-only; verify by diff and grep." (See
   `.claude/rules/prompt-contract.md` and `decisions/planner-decisions.md` PD-05.)
8. **Commit title** — Conventional Commits, exact string.
9. **Push requirement** — explicit (`git push origin master`), note fast-forward.
10. **Final-report requirements** — diff, scope confirmation, `git show --stat`,
    new commit hash, push confirmation (new `origin/master` SHA).

## Output format → write to `prompts/next-implementation-prompt.md`
- 2–3 line rationale (which option, why, verified baseline SHA).
- A clearly delimited **"COPY BELOW / COPY ABOVE"** block: the self-contained,
  paste-ready prompt.
- A "Planner follow-up after this lands" section.
- Then **publish** to the exchange outbox (PD-06):
  `scripts/exchange-create-planner-prompt.sh <handoff-id> prompts/next-implementation-prompt.md`.
  `prompts/next-implementation-prompt.md` stays the human-readable mirror.

## Guardrails
- Ground every path + line number by actually reading the file first.
- One change → one commit. If you're tempted to bundle, split into sequential
  prompts.
- If the change needs an install/build/migration, make that an **explicit owner
  approval gate** in the prompt — never silently include it.
- Run the `no-mutation-guardian` mental checklist before finalizing.
