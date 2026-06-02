# BLOCKED — handoff 0001-option-b

**Status:** BLOCKED at Commit 1, step `npm install`.
**App repo:** /home/israel/Documents/Development/PlantApp
**Branch/HEAD:** master @ `b2836ca7ff4d65020f1d385d38940cf8652db459` (== origin/master).
**Working tree:** clean. No commit created, no file changed, nothing pushed.

## What happened

Baseline precondition passed exactly:
- branch = master
- HEAD = b2836ca7ff4d65020f1d385d38940cf8652db459
- origin/master = same
- `git status --short` = empty
- `backend/care-engine/index.ts` = placeholder comment + `export {};`

Commit 1's first command, `npm install` (run from `backend/`), failed before
fetching/writing any package. Verbatim error:

```
npm error code ENOTDIR
npm error syscall mkdir
npm error path /home/israel/.npm
npm error errno ENOTDIR
npm error Invalid response body while trying to fetch https://registry.npmjs.org/@types%2fnode: ENOTDIR: not a directory, mkdir '/home/israel/.npm'
npm error Log files were not written due to an error writing to the directory: /home/israel/.npm/_logs
```

`npm install` exited non-zero. The prompt's instruction for this case is:
"If `npm install` fails (e.g. no registry/network access), STOP and report the
error verbatim — do not proceed or fabricate." Stopping here.

## Root cause (environment, not code)

npm's cache directory is a **broken symlink** to an unmounted external drive:

```
$ ls -la /home/israel/.npm
lrwxrwxrwx ... /home/israel/.npm -> /media/israel/Drive/cache-mirror/npm

$ file /home/israel/.npm
/home/israel/.npm: broken symbolic link to /media/israel/Drive/cache-mirror/npm

$ npm config get cache
/home/israel/.npm

$ ls -la /media/israel/Drive/cache-mirror
ls: cannot access '/media/israel/Drive/cache-mirror': No such file or directory
```

Environment: node v22.22.0, npm 10.9.4. The registry was reachable (npm got as
far as fetching `@types/node` metadata); the failure is that npm cannot create
or write its cache dir `/home/israel/.npm` because the symlink target
`/media/israel/Drive/cache-mirror/npm` does not exist (external "Drive" not
mounted). npm aborts before installing anything, so `node_modules/` and
`backend/package-lock.json` were never created.

## Impact on the handoff

- Commit 1 cannot proceed: no `package-lock.json` was produced, and the
  first-ever `npm test` baseline run cannot execute (`vitest` not installed).
- Commit 2 (the red-first care-engine tests) is gated on Commit 1's executed
  test run, so it is not started.
- Nothing was committed or pushed. The repo is byte-identical to the verified
  baseline `b2836ca`.

## What I did NOT do (per protocol — no improvising)

- Did **not** apply a workaround such as `npm install --cache /tmp/...`,
  `npm ci`, `--prefer-offline`, or `NPM_CONFIG_CACHE=...` — none are described by
  the prompt, and rule 7 says stop on undescribed failures.
- Did **not** repoint or delete the `~/.npm` symlink (it is in the owner's home
  dir, outside the app repo; rule 4 limits mutations to the PlantApp repo and
  this handoff's `.writing` dir).
- Did **not** mount or touch `/media/israel/Drive`.
- Did **not** modify npm config, install npm globally, or change node/npm
  versions.
- Did **not** create, commit, or push anything in the app repo.

## Suggested unblock options (for the planner / owner to decide)

The planner is the only instance that asks the owner. Options, least- to
most-invasive:

1. **Mount the external drive** so `/media/israel/Drive/cache-mirror/npm`
   resolves, then re-issue this same handoff unchanged. Zero config change.
2. **Re-point the npm cache** to a real local directory the owner approves,
   e.g. `~/.npm-local`, then re-run. Requires either fixing the `~/.npm`
   symlink or setting `cache=...` in `~/.npmrc` — a persistent change to the
   owner's home, outside this repo, so it needs explicit owner approval.
3. **Authorize a per-command cache override** for this handoff only, e.g.
   `npm install --cache /tmp/plantapp-npm-cache` (and the same `--cache` flag on
   any subsequent npm invocation). This stays a plain dependency install (no
   `npm install <pkg>`), leaves `package.json` unchanged, and touches nothing in
   the owner's home — but it deviates from the prompt's literal `npm install`,
   so it should be explicitly sanctioned in a revised prompt rather than
   improvised here.

Recommend the planner pick one and re-issue (a revised PROMPT.md for option 3,
or the same prompt for options 1/2 once the environment is fixed).

## Re-verification baseline for the re-issued handoff

Unchanged from this attempt — the next implementer should still expect:
- master @ `b2836ca7ff4d65020f1d385d38940cf8652db459` == origin/master, clean
- `backend/care-engine/index.ts` == placeholder `export {};`
