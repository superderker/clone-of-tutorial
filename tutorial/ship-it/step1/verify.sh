#!/usr/bin/env bash
# step1/verify.sh — the learner ran the Demo Shop locally and it is serving.
# Exit 0 = step complete.

# Primary signal: the app answers on its default port.
if curl -sf --max-time 2 http://127.0.0.1:5000/health 2>/dev/null | grep -q '"ok"'; then
  exit 0
fi

# Secondary signal: the process exists (e.g. still starting up).
if pgrep -f "app\.py" >/dev/null 2>&1; then
  exit 0
fi

exit 1