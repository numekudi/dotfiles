# Dotfiles

Personal configuration files for development environment.

## Requirements

- [GNU Stow](https://www.gnu.org/software/stow/)
- tmux
- Clipboard provider for tmux copy integration:
  - Linux X11: `xclip` or `xsel`
  - Linux Wayland: `wl-copy`
  - macOS: `pbcopy`
  - WSL: `clip.exe`

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

## Windows (ネイティブ環境)

WSL ではなく Windows 側で使う場合は `install.ps1` を使う。stow は使わず、
ディレクトリはジャンクション、ファイルはシンボリックリンク (作成できない場合はコピー)
で配置する。

```powershell
git clone <this-repo> $env:USERPROFILE\dotfiles
cd $env:USERPROFILE\dotfiles

.\install.ps1 -DryRun   # 何が起きるか確認
.\install.ps1
```

| オプション | 内容 |
| --- | --- |
| `-Only git,nvim` | 指定パッケージだけ適用 |
| `-Mode Link\|Copy` | リンク固定 / コピー固定 (既定は Auto) |
| `-DryRun` | 変更せず表示のみ |
| `-Force` | 既存ファイルをバックアップせず削除 |
| `-Uninstall` | このリポジトリを指すリンクを解除 |

配置先は POSIX とは異なり、Windows 側の実際の参照先に合わせている:

| パッケージ | 配置先 |
| --- | --- |
| git | `~\.gitconfig`, `~\.config\git\ignore` |
| nvim | `%LOCALAPPDATA%\nvim` |
| vim | `~\_vimrc`, `~\.vimrc` |
| starship | `~\.config\starship.toml` |
| claude / codex | `~\.claude\CLAUDE.md`, `~\.codex\AGENTS.md` |
| zed | `%APPDATA%\Zed\keymap.json` |
| bash | `~\.bash_custom.sh` (Git Bash 用) |

`zsh` と `tmux` はネイティブ Windows では対象外なので、WSL から `install.sh` を使う。

既存のファイルは `<name>.bak-<timestamp>` に退避してから置き換える。

### シンボリックリンクについて

Windows ではファイルのシンボリックリンク作成に権限が要る。開発者モードが OFF かつ
非管理者で実行した場合、ディレクトリはジャンクション (権限不要) のままだが、
**ファイルはコピーになる** ので、リポジトリを更新したら `install.ps1` を再実行する。

リンクにしたい場合は次のどちらか:

- 設定 → 開発者向け (`ms-settings:developers`) で開発者モードを ON
- 管理者権限の PowerShell から実行

## Manual Stow

特定のパッケージだけ適用する場合:

```bash
stow git
stow zsh
stow nvim
stow vim
stow tmux
```

## vim について

`vim` パッケージは nvim が使えない環境 (リモートサーバー、コンテナ、`sudo -e` など) 用。
プラグインには依存せず、キーマップと主要オプションだけを `nvim` 側と揃えている。

## Uninstalling

```bash
stow -D <package>
```
