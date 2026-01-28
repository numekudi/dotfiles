#!/bin/bash

# Simple dotfiles install script

set -e

# Check if stow is installed
if ! command -v stow >/dev/null 2>&1; then
    echo "Error: stow is required but not installed."
    echo "Install it with: brew install stow (macOS) or sudo apt install stow (Linux)"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Install all dotfiles
echo "Installing dotfiles..."

for dir in */; do
    if [ -d "$dir" ] && [ "$dir" != ".git/" ]; then
        package="${dir%/}"
        echo "Installing $package"
        stow "$package"
    fi
done

echo "Done! Dotfiles installed successfully."
