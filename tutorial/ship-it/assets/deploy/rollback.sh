#!/usr/bin/env bash
# Instant rollback = flip back to the previous, still-running environment
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE="$ROOT/.prod"
CANDIDATE="$STATE/candidate"

[ -f "$STATE/live_color" ] || { echo "X  production is not running - run ./deploy/bootstrap.sh first (Step 3)"; exit 1; }
LIVE=$(cat "$STATE/live_color")
[ "$LIVE" = blue ] && OTHER=green || OTHER=blue
PORT=$([ "$OTHER" = blue ] && echo 8081 || echo 8082)

# A pending, unapproved candidate is not a rollback target
if [ -f "$CANDIDATE" ]; then
  read -r C_COLOR C_V < "$CANDIDATE"
  if [ "$C_COLOR" = "$OTHER" ]; then
    echo "X  the other environment ($OTHER) holds the unapproved candidate v$C_V"
    echo "   approve it (./deploy/approve.sh) or replace it by deploying a new version"
    exit 1
  fi
fi

docker ps --format '{{.Names}}' | grep -qx "app-$OTHER" \
  || { echo "no previous release to roll back to - you must roll FORWARD (fix and redeploy)"; exit 1; }
V=$(curl -sf --max-time 2 "http://127.0.0.1:$PORT/version" | sed -n 's/.*"version": *"\([0-9]*\)".*/\1/p')
[ -n "$V" ] || { echo "X  could not read a version from app-$OTHER - is it healthy?"; exit 1; }
echo "rolling back: $LIVE -> $OTHER (v$V)"
"$ROOT/deploy/flip.sh" "$OTHER"
"$ROOT/deploy/smoke.sh" http://127.0.0.1:8080 "$V"
echo "OK rollback complete - v$V is live again"