# Dotfiles

Personal configuration files for development environment.

## Requirements

- [GNU Stow](https://www.gnu.org/software/stow/)

```bash
# macOS
brew install stow

# Linux
sudo apt install stow
```

## Installation

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles

# Symlink dotfiles
./install.sh

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
