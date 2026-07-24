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

packages=("git" "zsh" "nvim" "bash" "tmux" "copilot" "gemini" "starship" "zed" "claude" "codex")

for package in "${packages[@]}"; do
    echo "Installing $package"
    stow "$package"
done


DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create skills symlinks
echo "Creating skills symlinks..."
for tool in claude copilot gemini; do
    hidden_dir="$DOTFILES_DIR/$tool/.$tool"
    if [ -d "$hidden_dir" ]; then
        ln -sfn "../../agents/.agents/skills" "$hidden_dir/skills"
        echo "  $tool/.${tool}/skills -> agents/.agents/skills"
    fi
done

# Sync Zed config to Windows (WSL only)
# On WSL, Zed runs as a native Windows app and reads its config from the Windows
# AppData dir, which stow cannot symlink into. So we copy the files explicitly.
if command -v cmd.exe >/dev/null 2>&1; then
    echo "Syncing Zed config to Windows..."
    zed_src="$DOTFILES_DIR/zed/.config/zed"
    zed_files=(settings.json keymap.json)
    win_user=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    win_dst="/mnt/c/Users/$win_user/AppData/Roaming/Zed"
    if [ -d "$win_dst" ]; then
        for f in "${zed_files[@]}"; do
            cp "$zed_src/$f" "$win_dst/$f"
        done
        echo "  Synced to $win_dst"
    else
        echo "  Windows Zed config dir not found: $win_dst (skipped)"
    fi
fi

echo "Done! Dotfiles installed successfully."
