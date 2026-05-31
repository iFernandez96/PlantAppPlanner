# Next Implementation Prompt

**Chosen:** Option A — remove the stale `GardenSpace.name` minLength comment.
**Why this and not Option B:** the stale comment in
`backend/tests/schema/garden-space.test.ts` (lines 3–8) **still exists** as of
`52c9d77`, while the schema already enforces `minLength: 1`. Clean it before
writing new care-engine tests. (Option B — red-first care-engine tests — is
on-deck; the planner will issue that prompt once this lands on `origin/master`.)

**Verified preconditions (2026-05-31):** PlantApp on `master`, HEAD `52c9d77` ==
`origin/master`, working tree clean. The schema enforces `minLength: 1`
(`shared-schemas/garden-space.schema.json:12`) and the Ajv helper uses
`strict: true` (`backend/tests/schema/_helpers.ts:15`), so the empty-name test is
a *passing regression guard*, not a pending red contract — the comment is wrong.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are working in the **PlantApp** repo: `/home/israel/Documents/Development/PlantApp`
(branch `master`, GitHub `iFernandez96/PlantApp`).

This is a **single-purpose, comment-only cleanup**. A stale comment in a schema
test claims `garden-space.schema.json` does not enforce `minLength` on `name`.
That is no longer true (the schema enforces `"minLength": 1`). Fix the comment.

### Scope (exactly one logical change)
- Correct the stale comment block in **one** file. Nothing else.

### Forbidden — do NOT
- Do not modify `shared-schemas/garden-space.schema.json` (it is already correct).
- Do not modify `backend/tests/schema/_helpers.ts`.
- Do not change any test **logic**: leave the `validGardenSpace` fixture and all
  three `it(...)` assertions byte-for-byte identical.
- Do not reformat, re-indent, or reorder anything in the file.
- Do not create, rename, or delete any file.
- Do not touch any other file anywhere in the repo.
- Do not run `npm install`, `npm test`, `vitest`, `gradle`, `supabase`, builds,
  migrations, or any dependency/DB command. None are needed for a comment edit.

### Exact file to touch
- `backend/tests/schema/garden-space.test.ts` — comment lines only (the header
  block at the top of the file).

### The edit
First confirm you are at the expected baseline:
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin
git rev-parse --abbrev-ref HEAD          # expect: master
git rev-parse HEAD                        # expect: 52c9d776d0202426c91af67d094a5330cc73f123
git rev-parse origin/master               # expect: same as HEAD
git status --short                        # expect: empty (clean)
```
If HEAD is **not** `52c9d77` or the tree is **not** clean, STOP and report — the
baseline has changed and this prompt may be stale.

Replace this exact block at the top of
`backend/tests/schema/garden-space.test.ts`:

```ts
// Test #4 (per docs/slice-01-implementation-plan.md):
// garden-space.schema.json rejects empty name and missing kind.
//
// Note: at the time these tests were written, garden-space.schema.json does
// not yet enforce a minLength on `name`. The empty-name test therefore acts
// as a contract specification: when it fails red, the next step is to add
// `"minLength": 1` (and likely `"pattern"` or `"format"` constraints) to the
// schema rather than to weaken the test.
```

with this exact block:

```ts
// Test #4 (per docs/slice-01-implementation-plan.md):
// garden-space.schema.json rejects empty name and missing kind.
//
// garden-space.schema.json enforces `"minLength": 1` on `name`
// (shared-schemas/garden-space.schema.json), so the empty-name case below is a
// passing regression guard, not a pending red contract.
```

(Equally acceptable alternative: delete the stale `//` separator + `Note:`
paragraph entirely, keeping only the first two `// Test #4 …` lines. The only
hard requirement is that no comment in the file claims the schema lacks a
`minLength` or that the empty-name test "fails red.")

### Verify (no test run — comment-only change)
```bash
git -C /home/israel/Documents/Development/PlantApp status --short
# expect exactly: " M backend/tests/schema/garden-space.test.ts"
git -C /home/israel/Documents/Development/PlantApp diff
# expect: only comment (`//`) lines changed; the import lines, the
# `validGardenSpace` fixture, and all three `it(...)` blocks UNCHANGED.
```
Expected failure mode to ignore: `npm test` would still print `vitest: not found`
because dependencies are not installed and installing them is **out of scope**.
A comment-only change cannot affect compilation or test results, so no run is
required or expected.

### Commit (exact title)
```bash
git -C /home/israel/Documents/Development/PlantApp add backend/tests/schema/garden-space.test.ts
git -C /home/israel/Documents/Development/PlantApp commit -m "test(schema): remove stale GardenSpace minLength comment"
```

### Push (required — impl repo policy: push after every logical change)
```bash
git -C /home/israel/Documents/Development/PlantApp push origin master
```
This should be a clean fast-forward (local was exactly `origin/master`).

### Final report back to the owner
1. The full `git diff` of the change (prove it is comment-only).
2. Explicit confirmation that the `validGardenSpace` fixture and all three
   `it(...)` assertions are unchanged.
3. `git show --stat HEAD` output (expect **1 file changed**, only this file).
4. The new commit hash + title.
5. Push confirmation: the new `origin/master` SHA after push.
6. Confirmation that no other file was created, modified, or deleted, and that no
   install/build/migration/test command was run.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands

When the implementation Claude reports success, the planner will:
1. Re-fetch PlantApp, confirm the new commit is on `origin/master`, and confirm
   the diff was comment-only.
2. Update `state/current-state.md`, `state/known-history.md`, and
   `github-checks/latest-github-check.md` with the new HEAD.
3. Write the **Option B** prompt: red-first care-engine unit tests for
   `computeInitialWaterTask` (Slice 1 plan tests #7–#14, formula D-10), which must
   fail red first (no implementation yet, and deps still not installed → the
   tests will not even run until `npm install` is separately approved). The
   planner will spell out that approval question explicitly in that prompt.
