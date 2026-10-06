#!/usr/bin/env bash
# step4/verify.sh — continuous delivery: v2 went live on GREEN after human approval.
# Exit 0 = step complete.

RESP=$(curl -sf --max-time 2 http://127.0.0.1:8080/version 2>/dev/null || true)
V=$(printf '%s' "$RESP" | sed -n 's/.*"version": *"\([0-9]*\)".*/\1/p')
C=$(printf '%s' "$RESP" | sed -n 's/.*"color": *"\([a-z]*\)".*/\1/p')

[ "$V" = "2" ]     || exit 1   # v2 is live through the proxy
[ "$C" = "green" ] || exit 1   # served by the green environment
[ "$(cat "$HOME/tutorial/.prod/live_color" 2>/dev/null)" = "green" ] || exit 1

exit 0