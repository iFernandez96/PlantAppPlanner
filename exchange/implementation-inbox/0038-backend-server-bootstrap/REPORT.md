# DONE — handoff 0038-backend-server-bootstrap

**App repo:** /home/israel/Documents/Development/PlantApp (branch `master`)
**Result:** the Fastify backend now has a real HTTP entry point — `backend/src/server.ts` boots the
existing `buildApp()` and `.listen()`s on `0.0.0.0:3000` (env-overridable), plus a `start` script.
No route/engine/schema/auth change. Verified: server boots, routes, and auth-guards (401 without a
token). Final `origin/master` = `e95c40ee0712d8e57d667f07f33d5974f99323bd`.

## Baseline + unblock
- HEAD at start = `369f2f0…` == origin/master; clean. No prior `server.ts`/`.listen()`/`start`.

## What was added
1. **`backend/src/server.ts`** (new) — `main()` reads `HOST` (default `0.0.0.0`, so a LAN device
   can reach it) + `PORT` (default `3000`), `const app = await buildApp(); await app.listen({ host,
   port })`, logs `PlantApp API listening on http://<host>:<port>`; `main().catch` logs and
   `process.exit(1)`. (`tsconfig` `outDir ./dist` → compiles to `dist/src/server.js`, and the
   `../care-engine/*.js` imports resolve under `dist/`.)
2. **`backend/package.json`** — added `"start": "node dist/src/server.js"` (build-then-node; no new
   dependency, no TS runtime). All existing scripts unchanged.

## Verification (green — the server actually runs)
```
$ cd backend && npm run build                       # tsc → dist/
$ ls dist/src/server.js                             # present
$ SUPABASE_URL=http://127.0.0.1:54321 SUPABASE_ANON_KEY=dummy PORT=3000 node dist/src/server.js &
  PlantApp API listening on http://0.0.0.0:3000      # startup log
$ curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:3000/plants   # → 401
  server alive on :3000
$ npm test           Tests 72 passed (72)            # server.ts not imported by tests
$ npm run typecheck  clean
$ npm run lint       clean
```
- `dist/src/server.js` built; server boots and logs; `GET /plants` with no token → **401**
  (server up + routing + auth hook working — no Supabase contact needed for the no-token path);
  unit **72/72**; typecheck + lint clean.
- Dummy env is sufficient: `loadConfig()` only needs the vars *present*, and the no-token path 401s
  in `auth.ts` before any Supabase call.

## Implementation note
First lint run flagged 2 warnings: the `// eslint-disable-next-line no-console` directives were
"unused" because `no-console` isn't an enabled rule in this config (console is already allowed). I
removed the directives — lint is now clean (0/0). No behavioural change.

## Commit
- `e95c40e` — feat(backend): HTTP server bootstrap (server.ts + start script) for real runs
- `git show --stat HEAD`: 2 files, +18 — only `backend/src/server.ts` + `backend/package.json`.
  `backend/dist/` is git-ignored (confirmed via `git check-ignore`); no `dist/`/`.env`/secrets
  committed.

## Compliance
- No change to `app.ts` handlers, the care engines, `auth.ts`, `config.ts`, `mappers.ts`, schemas,
  migrations, or Android. No new dependency. `buildApp()` signature/behaviour unchanged. No CORS
  (client is not a browser).

Final `origin/master` SHA: `e95c40ee0712d8e57d667f07f33d5974f99323bd`

## Next (per planner follow-up)
Step 2 (Android device-debug build): split the two base URLs (auth → Supabase `:54321/`, PlantApp
API → Fastify `:3000/`) via a **debug-overridable** mechanism (avoid committing a host-specific IP
as the production default) + a **debug-only `network-security-config`** allowing cleartext to the
LAN host; rebuild the debug APK. Then the planner runs Supabase + this server bound to the LAN
(owner opens `ufw` 54321 + 3000) and re-runs the device suite for the real sign-in → add-plant →
reminder journey.
