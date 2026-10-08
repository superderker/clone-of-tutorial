#!/usr/bin/env bash
# step8/verify.sh — a commit triggered CI on its own (hook installed, v6 built by the hook).
HOOK="$HOME/tutorial/.git/hooks/post-commit"
[ -x "$HOOK" ] || exit 1
grep -q "CI COMPLETE.*app:6" "$HOME/tutorial/.prod/pipeline.log" 2>/dev/null || exit 1
docker image inspect app:6 >/dev/null 2>&1 || exit 1
exit 0