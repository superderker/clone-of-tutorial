#!/usr/bin/env bash
# step2/verify.sh — continuous integration: app:2 was built and versioned,
# and the pipeline stopped BEFORE any deployment (the CI boundary).
# Exit 0 = step complete.

# 1. The versioned artifact exists.
docker image inspect app:2 >/dev/null 2>&1 || exit 1

# 2. No production environment was created - CI ends before deploy.
RUNNING=$(docker ps --format '{{.Names}}' 2>/dev/null || true)
for c in app-blue app-green proxy; do
  printf '%s\n' "$RUNNING" | grep -qx "$c" && exit 1
done

exit 0