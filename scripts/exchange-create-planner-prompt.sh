#!/usr/bin/env bash
# Planner-only. Atomically publish a prompt into exchange/planner-outbox/<id>/.
# Builds in .writing/, writes READY.json last, atomically renames into the outbox,
# then updates pointers/latest-ready-prompt via .tmp + mv.
# NEVER touches the PlantApp app repo. See exchange/README.md (PD-06).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXCHANGE="$REPO_ROOT/exchange"
OUTBOX="$EXCHANGE/planner-outbox"
WRITING="$OUTBOX/.writing"
POINTERS="$EXCHANGE/pointers"
LOCKS="$EXCHANGE/locks"

die() { echo "ERROR: $*" >&2; exit 1; }

[ "$#" -eq 2 ] || die "usage: $(basename "$0") <handoff-id> <prompt-file.md>"
ID="$1"
SRC="$2"

echo "$ID" | grep -Eq '^[A-Za-z0-9._-]+$' || die "invalid handoff-id '$ID' (allowed: A-Za-z0-9._-)"
[ -f "$SRC" ] || die "prompt file not found: $SRC"
[ -d "$EXCHANGE" ] || die "exchange dir missing: $EXCHANGE"

# Safety: never read the prompt source out of the PlantApp app repo.
SRC_ABS="$(cd "$(dirname "$SRC")" && pwd)/$(basename "$SRC")"
case "$SRC_ABS" in
  */PlantApp/*) die "refusing to read from the PlantApp app repo: $SRC_ABS" ;;
esac

DEST="$OUTBOX/$ID"
STAGE="$WRITING/$ID"
[ ! -e "$DEST" ] || die "outbox entry already exists (immutable): $DEST"
[ ! -e "$STAGE" ] || die "stale staging dir exists: $STAGE (remove it first)"

LOCK="$LOCKS/planner-outbox.lock"
mkdir "$LOCK" 2>/dev/null || die "another planner write is in progress ($LOCK)"
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

mkdir -p "$STAGE"
cp "$SRC" "$STAGE/PROMPT.md"

cat > "$STAGE/MANIFEST.json" <<EOF
{
  "id": "$ID",
  "kind": "prompt",
  "status": "ready",
  "producer": "planner",
  "createdUtc": "$NOW",
  "sourceFile": "$(basename "$SRC")",
  "files": ["PROMPT.md"]
}
EOF

# Checksums over content files. READY.json is the completion marker, not content.
( cd "$STAGE" && sha256sum PROMPT.md MANIFEST.json > SHA256SUMS )

# READY.json LAST, inside .writing; presence (after the atomic mv) == readable.
cat > "$STAGE/READY.json" <<EOF
{
  "id": "$ID",
  "kind": "prompt",
  "status": "ready",
  "producer": "planner",
  "createdUtc": "$NOW",
  "checksums": "SHA256SUMS"
}
EOF

# Atomic publish (rename within the same filesystem).
mv "$STAGE" "$DEST"

# Atomic pointer update.
printf '%s\n' "$ID" > "$POINTERS/latest-ready-prompt.tmp"
mv "$POINTERS/latest-ready-prompt.tmp" "$POINTERS/latest-ready-prompt"

echo "published prompt: $DEST"
echo "pointer updated:  $POINTERS/latest-ready-prompt -> $ID"
