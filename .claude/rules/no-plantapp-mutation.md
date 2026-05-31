# Rule: No PlantApp mutation

**Status:** Hard rule. Applies to every planner session, skill, and subagent.

The real app repo `/home/israel/Documents/Development/PlantApp` is **READ-ONLY**
from this planner repo.

## Forbidden (planner side)
- Editing, creating, moving, or deleting any PlantApp file.
- `git add` / `commit` / `push` in PlantApp.
- `npm install`, `npm run …`, `vitest`, `gradle`/`gradlew`, `supabase`, any
  build/migration/DB command in PlantApp.
- Any destructive git anywhere: `reset --hard`, `clean -fd`, force-push, branch
  deletion, history rewrite.

## Allowed (planner side, read-only)
- File reads, `grep`, `find`.
- Read-only git: `status`, `log`, `diff`, `show`, `branch`, `remote`,
  `rev-parse`, `fetch`.
- Read-only `gh`: `repo view`, `pr list`, `issue list`, `gh api` GETs.

## How mutations actually happen
The planner emits an exact prompt (`prompts/next-implementation-prompt.md`); the
**owner** pastes it into a **separate implementation Claude Code instance** that
is allowed to edit PlantApp — but only within the single approved scope. Any
install/build/migration must be an explicit, per-change owner-approved step in
that prompt.

## Exception
A direct planner mutation of PlantApp requires **explicit, per-change owner
approval given in the current session**. Prior approval never carries forward.
