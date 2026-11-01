#!/usr/bin/env bash
set -euo pipefail

# Scripts/test-window.sh - Run plasmoid in isolated plasmawindowed window

# Lavora sempre dalla radice del repo, ovunque venga lanciato lo script
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Launching plasmoid in isolated test window..."
exec plasmawindowed io.github.padelle.eartrumpet
