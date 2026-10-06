#!/usr/bin/env bash
# Repoints the proxy at a color and reloads nginx
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE="$ROOT/.prod"
TARGET="${1:-}"

case "$TARGET" in
  blue|green) ;;
  *) echo "usage: flip.sh blue|green" >&2; exit 1 ;;
esac
[ -f "$STATE/live_color" ] || { echo "X  production is not running - run ./deploy/bootstrap.sh first (Step 3)"; exit 1; }
LIVE=$(cat "$STATE/live_color")

if [ "$TARGET" = "$LIVE" ]; then
  echo "note: $TARGET is already live - nothing to do"
  exit 0
fi
docker ps --format '{{.Names}}' | grep -qx "app-$TARGET" \
  || { echo "X  app-$TARGET is not running - deploy to $TARGET first"; exit 1; }
docker ps --format '{{.Names}}' | grep -qx proxy \
  || { echo "X  the proxy is not running - run ./deploy/bootstrap.sh"; exit 1; }

write_conf() { sed "s/__COLOR__/$1/" "$ROOT/deploy/nginx.server.template" > "$STATE/conf.d/server.conf"; }

write_conf "$TARGET"
if ! docker exec proxy nginx -s reload; then
  write_conf "$LIVE"; docker exec proxy nginx -s reload || true
  echo "X  nginx refused the new configuration - traffic unchanged ($LIVE)"; exit 1
fi

# Wait until the new configuration actually serves a healthy response
ok=0
for i in $(seq 1 10); do
  if curl -sf --max-time 2 http://127.0.0.1:8080/health >/dev/null; then ok=1; break; fi
  sleep 0.5
done
if [ "$ok" != 1 ]; then
  write_conf "$LIVE"; docker exec proxy nginx -s reload || true
  echo "X  $TARGET did not serve a healthy response through the proxy - reverted to $LIVE"; exit 1
fi

echo "$TARGET" > "$STATE/live_color"
echo "traffic flipped -> $TARGET"