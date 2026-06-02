# Rule: Implementation-prompt contract

Every prompt the planner produces for the implementation Claude **must** contain
all ten sections below. A prompt missing any section is not ready to ship.

1. **Scope** — exactly one logical change. No bundling.
2. **Forbidden changes** — explicit "do NOT touch" list.
3. **Exact files/dirs to touch** — paths; prefer exact old→new text blocks.
4. **Baseline precondition** — branch + expected HEAD SHA + clean tree, with a
   **STOP-and-report** instruction if reality differs (guards against applying a
   stale prompt to a moved tree).
5. **Exact commands** — copy/paste ready (`git -C <abs path> …`).
6. **Expected failure mode** — what "still failing" looks like and must be
   ignored (e.g. `vitest: not found` when deps aren't installed). Separate
   *expected* failures from *regressions*.
7. **Standalone verification** — see the required subsection below.
8. **Commit title** — Conventional Commits, exact string.
9. **Push requirement** — explicit; note fast-forward expectation.
10. **Final-report requirements** — diff, scope confirmation, `git show --stat`,
    new commit hash, push confirmation (new `origin/master`).

### Standalone verification

Every implementation prompt for a feature must include:
- the exact command(s) to run,
- what the command proves,
- expected pass/fail behavior,
- whether this is red, green, or regression verification,
- what output the implementation Claude must report,
- where evidence should be captured if applicable.

Doc-only or prompt-only commits may say:
"Standalone verification: not applicable — documentation/prompt-only change. Verify
by diff and grep."

## Additional invariants
- One change → one commit → one push.
- Install/build/migration steps are allowed in a prompt **only** behind an
  explicit owner-approval gate, never silently.
- Ground every cited path/line/SHA by reading the real repo first.
- A feature is **not done** until its standalone verification produces objective
  pass/fail evidence (PD-05). Claude self-report is insufficient.
- After writing `prompts/next-implementation-prompt.md`, publish the prompt to the
  exchange outbox with `scripts/exchange-create-planner-prompt.sh <id>
  prompts/next-implementation-prompt.md` (PD-06). Published `<id>/` dirs are
  immutable — supersede with a new id, never edit in place.
- After writing/publishing a prompt, run the `vision-alignment-reviewer` to
  sanity-check it against the product vision (`../PlantApp/ChatHistory.md`); revise or
  escalate to the owner on drift before the implementation proceeds.
- Run the `no-mutation-guardian` checklist before finalizing.
