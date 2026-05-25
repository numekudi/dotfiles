#!/bin/bash
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.config/zed" && pwd)"
FILES=(settings.json keymap.json)

if command -v cmd.exe &>/dev/null; then
  WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
  win_dst="/mnt/c/Users/$WIN_USER/AppData/Roaming/Zed"
  if [[ -d "$win_dst" ]]; then
    for f in "${FILES[@]}"; do
      cp "$SRC/$f" "$win_dst/$f"
    done
    echo "Synced to $win_dst"
  else
    echo "Windows Zed config dir not found: $win_dst"
  fi
fi
