#!/usr/bin/env bash
# Creates production from scratch: network, blue env (v1), proxy on :8080
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE="$ROOT/.prod"
mkdir -p "$STATE/conf.d"
rm -f "$STATE/candidate"

docker network create cdnet 2>/dev/null || true
docker rm -f app-blue app-green proxy 2>/dev/null || true

# The pipeline (Step 2) built app:2; production starts from the INITIAL commit (v1)
if ! docker image inspect app:1 >/dev/null 2>&1; then
  ROOT_COMMIT=$(git rev-list --max-parents=0 HEAD 2>/dev/null | head -n1 || true)
  if [ -z "$ROOT_COMMIT" ]; then
    echo "X  image app:1 is missing and no initial commit was found"
    echo "   the setup should have made an initial commit of the v1 code - restart the scenario"
    exit 1
  fi
  echo "building image app:1 from the initial commit $(git rev-parse --short "$ROOT_COMMIT") ..."
  git archive "$ROOT_COMMIT:app" | docker build -q -t app:1 - >/dev/null \
    || { echo "X  failed to build app:1"; exit 1; }
  echo "   image app:1 built"
fi

echo "starting BLUE environment with v1 ..."
docker run -d --name app-blue --network cdnet -p 8081:5000 -e COLOR=blue app:1 >/dev/null

sed "s/__COLOR__/blue/" "$ROOT/deploy/nginx.server.template" > "$STATE/conf.d/server.conf"
echo "starting reverse proxy on :8080 ..."
docker run -d --name proxy --network cdnet -p 8080:80 \
  -v "$STATE/conf.d":/etc/nginx/conf.d:ro nginx:alpine >/dev/null

sleep 1
docker ps --format '{{.Names}}' | grep -qx proxy || {
  echo "X  the proxy failed to start - its logs:"
  docker logs proxy 2>&1 | tail -5
  exit 1
}

echo blue > "$STATE/live_color"
"$ROOT/deploy/smoke.sh" http://127.0.0.1:8081 1
"$ROOT/deploy/smoke.sh" http://127.0.0.1:8080 1
echo "production is up: v1 live on BLUE"