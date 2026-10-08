#!/usr/bin/env bash
# step8/verify.sh — the hook is installed and a commit built app:6 without a manual pipeline run.
[ -x "$HOME/tutorial/.git/hooks/post-commit" ] || exit 1
[ -f "$HOME/tutorial/.prod/hook_ran" ] || exit 1
docker image inspect app:6 >/dev/null 2>&1 || exit 1
exit 0