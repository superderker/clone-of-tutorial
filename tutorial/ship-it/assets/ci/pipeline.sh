#!/usr/bin/env bash
# Installs a post-commit hook: every commit now triggers CI (test + build + version, no deploy)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$ROOT/.git/hooks/post-commit"

cat > "$HOOK" <<'EOF'
#!/usr/bin/env bash
cd "$(git rev-parse --show-toplevel)" && ./ci/pipeline.sh --ci-only
EOF
chmod +x "$HOOK"
echo "post-commit hook installed: every commit now triggers CI"