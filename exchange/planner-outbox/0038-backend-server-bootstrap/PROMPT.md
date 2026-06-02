# Next Implementation Prompt — backend server bootstrap (enable real HTTP runs)

**On-device full-stack enablement, step 1 of 2 (backend).** The Fastify backend currently has
**no HTTP entry point** — `buildApp()` is only ever exercised in-process via `app.inject()` in
tests. To run a real on-device full-stack test, the API must actually `listen()`. This handoff adds
a minimal server bootstrap + a `start` script. **No route/engine/schema change**; purely makes the
existing app runnable over HTTP.

**Verified baseline (2026-06-02):** PlantApp `master`, HEAD
`369f2f06dcc6bc8019cf051b40228e01a0746b89` == `origin/master`, clean. `backend/src/` has
`app.ts` (exports `async buildApp(): Promise<FastifyInstance>`), `auth.ts`, `config.ts`,
`mappers.ts` — **no `server.ts`/`index.ts`, no `.listen()`**, and `package.json` has **no
`start`/`dev` script**. `auth.ts`: a request with no `Authorization: Bearer` → **`401
missing_bearer_token`** before any Supabase call. `config.ts` `loadConfig()` throws if
`SUPABASE_URL`/`SUPABASE_ANON_KEY` (or `API_URL`/`ANON_KEY`) are unset. `tsconfig.json`:
`module/moduleResolution NodeNext`, `outDir ./dist` (so `src/server.ts` → `dist/src/server.js`,
and `../care-engine/*.js` imports resolve under `dist/`). `build` script = `tsc -p tsconfig.json`.

Single logical change (the server bootstrap + start script) → one commit.

---

## ⬇️ COPY EVERYTHING BELOW THIS LINE INTO THE IMPLEMENTATION CLAUDE ⬇️

You are in **PlantApp** (`/home/israel/Documents/Development/PlantApp`, `master`). Add a minimal
HTTP server entry point so the existing Fastify app can run for real (device/integration use).

### Baseline precondition (STOP and report if mismatch)
```bash
cd /home/israel/Documents/Development/PlantApp
git fetch origin && git rev-parse HEAD   # expect 369f2f06dcc6bc8019cf051b40228e01a0746b89 == origin/master
git status --short                         # expect empty
```

### Scope
1. **`backend/src/server.ts`** (new) — bootstrap the existing app; bind all interfaces so a LAN
   device can reach it; port/host overridable by env:
   ```ts
   import { buildApp } from './app.js';

   async function main(): Promise<void> {
     const host = process.env.HOST ?? '0.0.0.0';
     const port = Number(process.env.PORT ?? 3000);
     const app = await buildApp();
     await app.listen({ host, port });
     // eslint-disable-next-line no-console
     console.log(`PlantApp API listening on http://${host}:${port}`);
   }

   main().catch((err) => {
     // eslint-disable-next-line no-console
     console.error('Failed to start PlantApp API:', err);
     process.exit(1);
   });
   ```
2. **`backend/package.json`** — add two scripts (no new dependency):
   - `"build:run": "tsc -p tsconfig.json"` is NOT needed if `build` already exists — reuse `build`.
   - `"start": "node dist/src/server.js"` (runs the compiled server; assumes `npm run build` first).
   Keep all existing scripts unchanged. Do **not** add a TS-runtime dep; the run path is
   build-then-node.

### Forbidden
- No change to `app.ts` route handlers, the care engines, `auth.ts`, `config.ts`, `mappers.ts`,
  schemas, migrations, or Android. No new dependency. Do not alter `buildApp()`’s signature/behavior.
  No CORS needed (the Android client is not a browser). Don't commit `.env`/secrets/`dist/`.

### Standalone verification (the gate) — proves the HTTP server runs, routes, and auth-guards
```bash
cd /home/israel/Documents/Development/PlantApp/backend
npm run build                                   # tsc -> dist/ (expect dist/src/server.js)
# Boot with DUMMY env (server only needs the vars present; the no-token path 401s before touching Supabase):
SUPABASE_URL=http://127.0.0.1:54321 SUPABASE_ANON_KEY=dummy PORT=3000 node dist/src/server.js &
SRV=$!; sleep 2
echo -n "GET /plants (no token) -> "; curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:3000/plants   # expect 401
echo -n "startup log present -> "; (kill -0 $SRV 2>/dev/null && echo "server alive on :3000") || echo "server NOT alive"
kill $SRV 2>/dev/null
npm test                                         # unit still 72/72 (server.ts isn't imported by tests)
npm run typecheck && npm run lint                # clean
```
Expected: `dist/src/server.js` exists; the server boots and `GET /plants` with no token returns
**401** (server up + routing + auth hook working — no Supabase contact needed for the no-token
path); unit 72/72; typecheck + lint clean. This is **green** verification (the server runs).
Report the 401 + the startup log line.

### Commit + push
```bash
git -C /home/israel/Documents/Development/PlantApp add backend/src/server.ts backend/package.json
git -C /home/israel/Documents/Development/PlantApp commit -m "feat(backend): HTTP server bootstrap (server.ts + start script) for real runs"
git -C /home/israel/Documents/Development/PlantApp push origin master
```

### Final report
1. `server.ts` (host `0.0.0.0`, env PORT/HOST) + the `start` script.
2. The verification output: `dist/src/server.js` built, `GET /plants` → 401, server-alive log,
   `npm test` 72/72, typecheck + lint clean.
3. `git show --stat HEAD`; new commit hash; new `origin/master` SHA; confirm only
   `backend/src/server.ts` + `backend/package.json` changed.

## ⬆️ COPY EVERYTHING ABOVE THIS LINE ⬆️

---

## Planner follow-up after this lands
Verify (HEAD moved; only `server.ts` + `package.json`; server boots → 401; unit 72/72). Then
**step 2 (Android device-debug build)**: split the two base URLs (auth → Supabase
`http://10.0.0.179:54321/`, PlantApp API → Fastify `http://10.0.0.179:3000/`) via a
**debug-overridable** mechanism (BuildConfig/Gradle property — avoid committing a host-specific IP
as the production default) **and** add a **debug-only `network-security-config`** permitting
cleartext to the LAN host (the device blocker was `CLEARTEXT … not permitted`, not connectivity);
rebuild the debug APK. Then the planner (owner-approved this session) runs **Supabase + the Fastify
server bound to the LAN** (and the owner opens the `ufw` ports 54321 + 3000 to the LAN — `sudo`),
reinstalls the APK, and re-runs the device agent suite (`reviews/device-test-suite.md`) for the
real sign-in → add-plant → reminder-fires journey. Vision-check the Android step.
