#!/usr/bin/env python3
"""Generate batched seed SQL for the W2 catalog from scratch/catalog/profiles/*.json.

Planner-side staging ONLY: output goes to scratch/catalog/seed-sql/; the actual
migration files are installed by the implementation Claude via reviewed handoffs.

- Upserts (insert ... on conflict (id) do update) so the 5 Slice-1 seeded ids are
  enriched (version 2) rather than duplicated.
- Batched by category group for reviewability (each batch is one future migration).
- Run AFTER the houseplant enum lands (0060) and after the 9 houseplant profiles
  are recategorized in scratch — the script refuses to emit category values the
  DB constraint wouldn't accept.
"""
import json
import sys
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).parent
PROFILES = HERE / "profiles"
OUT = HERE / "seed-sql"

ALLOWED_CATEGORIES = {
    "fruit", "vegetable", "herb", "ornamental", "vine",
    "root", "berry", "succulent", "houseplant", "other",
}

# batch name -> categories (each batch becomes one migration file)
BATCHES = {
    "batch1_vegetables_roots": {"vegetable", "root"},
    "batch2_herbs_berries": {"herb", "berry"},
    "batch3_fruit_vines_succulents": {"fruit", "vine", "succulent"},
    "batch4_ornamentals_houseplants": {"ornamental", "houseplant", "other"},
}

COLUMNS = (
    "id, scientific_name, common_names, category, growth_habit, requires_support, "
    "self_fruitful, pollination_partners_required, watering_profile, feeding_profile, "
    "container_profile, light_profile, temperature_profile, seasonality, common_issues, "
    "vertical_suitability, source, version, last_reviewed_at"
)

UPDATE_COLS = [
    "scientific_name", "common_names", "category", "growth_habit", "requires_support",
    "self_fruitful", "pollination_partners_required", "watering_profile",
    "feeding_profile", "container_profile", "light_profile", "temperature_profile",
    "seasonality", "common_issues", "vertical_suitability", "source", "version",
    "last_reviewed_at",
]


def sq(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def lit(v, kind):
    if v is None:
        return "null"
    if kind == "text":
        return sq(str(v))
    if kind == "bool":
        return "true" if v else "false"
    if kind == "num":
        return repr(v) if not isinstance(v, bool) else ("true" if v else "false")
    if kind == "textarray":
        return "array[" + ",".join(sq(str(x)) for x in v) + "]::text[]"
    if kind == "jsonb":
        return sq(json.dumps(v, ensure_ascii=False, separators=(",", ":"))) + "::jsonb"
    if kind == "date":
        return sq(str(v))
    raise ValueError(kind)


def row_sql(p: dict) -> str:
    vals = [
        lit(p["id"], "text"),
        lit(p["scientificName"], "text"),
        lit(p["commonNames"], "textarray"),
        lit(p["category"], "text"),
        lit(p["growthHabit"], "text"),
        lit(p.get("requiresSupport", False), "bool"),
        lit(p.get("selfFruitful"), "bool"),
        lit(p.get("pollinationPartnersRequired", 0), "num"),
        lit(p["wateringProfile"], "jsonb"),
        lit(p["feedingProfile"], "jsonb"),
        lit(p["containerProfile"], "jsonb"),
        lit(p["lightProfile"], "jsonb"),
        lit(p["temperatureProfile"], "jsonb"),
        lit(p.get("seasonality"), "jsonb"),
        lit(p.get("commonIssues"), "textarray") if p.get("commonIssues") else "null",
        lit(p.get("verticalSuitability"), "num"),
        lit(p.get("source"), "jsonb"),
        lit(p["version"], "num"),
        lit(p.get("lastReviewedAt"), "date"),
    ]
    return "  (" + ", ".join(vals) + ")"


def main() -> int:
    profiles = []
    for f in sorted(PROFILES.glob("*.json")):
        p = json.loads(f.read_text())
        if p["category"] not in ALLOWED_CATEGORIES:
            print(f"REFUSE: {p['id']} category {p['category']!r} not in DB vocabulary")
            return 1
        profiles.append(p)
    if len(profiles) != 75:
        print(f"REFUSE: expected 75 profiles, found {len(profiles)}")
        return 1

    by_batch = defaultdict(list)
    for p in profiles:
        for name, cats in BATCHES.items():
            if p["category"] in cats:
                by_batch[name].append(p)
                break
        else:
            print(f"REFUSE: {p['id']} category {p['category']!r} matched no batch")
            return 1

    OUT.mkdir(exist_ok=True)
    total = 0
    update_set = ",\n  ".join(f"{c} = excluded.{c}" for c in UPDATE_COLS)
    for name, plist in sorted(by_batch.items()):
        rows = ",\n".join(row_sql(p) for p in sorted(plist, key=lambda x: x["id"]))
        sql = (
            f"-- W2 catalog seed {name} — {len(plist)} cited profiles "
            f"(generated from PlantAppPlanner scratch/catalog/profiles; sources embedded per row).\n"
            f"-- Upsert: already-seeded Slice-1 ids are enriched in place (version bump), never duplicated.\n"
            f"insert into public.plant_profiles (\n  {COLUMNS}\n) values\n{rows}\n"
            f"on conflict (id) do update set\n  {update_set};\n"
        )
        out = OUT / f"{name}.sql"
        out.write_text(sql)
        total += len(plist)
        print(f"{out.name}: {len(plist)} profiles")
    print(f"total: {total}/75")
    return 0 if total == 75 else 1


if __name__ == "__main__":
    sys.exit(main())
