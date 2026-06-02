#!/usr/bin/env bash
# Planner-only. Atomically publish an owner-decision packet into
# exchange/owner-needed/<id>/. Builds in .writing/, writes READY.json last, renames
# into place, updates pointers/latest-owner-needed via .tmp + mv.
# NEVER touches the PlantApp app repo. See exchange/README.md (PD-06).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXCHANGE="$REPO_ROOT/exchange"
ON="$EXCHANGE/owner-needed"
WRITING="$ON/.writing"
POINTERS="$EXCHANGE/pointers"
LOCKS="$EXCHANGE/locks"

die() { echo "ERROR: $*" >&2; exit 1; }

[ "$#" -eq 2 ] || die "usage: $(basename "$0") <id> <decision-file.md>"
ID="$1"
SRC="$2"

echo "$ID" | grep -Eq '^[A-Za-z0-9._-]+$' || die "invalid id '$ID' (allowed: A-Za-z0-9._-)"
[ -f "$SRC" ] || die "decision file not found: $SRC"
SRC_ABS="$(cd "$(dirname "$SRC")" && pwd)/$(basename "$SRC")"
case "$SRC_ABS" in */PlantApp/*) die "refusing to read from the PlantApp app repo: $SRC_ABS" ;; esac

DEST="$ON/$ID"
STAGE="$WRITING/$ID"
mkdir -p "$ON" "$WRITING" "$POINTERS" "$LOCKS"
[ ! -e "$DEST" ] || die "owner-needed entry already exists (immutable): $DEST"
[ ! -e "$STAGE" ] || die "stale staging dir exists: $STAGE"

LOCK="$LOCKS/owner-needed.lock"
mkdir "$LOCK" 2>/dev/null || die "another owner-needed write is in progress ($LOCK)"
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
mkdir -p "$STAGE"
cp "$SRC" "$STAGE/DECISION.md"

cat > "$STAGE/MANIFEST.json" <<EOF
{
  "id": "$ID",
  "kind": "owner-needed",
  "status": "open",
  "producer": "planner",
  "createdUtc": "$NOW",
  "files": ["DECISION.md"]
}
EOF

( cd "$STAGE" && sha256sum DECISION.md MANIFEST.json > SHA256SUMS )

cat > "$STAGE/READY.json" <<EOF
{
  "id": "$ID",
  "kind": "owner-needed",
  "status": "open",
  "producer": "planner",
  "createdUtc": "$NOW",
  "checksums": "SHA256SUMS"
}
EOF

mv "$STAGE" "$DEST"

printf '%s\n' "$ID" > "$POINTERS/latest-owner-needed.tmp"
mv "$POINTERS/latest-owner-needed.tmp" "$POINTERS/latest-owner-needed"

echo "owner-needed published: $DEST"
echo "pointer updated: $POINTERS/latest-owner-needed -> $ID"
