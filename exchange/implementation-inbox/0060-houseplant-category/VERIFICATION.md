# Standalone verification — 0060

Type: red-first → green at BOTH enforcement layers (shared schema + DB constraint).

## 1. RED (tests only; schema/migration unchanged)
Unit:
```
× plant-profile.schema.json — test #1 > accepts the 'pothos (houseplant category, W2 Gate …' seed profile
+     "message": "must be equal to one of the allowed values",
      Tests  1 failed | 72 passed (73)
```
Integration (env exported via `supabase status -o env`):
```
× W2 Gate B — plant_profiles.category accepts houseplant > check constraint allows houseplant (transaction rolled back)
  → new row for relation "plant_profiles" violates check constraint "plant_profiles_category_check"
 Test Files  1 failed | 8 passed (9)
      Tests  1 failed | 35 passed (36)
```

## 2. Migration apply
```
$ npx supabase db reset
…
Applying migration 0005_w2_houseplant_category.sql...
Finished supabase db reset on branch master.
```
Constraint name `plant_profiles_category_check` matched — no fallback query needed.

## 3. GREEN
```
$ npm test
 Test Files  11 passed (11)
      Tests  73 passed (73)

$ npm run test:int        (after the grants environment repair — see REPORT §5)
 Test Files  9 passed (9)
      Tests  36 passed (36)

$ npm run validate-schemas
schema ../shared-schemas/plant-instance.schema.json is valid
schema ../shared-schemas/plant-profile.schema.json is valid
schema ../shared-schemas/space-plan.schema.json is valid
```

## 4. Environment repair evidence (deviation, local-only)
Probe after reset: `42501 permission denied for table garden_spaces` for role `authenticated`
→ standard Supabase grants restored manually in the DB container (SQL in REPORT §5)
→ suite immediately 36/36. No repo file changed by the repair.
