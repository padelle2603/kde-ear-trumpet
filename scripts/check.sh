#!/usr/bin/env bash
set -euo pipefail

# Scripts/check.sh - Quality gate & linting for kde-ear-trumpet

# Lavora sempre dalla radice del repo, ovunque venga lanciato lo script
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Running qmllint on QML files..."
if command -v qmllint &> /dev/null; then
    qmllint package/contents/ui/*.qml package/contents/config/*.qml
    echo "✓ qmllint passed cleanly."
else
    echo "⚠ qmllint not found, skipping QML linting."
fi

echo "==> Validating metadata.json..."
if command -v python3 &> /dev/null; then
    python3 -m json.tool package/metadata.json > /dev/null
    echo "✓ metadata.json is valid JSON."
else
    echo "⚠ python3 not found, skipping JSON validation."
fi

echo "==> All quality checks passed successfully!"
