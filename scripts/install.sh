#!/usr/bin/env bash
set -euo pipefail

# Scripts/install.sh - Install or upgrade the plasmoid locally

# Lavora sempre dalla radice del repo, ovunque venga lanciato lo script
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Running quality checks before installation..."
if [ -f "$REPO_ROOT/scripts/check.sh" ]; then
    "$REPO_ROOT/scripts/check.sh"
fi

echo "==> Installing/Upgrading plasmoid using kpackagetool6..."
if kpackagetool6 --type Plasma/Applet --list | grep -q "io.github.padelle.eartrumpet"; then
    kpackagetool6 --type Plasma/Applet --upgrade "$REPO_ROOT/package"
    echo "✓ Plasmoid successfully upgraded."
else
    kpackagetool6 --type Plasma/Applet --install "$REPO_ROOT/package"
    echo "✓ Plasmoid successfully installed."
fi

# Chiedi se riavviare plasmashell
REPLY=""
read -p "Do you want to restart Plasma Shell to apply changes immediately? [y/N] " -n 1 -r || true
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "==> Restarting Plasma Shell..."
    kquitapp6 plasmashell 2>/dev/null || true
    plasmashell --replace &>/dev/null &
    echo "✓ Plasma Shell restarted."
fi

echo "==> Done!"
