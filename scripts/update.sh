#!/usr/bin/env bash
set -euo pipefail

# Scripts/update.sh - Check for new version on GitHub, pull, install and restart

echo "==> Fetching latest changes from remote (origin/main)..."
git fetch origin main

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "✓ You are already running the latest version."
    read -p "Do you want to force reinstall and restart anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
else
    echo "==> New updates found! Pulling changes..."
    git pull origin main
fi

echo "==> Installing updated package..."
./scripts/install.sh

echo "==> Update complete!"
