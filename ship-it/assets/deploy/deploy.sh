#!/usr/bin/env bash
# Blue-green release of one version to the idle color, with verification gate
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE="$ROOT/.prod"
CANDIDATE="$STATE/candidate"

V="${1:?usage: deploy.sh VERSION}"
[[ "$V" =~ ^[0-9]+$ ]] || { echo "X  VERSION must be a plain number (found '$V')"; exit 1; }
case "${APPROVAL:-auto}" in
  auto|manual) ;;
  *) echo "X  APPROVAL must be 'auto' or 'manual' (found '${APPROVAL:-}')"; exit 1 ;;
esac
[ -f "$STATE/live_color" ] || { echo "X  production is not running - start it first with:  ./deploy/bootstrap.sh  (Step 3)"; exit 1; }
docker image inspect "app:$V" >/dev/null 2>&1 || {
  echo "X  image app:$V not found - the pipeline must build it first:  ./ci/pipeline.sh"
  exit 1
}

LIVE=$(cat "$STATE/live_color")
[ "$LIVE" = blue ] && IDLE=green || IDLE=blue
PORT=$([ "$IDLE" = blue ] && echo 8081 || echo 8082)

echo "live=$LIVE  idle=$IDLE  ->  deploying v$V to $IDLE (users unaffected)"

# Configuration is code: container env is derived from files versioned in the repo
BROKEN=false; [ -f "$ROOT/app/BROKEN" ] && BROKEN=true
BETA=off;     [ -f "$ROOT/app/BETA_ON" ] && BETA=on

docker rm -f "app-$IDLE" >/dev/null 2>&1 || true
docker run -d --name "app-$IDLE" --network cdnet -p "$PORT:5000" \
  -e COLOR="$IDLE" -e BROKEN="$BROKEN" -e FEATURE_BETA="$BETA" "app:$V" >/dev/null

if ! "$ROOT/deploy/smoke.sh" "http://127.0.0.1:$PORT" "$V"; then
  echo "X  v$V FAILED verification on $IDLE - aborting release"
  echo "   users are still on $LIVE; nobody saw anything"
  docker rm -f "app-$IDLE" >/dev/null
  rm -f "$CANDIDATE"
  exit 1
fi
echo "OK v$V verified on $IDLE (direct check on :$PORT)"

if [ "${APPROVAL:-auto}" = "manual" ]; then
  echo "$IDLE $V" > "$CANDIDATE"
  echo "|| RELEASE CANDIDATE READY - delivery mode: waiting for human approval"
  echo "   inspect it on :$PORT, then run:  ./deploy/approve.sh"
  exit 0
fi

rm -f "$CANDIDATE"   # an automated release consumes the candidate slot
if ! "$ROOT/deploy/flip.sh" "$IDLE"; then
  echo "X  could not switch traffic to $IDLE - users are still on $LIVE"
  echo "$IDLE $V" > "$CANDIDATE"
  echo "   v$V stays on $IDLE (port $PORT) as a verified candidate"
  echo "   once the proxy is healthy again, ./deploy/approve.sh can release it"
  exit 1
fi
if ! "$ROOT/deploy/smoke.sh" http://127.0.0.1:8080 "$V"; then
  echo "X  post-flip check failed - rolling back automatically"
  "$ROOT/deploy/rollback.sh"
  exit 1
fi
echo "OK v$V is LIVE on $IDLE"