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

## CLI

Python製のツール群は `nskills` コマンドで使用できます。

```bash
uv run nskills --help
```

### image-generation

Gemini APIを使って画像を生成します。事前に Vertex AI の認証が必要です。

```bash
uv run nskills image-generation <prompt> <output_path> [options]
```

| オプション | デフォルト | 説明 |
|---|---|---|
| `--reference-image` | — | 参考画像のパス |
| `--model` | `gemini-3-pro-image-preview` | モデル名 |
| `--temperature` | `0.2` | 温度パラメータ |
| `--image-size` | `1K` | 画像サイズ |
| `--aspect-ratio` | `1:1` | アスペクト比 |

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
