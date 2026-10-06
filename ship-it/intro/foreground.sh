#!/usr/bin/env bash
# foreground.sh — gates the learner's terminal until background setup is done.
TIMEOUT=600   # seconds; generous backstop in case background.sh dies without a flag
waited=0

echo "Preparing your environment (installing tools, building v1 image)..."

while [ "$waited" -lt "$TIMEOUT" ]; do
    if [ -f /tmp/.tutorial_ready ]; then
        echo
        echo "Environment ready."
        echo "Your tutorial repo is in /root/tutorial."
        exit 0
    fi
    if [ -f /tmp/.tutorial_failed ]; then
        echo
        echo "Environment setup failed - please restart the scenario."
        exit 1
    fi
    sleep 2
    waited=$((waited + 2))
    [ $((waited % 10)) -eq 0 ] && printf '.'
done

echo
echo "Setup did not finish within 10 minutes (possibly a slow image pull)."
echo "Check 'docker images' for app:1 - if it is missing, restart the scenario."
exit 1