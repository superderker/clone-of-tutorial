#!/usr/bin/env bash
# step7/verify.sh — rollback: v5 shipped to green, traffic came back to v3.
# Users are on v3 (blue); the rolled-back v5 still runs on green, offline.
# Exit 0 = step complete.

# Users are back on the previous release, served by blue through the proxy.
RESP=$(curl -sf --max-time 2 http://127.0.0.1:8080/version 2>/dev/null || true)
V=$(printf '%s' "$RESP" | sed -n 's/.*"version": *"\([0-9]*\)".*/\1/p')
C=$(printf '%s' "$RESP" | sed -n 's/.*"color": *"\([a-z]*\)".*/\1/p')
[ "$V" = "3" ]    || exit 1
[ "$C" = "blue" ] || exit 1
[ "$(cat "$HOME/tutorial/.prod/live_color" 2>/dev/null)" = "blue" ] || exit 1

# The rolled-back release (v5) is still running on green, just offline.
# Without this, the check would pass even if the learner skipped the step.
G=$(curl -sf --max-time 2 http://127.0.0.1:8082/version 2>/dev/null | sed -n 's/.*"version": *"\([0-9]*\)".*/\1/p')
[ "$G" = "5" ] || exit 1

exit 0