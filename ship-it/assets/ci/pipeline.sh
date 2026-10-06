#!/usr/bin/env bash
# pipeline.sh — a miniature CI/CD server.
# Stages: TEST -> BUILD -> VERSION -> DEPLOY   (matching the architecture diagram)
#
# Usage:
#   ./ci/pipeline.sh --ci-only          # continuous integration: test + build, no deploy
#   ./ci/pipeline.sh                    # continuous deployment: green build goes live (default)
#   APPROVAL=manual ./ci/pipeline.sh    # continuous delivery: deploy, then wait for a human
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# --- preflight -------------------------------------------------------------
[ -f app/VERSION ] || { echo "X  app/VERSION not found - run me from the tutorial repo"; exit 1; }
V=$(cat app/VERSION)
[[ "$V" =~ ^[0-9]+$ ]] || { echo "X  app/VERSION must contain a plain number (found '$V')"; exit 1; }
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
C=$(git rev-parse --short HEAD 2>/dev/null || echo "no-commit-yet")

echo "=== pipeline start | change $C on $BRANCH -> release candidate v$V"

# --- [1/4] TEST ------------------------------------------------------------
echo "=== [1/4] TEST      | running automated unit tests"
if ! python3 -m unittest discover -s app/tests >/tmp/test.log 2>&1; then
  cat /tmp/test.log
  echo "X  TESTS FAILED - pipeline stops here; nothing was built or deployed"
  exit 1
fi
grep -E "^(Ran|OK)" /tmp/test.log || true
echo "   tests passed"

# --- [2/4] BUILD -----------------------------------------------------------
echo "=== [2/4] BUILD     | building a container image from the tested code"
if ! IMAGE=$(docker build -q app 2>/tmp/build.log); then
  cat /tmp/build.log
  echo "X  BUILD FAILED - pipeline stops here; nothing was deployed"
  exit 1
fi
echo "   image $IMAGE built"

# --- [3/4] VERSION ---------------------------------------------------------
echo "=== [3/4] VERSION   | registering the immutable, versioned artifact"
docker tag "$IMAGE" "app:$V"
echo "   artifact app:$V registered"

# --- the CI boundary ---------------------------------------------------------
if [ "${1:-}" = "--ci-only" ]; then
  echo "=== CI COMPLETE     | app:$V tested, built and versioned (continuous integration ends here)"
  exit 0
fi

# --- [4/4] DEPLOY ------------------------------------------------------------
case "${APPROVAL:-auto}" in
  auto|manual) ;;
  *) echo "X  APPROVAL must be 'auto' or 'manual' (found '${APPROVAL:-}')"; exit 1 ;;
esac
[ -f "$ROOT/.prod/live_color" ] || {
  echo "X  production is not running yet - start it first with:  ./deploy/bootstrap.sh  (Step 3)"
  exit 1
}

echo "=== [4/4] DEPLOY    | blue-green release of app:$V (APPROVAL=${APPROVAL:-auto})"
APPROVAL="${APPROVAL:-auto}" "$ROOT/deploy/deploy.sh" "$V"