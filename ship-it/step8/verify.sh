#!/usr/bin/env bash
# step8/verify.sh — wrap-up: the repo carries the release history
# (initial v1 plus at least three shipped releases).
# Exit 0 = step complete.

COUNT=$(git -C "$HOME/tutorial" rev-list --count HEAD 2>/dev/null || echo 0)
[ "$COUNT" -ge 4 ] || exit 1

exit 0