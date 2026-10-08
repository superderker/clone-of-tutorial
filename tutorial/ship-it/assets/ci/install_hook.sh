#!/usr/bin/env bash
# Installs a post-commit hook: every commit now triggers CI (test + build + version, no deploy)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$ROOT/.git/hooks/post-commit"
mkdir -p "$ROOT/.prod"

cat > "$HOOK" <<'EOF'
#!/usr/bin/env bash
ROOT="$(git rev-parse --show-toplevel)"
mkdir -p "$ROOT/.prod"
( cd "$ROOT" && ./ci/pipeline.sh --ci-only ) >> "$ROOT/.prod/pipeline.log" 2>&1 &
EOF
chmod +x "$HOOK"
echo "post-commit hook installed: every commit now triggers CI"