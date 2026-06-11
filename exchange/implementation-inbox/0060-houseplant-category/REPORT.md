# Implementation report — 0060-houseplant-category

## Status: DONE (one environment deviation — see §5; repo changes exactly per prompt)

## 1. Scope confirmation + git show --stat HEAD
Only the 4 listed files changed:
```
 .../houseplant-category.integration.test.ts        | 30 ++++++++++++++++++++++ (new)
 backend/tests/schema/plant-profile.test.ts         | 18 +++++++++++++
 shared-schemas/plant-profile.schema.json           |  2 +-
 .../migrations/0005_w2_houseplant_category.sql     |  9 +++++++ (new)
 4 files changed, 58 insertions(+), 1 deletion(-)
```
- Schema enum: `"houseplant"` inserted after `"succulent"`, before `"other"` (the file uses a
  single-line enum, so the entry was added inline matching the existing style).
- Migration 0005: verbatim §5b. The auto-generated constraint name matched
  (`plant_profiles_category_check`) — drop/add applied cleanly, no name deviation.
- Pothos schema fixture + the rolled-back-transaction integration test: verbatim §5c/§5d.
- No seed/backend-src/Android/engine changes; migrations 0001–0004 untouched;
  `android/.kotlin/` left untracked.

## 2. RED evidence (tests added first, no schema/migration change)
Unit (`npm test`):
```
× accepts the 'pothos (houseplant category, W2 Gate B)' seed profile
+     "message": "must be equal to one of the allowed values",
      Tests  1 failed | 72 passed (73)
```
Integration (`npm run test:int`, Supabase env loaded):
```
× W2 Gate B — plant_profiles.category accepts houseplant > check constraint allows houseplant (transaction rolled back)
  → new row for relation "plant_profiles" violates check constraint "plant_profiles_category_check"
 Test Files  1 failed | 8 passed (9)
      Tests  1 failed | 35 passed (36)
```
Both layers red exactly as predicted; nothing else failed.
(Note: `test:int` must run with `supabase status -o env` exported — without it 6 files fail on
missing env; that is pre-existing harness behavior, not part of the red.)

## 3. GREEN outputs (after schema + migration + `supabase db reset` applying 0001–0005)
```
npm test               →  Test Files  11 passed (11)   Tests  73 passed (73)
npm run test:int       →  Test Files   9 passed (9)    Tests  36 passed (36)
npm run validate-schemas →
  schema ../shared-schemas/plant-instance.schema.json is valid
  schema ../shared-schemas/plant-profile.schema.json is valid
  schema ../shared-schemas/space-plan.schema.json is valid
```
`db reset` output ended: `Applying migration 0005_w2_houseplant_category.sql... Finished
supabase db reset on branch master.`

## 4. Commit + push
- New commit: `22067b6a619f8b955db2ee24df0212be40c231d2`
- Title (exact): `feat(schema): add houseplant category to plant-profile vocabulary (schema + DB)`
- Pushed: `1a5dede..22067b6  master -> master` (fast-forward);
  new `origin/master` = `22067b6a619f8b955db2ee24df0212be40c231d2`.

## 5. Deviations
**One environment-repair deviation (no repo change):** after `supabase db reset`, the whole
integration suite (not just the new test) failed — every authed POST returned 400. Probe
showed Postgres error `42501 permission denied for table garden_spaces`: the reset rebuilt the
DB **without the standard Supabase grants** for `anon/authenticated/service_role` on schema
`public`. No migration in the repo has ever issued GRANTs — those grants previously came from
the platform's default privileges, and the current (unpinned `npx supabase`) CLI/image no
longer applies them on reset. The §6 Kong-restart remedy did not apply (Kong was healthy).
I restored the environment manually inside the local DB container:
```sql
grant usage on schema public to anon, authenticated, service_role;
grant all on all tables    in schema public to anon, authenticated, service_role;
grant all on all sequences in schema public to anon, authenticated, service_role;
grant all on all functions in schema public to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables    to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
```
after which the full integration suite went 36/36. **Planner follow-up recommended:** every
future `db reset` will hit this again until a grants migration (or a pinned CLI version) is
added — suggest a dedicated slice adding e.g. `0006_grants.sql` with the statements above
(they are the standard Supabase defaults; RLS still governs row access). Also note (per §6,
expected): the reset wiped local auth users — the device test account must re-sign-in via
Mailpit.
