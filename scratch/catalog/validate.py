#!/usr/bin/env python3
"""Validate every scratch/catalog/profiles/*.json against plant-profile.schema.json.

Usage: python3 validate.py
Exit 0 = all valid; exit 1 = at least one invalid. Prints per-file pass/fail + a summary.
Read-only against PlantApp (only reads the shared schema). No PlantApp mutation.
"""
import json
import sys
from pathlib import Path

from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parent
SCHEMA = Path(
    "/home/israel/Documents/Development/PlantApp/shared-schemas/plant-profile.schema.json"
)
PROFILES = ROOT / "profiles"


def main() -> int:
    schema = json.loads(SCHEMA.read_text())
    validator = Draft202012Validator(schema)
    files = sorted(PROFILES.glob("*.json"))
    if not files:
        print("No profiles found in", PROFILES)
        return 1
    bad = 0
    for f in files:
        try:
            data = json.loads(f.read_text())
        except json.JSONDecodeError as e:
            print(f"FAIL {f.name}: JSON parse error: {e}")
            bad += 1
            continue
        errors = sorted(validator.iter_errors(data), key=lambda e: list(e.path))
        # id should match the filename stem
        id_ok = data.get("id") == f.stem
        has_source = bool(data.get("source"))
        if errors:
            print(f"FAIL {f.name}: {len(errors)} schema error(s)")
            for e in errors[:6]:
                loc = "/".join(str(p) for p in e.path) or "(root)"
                print(f"      - {loc}: {e.message}")
            bad += 1
        elif not id_ok:
            print(f"FAIL {f.name}: id '{data.get('id')}' != filename stem '{f.stem}'")
            bad += 1
        elif not has_source:
            print(f"WARN {f.name}: schema-valid but NO source citations")
        else:
            print(f"OK   {f.name}  ({len(data.get('source', []))} citation(s))")
    print(f"\n=== {len(files) - bad}/{len(files)} valid; {bad} invalid ===")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
