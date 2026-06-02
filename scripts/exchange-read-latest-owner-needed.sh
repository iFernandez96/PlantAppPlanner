#!/usr/bin/env bash
# Reader for the latest (or a given) owner-needed decision packet. Reads ONLY
# owner-needed/<id>/ containing READY.json. Never reads .writing/. Verifies
# SHA256SUMS. NEVER touches the PlantApp app repo. See exchange/README.md (PD-06).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXCHANGE="$REPO_ROOT/exchange"
ON="$EXCHANGE/owner-needed"
POINTERS="$EXCHANGE/pointers"

die() { echo "ERROR: $*" >&2; exit 1; }

ID="${1:-}"
if [ -z "$ID" ]; then
  [ -f "$POINTERS/latest-owner-needed" ] || die "no latest-owner-needed pointer; none open"
  ID="$(cat "$POINTERS/latest-owner-needed")"
fi
echo "$ID" | grep -Eq '^[A-Za-z0-9._-]+$' || die "invalid id '$ID'"
case "$ID" in .writing|.writing/*) die "refusing to read .writing (incomplete)";; esac

DIR="$ON/$ID"
[ -d "$DIR" ] || die "owner-needed dir not found: $DIR"
[ -f "$DIR/READY.json" ] || die "no READY.json in $DIR — not ready; refusing to read"
( cd "$DIR" && sha256sum -c SHA256SUMS >/dev/null ) || die "checksum mismatch in $DIR — refusing to read"

echo "# OWNER-NEEDED: $ID" >&2
cat "$DIR/DECISION.md"
