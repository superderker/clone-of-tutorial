#!/usr/bin/env bash
# background.sh — runs at environment startup, before the learner needs anything.
# Prepares tools, initializes the git repo (initial v1 commit), pre-pulls images,
# and builds the initial app:1 artifact. Signals foreground.sh via /tmp flags
set -euo pipefail

TUTORIAL="${HOME:-/root}/tutorial"
READY_FLAG=/tmp/.tutorial_ready
FAILED_FLAG=/tmp/.tutorial_failed

# The flag contract: background.sh must ALWAYS leave exactly one flag behind
# This trap guarantees it even on unexpected failures, so foreground.sh never hangs
on_exit() {
  status=$?
  if [ "$status" -ne 0 ] && [ ! -f "$READY_FLAG" ]; then
    touch "$FAILED_FLAG"
  fi
}
trap on_exit EXIT

rm -f "$READY_FLAG" "$FAILED_FLAG"

echo "Waiting for KillerCoda assets..."
for i in $(seq 1 60); do
  [ -f "$TUTORIAL/app/VERSION" ] && break
  sleep 1
done
if [ ! -f "$TUTORIAL/app/VERSION" ]; then
  echo "ERROR: KillerCoda assets were not copied to $TUTORIAL."
  exit 1
fi
echo "Assets detected!"

# asset integrity
for f in \
  app/app.py app/VERSION app/Dockerfile app/tests/test_app.py \
  ci/pipeline.sh \
  deploy/bootstrap.sh deploy/deploy.sh deploy/flip.sh deploy/approve.sh \
  deploy/rollback.sh deploy/smoke.sh deploy/nginx.server.template \
  new_change.sh; do
  [ -f "$TUTORIAL/$f" ] || { echo "ERROR: missing tutorial asset: $f"; exit 1; }
done

# required tools
missing=()
for t in python3 curl git; do
  command -v "$t" >/dev/null 2>&1 || missing+=("$t")
done
if [ "${#missing[@]}" -gt 0 ]; then
  echo "installing missing tools: ${missing[*]}"
  apt-get update -qq || true
  apt-get install -y -qq "${missing[@]}" >/dev/null || true
  for t in "${missing[@]}"; do
    command -v "$t" >/dev/null 2>&1 || { echo "ERROR: required tool '$t' is unavailable"; exit 1; }
  done
fi

# docker daemon readiness
for i in $(seq 1 30); do
  docker info >/dev/null 2>&1 && break
  sleep 2
done
docker info >/dev/null 2>&1 || { echo "ERROR: the docker daemon is not running"; exit 1; }

# executable scripts (existence proven by the integrity check above)
chmod +x "$TUTORIAL"/ci/*.sh "$TUTORIAL"/deploy/*.sh "$TUTORIAL"/new_change.sh

# git repository with the initial v1 release
cd "$TUTORIAL"
git config --global user.email "you@devops.tutorial"
git config --global user.name "DevOps Learner"
git config --global init.defaultBranch main || true

# Runtime state and bytecode must never enter git (new_change.sh commits with -A).
cat > .gitignore <<'EOF'
.prod/
__pycache__/
*.pyc
EOF

git init -q
git add -A
git commit -qm "v1: initial release"
git rev-parse --verify HEAD >/dev/null || { echo "ERROR: the initial git commit failed"; exit 1; }
echo "git repo initialized with the v1 release"

# pre-pull images and build the initial artifact
docker pull -q python:3.12-alpine >/dev/null 2>&1 || true
docker pull -q nginx:alpine >/dev/null 2>&1 || true

echo "Building initial app:1 image..."
if ! docker build -q -t app:1 "$TUTORIAL/app" >/tmp/build1.log 2>&1; then
  echo "   first attempt failed - retrying after pulling the base image..."
  docker pull -q python:3.12-alpine >/dev/null 2>&1 || true
  if ! docker build -q -t app:1 "$TUTORIAL/app" >/tmp/build1.log 2>&1; then
    echo "ERROR: could not build the initial app:1 image:"
    tail -5 /tmp/build1.log
    exit 1
  fi
fi
docker image inspect app:1 >/dev/null
echo "Initial app:1 image ready."

touch "$READY_FLAG"
echo "Setup complete!"