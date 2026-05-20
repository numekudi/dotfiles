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

packages=("git" "zsh" "nvim" "bash" "agents" "copilot" "gemini" "starship" "zed" "claude")

for package in "${packages[@]}"; do
    echo "Installing $package"
    stow "$package"
done

uv tool install nskills

# Create skills symlinks
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Creating skills symlinks..."
for tool in claude copilot gemini; do
    hidden_dir="$DOTFILES_DIR/$tool/.$tool"
    if [ -d "$hidden_dir" ]; then
        ln -sfn "../../agents/.agents/skills" "$hidden_dir/skills"
        echo "  $tool/.${tool}/skills -> agents/.agents/skills"
    fi
done

echo "Done! Dotfiles installed successfully."
