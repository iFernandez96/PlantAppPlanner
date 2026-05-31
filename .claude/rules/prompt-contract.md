# Rule: Implementation-prompt contract

Every prompt the planner produces for the implementation Claude **must** contain
all nine sections below. A prompt missing any section is not ready to ship.

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
7. **Commit title** — Conventional Commits, exact string.
8. **Push requirement** — explicit; note fast-forward expectation.
9. **Final-report requirements** — diff, scope confirmation, `git show --stat`,
   new commit hash, push confirmation (new `origin/master`).

## Additional invariants
- One change → one commit → one push.
- Install/build/migration steps are allowed in a prompt **only** behind an
  explicit owner-approval gate, never silently.
- Ground every cited path/line/SHA by reading the real repo first.
- Run the `no-mutation-guardian` checklist before finalizing.
