#!/usr/bin/env bash
# The human gate of continuous delivery: promote the verified candidate
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE="$ROOT/.prod"
CANDIDATE="$STATE/candidate"

[ -f "$CANDIDATE" ] || {
  echo "X  no release candidate is waiting for approval"
  echo "   create one with:  APPROVAL=manual ./ci/pipeline.sh"
  exit 1
}
read -r COLOR V < "$CANDIDATE"
case "$COLOR" in
  blue|green) ;;
  *) echo "X  corrupt candidate state - re-run the pipeline"; exit 1 ;;
esac
PORT=$([ "$COLOR" = blue ] && echo 8081 || echo 8082)

# Defense in depth: confirm the candidate still serves what the pipeline verified
RUNNING=$(curl -sf --max-time 2 "http://127.0.0.1:$PORT/version" | sed -n 's/.*"version": *"\([0-9]*\)".*/\1/p')
[ "$RUNNING" = "$V" ] || {
  echo "X  the candidate on $COLOR no longer serves v$V (found '${RUNNING:-nothing}')"
  echo "   re-run the pipeline to create a fresh candidate"
  exit 1
}

echo "human approval granted -> releasing v$V from $COLOR"
"$ROOT/deploy/flip.sh" "$COLOR"
"$ROOT/deploy/smoke.sh" http://127.0.0.1:8080 "$V"
rm -f "$CANDIDATE"
echo "OK v$V is LIVE"