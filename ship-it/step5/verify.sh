#!/usr/bin/env bash
# step5/verify.sh — continuous deployment: v3 went live on BLUE with no human gate.
# Exit 0 = step complete.

RESP=$(curl -sf --max-time 2 http://127.0.0.1:8080/version 2>/dev/null || true)
V=$(printf '%s' "$RESP" | sed -n 's/.*"version": *"\([0-9]*\)".*/\1/p')
C=$(printf '%s' "$RESP" | sed -n 's/.*"color": *"\([a-z]*\)".*/\1/p')

[ "$V" = "3" ]    || exit 1   # v3 is live through the proxy
[ "$C" = "blue" ] || exit 1   # served by the blue environment
[ "$(cat "$HOME/tutorial/.prod/live_color" 2>/dev/null)" = "blue" ] || exit 1

exit 0