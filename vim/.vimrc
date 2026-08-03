" nvim が使えない環境 (リモートサーバー / コンテナ / sudo -e など) 用の設定。
" プラグインには依存せず素の vim だけで完結させる。
" キーマップと主要オプションは nvim/.config/nvim/init.lua と揃えてあるので、
" どちらを起動しても指の動きは変わらない。

" vi 互換を切る。他の全ての設定より先に置く必要がある (副作用で値がリセットされるため)
set nocompatible

syntax enable
filetype plugin indent on

" ---------------------------------------------------------------------------
" 表示
" ---------------------------------------------------------------------------
set number
set relativenumber
set signcolumn=yes
set laststatus=2          " ステータスラインを常に表示 (nvim の既定値に合わせる)
set ruler
set showcmd
set scrolloff=5
set nowrap

" 24bit カラーは対応端末でのみ有効化する。非対応端末で設定すると色が壊れるため
if has('termguicolors') && ($COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit')
  set termguicolors
endif

" ---------------------------------------------------------------------------
" インデント
" ---------------------------------------------------------------------------
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smartindent
set autoindent

" ---------------------------------------------------------------------------
" 検索
" ---------------------------------------------------------------------------
" 既定では大文字小文字を無視し、検索語に大文字が含まれる場合のみ区別する
set ignorecase
set smartcase
set incsearch
set hlsearch

" ---------------------------------------------------------------------------
" 編集まわり
" ---------------------------------------------------------------------------
set backspace=indent,eol,start  " 挿入モードで既存文字も消せるようにする
set hidden                      " 未保存バッファを隠せるようにする
set splitright
set splitbelow
set updatetime=250
set ttimeoutlen=10              " <Esc> 後のキーコード待ちを詰めてモード切替を速くする
set mouse=a
set wildmenu
set wildmode=longest:full,full
set encoding=utf-8
set fileencodings=utf-8,cp932,euc-jp,latin1
set fileformats=unix,dos,mac

" システムクリップボード。
" 非対応ビルドで unnamedplus を指定すると起動時にエラーになるので、必ず機能検出してから設定する。
" +clipboard が無いビルド (WSL の Ubuntu 版 vim など) でも、vim 9.1 の
" clipboard_provider があれば外部コマンド経由で nvim と同じ挙動にできる。
if !has('clipboard') && has('clipboard_provider')
  " コピーは tmux と同じ ~/.local/bin/tmux-copy に委譲し、判定ロジックを一箇所に保つ
  let s:copy_cmd = executable(expand('~/.local/bin/tmux-copy')) ? [expand('~/.local/bin/tmux-copy')] : []
  " ペースト側も tmux-copy と同じ優先順位・同じ前提条件 (X11/Wayland は
  " ディスプレイが繋がっている時だけ) で選ぶ
  let s:paste_cmd =
        \ (!empty($WAYLAND_DISPLAY) && executable('wl-paste')) ? ['wl-paste', '--no-newline'] :
        \ executable('pbpaste')                                ? ['pbpaste'] :
        \ (!empty($DISPLAY) && executable('xclip'))            ? ['xclip', '-selection', 'clipboard', '-out'] :
        \ (!empty($DISPLAY) && executable('xsel'))             ? ['xsel', '--clipboard', '--output'] :
        \ executable('powershell.exe')                         ? ['powershell.exe', '-NoProfile', '-Command', '[Console]::Out.Write((Get-Clipboard -Raw))'] : []
  if !empty(s:copy_cmd) && !empty(s:paste_cmd)
    let g:clipboard = {
          \ 'name': 'dotfiles',
          \ 'copy':  { '+': s:copy_cmd,  '*': s:copy_cmd },
          \ 'paste': { '+': s:paste_cmd, '*': s:paste_cmd },
          \ }
  endif
endif

if has('clipboard') || exists('g:clipboard')
  set clipboard=unnamedplus
endif

" ---------------------------------------------------------------------------
" 履歴ファイル
" ---------------------------------------------------------------------------
" swap / backup / undo を作業ディレクトリに散らかさず一箇所へ集約する
let s:vimdir = expand('~/.vim')
for s:dir in ['swap', 'undo']
  if !isdirectory(s:vimdir . '/' . s:dir)
    call mkdir(s:vimdir . '/' . s:dir, 'p', 0700)
  endif
endfor
let &directory = s:vimdir . '/swap//'
set nobackup
set nowritebackup
if has('persistent_undo')
  let &undodir = s:vimdir . '/undo//'
  set undofile
endif

" ---------------------------------------------------------------------------
" キーマップ (init.lua と同一)
" ---------------------------------------------------------------------------
let mapleader = ' '
let maplocalleader = '\'
nnoremap <Space> <Nop>
vnoremap <Space> <Nop>

" <C-s> で保存。端末のフロー制御 (XOFF) を無効化しないと <C-s> が届かない
if !has('gui_running')
  silent! !stty -ixon 2>/dev/null
endif
" <Cmd> は vim 8.2.1978 以降でしか使えないので、古い環境でも動く古典的な形にする
nnoremap <C-s> :<C-u>w<CR>
vnoremap <C-s> <Esc>:<C-u>w<CR>
inoremap <C-s> <Esc>:<C-u>w<CR>

nnoremap H ^
vnoremap H ^
nnoremap L $
vnoremap L $

nnoremap <C-a> ggVG
vnoremap <C-a> ggVG
nnoremap <C-c> yy

nnoremap <Esc><Esc> :<C-u>set nohlsearch<CR>

" ---------------------------------------------------------------------------
" その他
" ---------------------------------------------------------------------------
augroup vimrc_restore_cursor
  autocmd!
  " 前回終了時のカーソル位置を復元する
  autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line('$') | execute "normal! g`\"" | endif
augroup END
