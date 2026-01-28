# Dotfiles

Personal configuration files for development environment.

## Installation

Install all dotfiles:

```bash
./install.sh
```

## Requirements

- [GNU Stow](https://www.gnu.org/software/stow/)

Install stow:
```bash
# macOS
brew install stow

# Linux
sudo apt install stow
```

## Manual Installation

To install specific packages:

```bash
stow git
stow zsh
stow starship
```

## Uninstalling

```bash
stow -D <package>
```
