#!/usr/bin/env bash
# step6/verify.sh — the verification gate stopped the broken release:
# users are still on v3 (blue) and the failed green environment is gone.
# Exit 0 = step complete.

RESP=$(curl -sf --max-time 2 http://127.0.0.1:8080/version 2>/dev/null || true)
V=$(printf '%s' "$RESP" | sed -n 's/.*"version": *"\([0-9]*\)".*/\1/p')
C=$(printf '%s' "$RESP" | sed -n 's/.*"color": *"\([a-z]*\)".*/\1/p')

[ "$V" = "3" ]    || exit 1   # users never left v3
[ "$C" = "blue" ] || exit 1   # ...on blue
[ "$(cat "$HOME/tutorial/.prod/live_color" 2>/dev/null)" = "blue" ] || exit 1

# The failed v4 environment was torn down by the aborted release.
if printf '%s\n' "$(docker ps --format '{{.Names}}' 2>/dev/null)" | grep -qx app-green; then
  exit 1
fi

exit 0