# Dotfiles

Personal configuration files for development environment.

## Requirements

- [GNU Stow](https://www.gnu.org/software/stow/)
- [uv](https://docs.astral.sh/uv/) (Python 3.13)

```bash
# macOS
brew install stow
brew install uv

# Linux
sudo apt install stow
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## Installation

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles

# Symlink dotfiles
./install.sh

# Install Python dependencies (for CLI tools)
uv sync
```

## Manual Stow

特定のパッケージだけ適用する場合:

```bash
stow git
stow zsh
stow nvim
```

## Uninstalling

```bash
stow -D <package>
```
