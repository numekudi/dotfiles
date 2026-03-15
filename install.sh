#!/bin/bash

# Simple dotfiles install script

set -e

# Check if stow is installed
if ! command -v stow >/dev/null 2>&1; then
    echo "Error: stow is required but not installed."
    echo "Install it with: brew install stow (macOS) or sudo apt install stow (Linux)"
    exit 1
fi

# Install all dotfiles
echo "Installing dotfiles..."

packages=("git" "zsh" "nvim" "bash" "agents" "copilot" "gemini" "starship" "zed")

for package in "${packages[@]}"; do
    echo "Installing $package"
    stow "$package"
done

uv tool install nskills

echo "Done! Dotfiles installed successfully."
