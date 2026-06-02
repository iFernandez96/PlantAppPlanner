# VERIFICATION — handoff 0038-backend-server-bootstrap

Gate: build → boot → probe (401) → unit/typecheck/lint. This is a green run-the-server check (no
new red-first test — the prompt's gate is the live HTTP boot).

## Build + boot + route + auth-guard
```
$ cd backend && npm run build
$ ls dist/src/server.js                         # exists
$ SUPABASE_URL=http://127.0.0.1:54321 SUPABASE_ANON_KEY=dummy PORT=3000 node dist/src/server.js &
PlantApp API listening on http://0.0.0.0:3000    # startup log
$ curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:3000/plants
401                                              # server up + routing + auth hook (no Supabase needed)
# server alive on :3000
```

## Unchanged suites
```
$ npm test            Tests 72 passed (72)        # server.ts not imported by tests
$ npm run typecheck   clean
$ npm run lint        clean (after removing unused no-console disable directives)
```

## Scope / integrity
- `git show --stat`: 2 files, +18 — only `backend/src/server.ts` (new) + `backend/package.json`
  (one `start` script). No change to `app.ts` handlers / care engines / `auth.ts` / `config.ts` /
  `mappers.ts` / schemas / migrations / Android. No new dependency. `buildApp()` unchanged.
- `backend/dist/` is git-ignored (`git check-ignore` confirms); no `dist/`/`.env`/secrets committed.

## Final repo state
- origin/master = `e95c40ee0712d8e57d667f07f33d5974f99323bd`; local == origin.
- Working tree clean (except git-ignored `backend/dist/` build output + `android/local.properties`).
