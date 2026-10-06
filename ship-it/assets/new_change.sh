#!/usr/bin/env bash
# Simulates a developer committing a change.
# Usage: ./new_change.sh VERSION [--broken] [--beta]
#   VERSION   plain number written to app/VERSION (e.g. 2)
#   --broken  ship a bad production config (invisible to unit tests, caught by smoke tests)
#   --beta    enable the beta feature flag (dark launch)
#
# NOTE: unlike the ci/ and deploy/ scripts, this file lives at the REPO ROOT,
# so ROOT is the script's own directory - no /.. .
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
[ -d "$ROOT/app" ] || { echo "X  app/ not found next to new_change.sh - run me from the tutorial repo root"; exit 1; }

# validate everything BEFORE mutating anything
V="${1:?usage: new_change.sh VERSION [--broken] [--beta]}"; shift
[[ "$V" =~ ^[0-9]+$ ]] || { echo "X  VERSION must be a plain number, e.g. 2 (found '$V')"; exit 1; }
for a in "$@"; do
  case "$a" in
    --broken|--beta) ;;
    *) echo "X  unknown flag '$a' - expected --broken or --beta"; exit 1 ;;
  esac
done

# apply the change
echo "$V" > app/VERSION
rm -f app/BROKEN app/BETA_ON
for a in "$@"; do
  case "$a" in
    --broken) touch app/BROKEN ;;   # bad production config, invisible to unit tests
    --beta)   touch app/BETA_ON ;;  # enable the beta feature flag
  esac
done

# commit
# Runtime state (.prod/) and bytecode (__pycache__) must never enter git.
if [ ! -f .gitignore ]; then
  printf '%s\n' '__pycache__/' '*.pyc' '.prod/' > .gitignore
fi
git config user.email >/dev/null 2>&1 || git config --local user.email "dev@demoshop.example"
git config user.name  >/dev/null 2>&1 || git config --local user.name  "Demo Shop Developer"
git add -A
if git diff --cached --quiet; then
  echo "nothing to commit - v$V with these flags is already the committed state"
  exit 0
fi
git commit -qm "release v$V${*:+ $*}"
echo "committed: $(git log --oneline -1)"