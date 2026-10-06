#!/usr/bin/env bash
# smoke.sh BASE_URL EXPECTED_VERSION — the pipeline's telemetry gate
# Polls until the service answers healthy AND serves the expected version
# Note: deliberately no `set -e` — failed attempts are the normal case here
set -u
URL="${1:-}"
WANT="${2:-}"
[ -n "$URL" ] && [ -n "$WANT" ] || { echo "usage: smoke.sh BASE_URL EXPECTED_VERSION" >&2; exit 1; }
[[ "$WANT" =~ ^[0-9]+$ ]] || { echo "X  EXPECTED_VERSION must be a plain number (found '$WANT')" >&2; exit 1; }

for i in $(seq 1 15); do
  H=$(curl -sf --max-time 2 "$URL/health")
  V=$(curl -sf --max-time 2 "$URL/version" | sed -n 's/.*"version": *"\([0-9]*\)".*/\1/p')
  if [ "${V:-}" = "$WANT" ] && printf '%s' "$H" | grep -q '"ok"'; then
    echo "smoke OK: $URL serves healthy v$WANT"
    exit 0
  fi
  printf '.'
  sleep 1
done
echo
echo "SMOKE FAILED: $URL never served a healthy v$WANT" >&2
echo "hint: curl $URL/health and curl $URL/version show what the service actually says" >&2
exit 1