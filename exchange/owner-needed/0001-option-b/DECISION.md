# Owner decision needed — 0001-option-b (npm cache unreachable)

**Raised by:** PlantAppPlanner listener · **Date:** 2026-06-01
**Listener state:** PAUSED — no new implementation prompt will be published until you choose.
**PlantApp:** untouched — `master @ b2836ca` == origin/master, working tree clean. Nothing was committed or pushed.

## What blocked

The implementation Claude ran Option B / Commit 1 (`npm install` in `backend/`) and it
failed **before installing anything**:

```
npm error code ENOTDIR
npm error syscall mkdir
npm error path /home/israel/.npm
npm error ENOTDIR: not a directory, mkdir '/home/israel/.npm'
```

Root cause (environment, not code): the npm cache dir is a **broken symlink** to an
unmounted external drive —

```
/home/israel/.npm -> /media/israel/Drive/cache-mirror/npm   (target missing; Drive not mounted)
npm config get cache => /home/israel/.npm
```

The registry was reachable; npm just can't create/write its cache. It correctly stopped
per the prompt ("if npm install fails, STOP and report"), did **not** improvise a
workaround, did **not** touch the `~/.npm` symlink, and did **not** mount the drive.

## Decision — how should the planner unblock this?

| # | Option | What it changes | Trade-off |
|---|---|---|---|
| 1 | **Mount the Drive** so `/media/israel/Drive/cache-mirror/npm` resolves, then re-issue the **same** prompt unchanged | nothing in repo/home | depends on the external Drive being mounted during dev |
| 2 | **Fix the cache globally** — repoint `~/.npm` to a real local dir (e.g. `~/.npm-local`) or set `cache=` in `~/.npmrc` | your home (persistent) | fixes the root cause for *all* npm usage, but is outside the planner's scope so needs your explicit OK |
| 3 (rec.) | **Scoped per-handoff override** — I revise the Option B prompt so every npm call uses `--cache /tmp/plantapp-npm-cache` | the prompt only | fastest unblock, no home/Drive dependency, stays a plain dependency install; deviates from the literal `npm install`, so you sanction it once |

**Planner recommendation:** Option 3 — it unblocks immediately, changes nothing in your
home or on the Drive, and keeps the install reproducible for this handoff. Option 2 is the
"right" long-term fix if you want your normal `~/.npm` working again for everything.

## To answer
Tell the planner: **1**, **2**, or **3** (or describe another approach). Then:
- Option 1/2: I re-publish the same Option B prompt and un-pause the listener.
- Option 3: I revise the Option B prompt to add `--cache /tmp/plantapp-npm-cache` to the
  npm commands, re-publish, and un-pause.

The planner is the only instance that asks you; the implementation Claude only ever
returns a BLOCKED report (which is what happened here).
