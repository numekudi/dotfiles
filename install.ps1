#Requires -Version 5.1
<#
.SYNOPSIS
    Dotfiles install script for native Windows (PowerShell).

.DESCRIPTION
    Windows counterpart of install.sh. GNU Stow is not used; instead each
    managed path is linked into place:

      - directories -> junction (works without admin / developer mode)
      - files       -> symbolic link, falling back to a plain copy when this
                       process may not create symlinks

    Packages with no native Windows equivalent (zsh, tmux) are skipped; use
    install.sh from WSL for those. Anything already present at a target path
    is backed up before it is replaced.

.PARAMETER Only
    Install just the named packages, e.g. -Only git,nvim

.PARAMETER Mode
    Auto (default) links when possible and copies otherwise.
    Link forces linking and reports a failure instead of copying.
    Copy always copies.

.PARAMETER Uninstall
    Remove links that point into this repository.

.PARAMETER DryRun
    Print what would happen without touching the filesystem.

.PARAMETER Force
    Delete existing targets instead of backing them up.

.EXAMPLE
    .\install.ps1
    .\install.ps1 -Only git,nvim -DryRun
    .\install.ps1 -Uninstall
#>
[CmdletBinding()]
param(
    [string[]]$Only,
    [ValidateSet('Auto', 'Link', 'Copy')]
    [string]$Mode = 'Auto',
    [switch]$Uninstall,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$DotfilesDir = $PSScriptRoot
$UserHome = $env:USERPROFILE
$Stamp = (Get-Date).ToString('yyyyMMdd-HHmmss')

# ---------------------------------------------------------------------------
# Package map
#
# Source paths are relative to this repository. Target paths are where the
# tool actually looks on native Windows, which is not always the POSIX path
# the stow packages are laid out for.
# ---------------------------------------------------------------------------
function New-Entry {
    param(
        [string]$Package,
        [string]$Source,
        [string]$Target,
        [ValidateSet('File', 'Dir')]
        [string]$Kind
    )
    [pscustomobject]@{
        Package = $Package
        Source  = Join-Path $DotfilesDir $Source
        Target  = $Target
        Kind    = $Kind
    }
}

$entries = @(
    New-Entry git      'git/.gitconfig'                 (Join-Path $UserHome '.gitconfig')            File
    New-Entry git      'git/.config/git/ignore'         (Join-Path $UserHome '.config\git\ignore')    File

    # Windows Neovim reads %LOCALAPPDATA%\nvim, not ~/.config/nvim.
    New-Entry nvim     'nvim/.config/nvim'              (Join-Path $env:LOCALAPPDATA 'nvim')          Dir

    # Vim on Windows prefers _vimrc; .vimrc is what Git Bash's vim picks up.
    New-Entry vim      'vim/.vimrc'                     (Join-Path $UserHome '_vimrc')                File
    New-Entry vim      'vim/.vimrc'                     (Join-Path $UserHome '.vimrc')                File

    New-Entry starship 'starship/.config/starship.toml' (Join-Path $UserHome '.config\starship.toml') File

    # ~/.claude and ~/.codex also hold local state, so only the managed files
    # are linked rather than the whole directory.
    New-Entry claude   'claude/.claude/CLAUDE.md'       (Join-Path $UserHome '.claude\CLAUDE.md')     File
    New-Entry codex    'codex/.codex/AGENTS.md'         (Join-Path $UserHome '.codex\AGENTS.md')      File
    New-Entry pi       'pi/.pi/agent/mcp.json'           (Join-Path $UserHome '.pi\agent\mcp.json')    File

    # Zed runs as a native Windows app and reads %APPDATA%\Zed.
    New-Entry zed      'zed/.config/zed/keymap.json'    (Join-Path $env:APPDATA 'Zed\keymap.json')    File

    # Sourced manually from Git Bash's .bashrc.
    New-Entry bash     'bash/.bash_custom.sh'           (Join-Path $UserHome '.bash_custom.sh')       File
)

# POSIX only; install these with install.sh from WSL.
$skippedPackages = 'zsh', 'tmux'

if ($Only) {
    $entries = @($entries | Where-Object { $Only -contains $_.Package })
    if ($entries.Count -eq 0) {
        throw "No packages matched -Only $($Only -join ',')"
    }
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Write-Step { param([string]$Message) Write-Host $Message }
function Write-Ok   { param([string]$Message) Write-Host "  $Message" -ForegroundColor Green }
function Write-Note { param([string]$Message) Write-Host "  $Message" -ForegroundColor DarkGray }
function Write-Warn { param([string]$Message) Write-Host "  $Message" -ForegroundColor Yellow }
function Write-Fail { param([string]$Message) Write-Host "  $Message" -ForegroundColor Red }

$script:SymlinkCapable = $null

function Test-SymlinkCapable {
    if ($null -ne $script:SymlinkCapable) { return $script:SymlinkCapable }

    $probeTarget = Join-Path $env:TEMP ("dotfiles-probe-target-{0}.txt" -f $PID)
    $probeLink = Join-Path $env:TEMP ("dotfiles-probe-link-{0}.txt" -f $PID)
    try {
        Set-Content -LiteralPath $probeTarget -Value 'probe' -Encoding ascii
        New-Item -ItemType SymbolicLink -Path $probeLink -Target $probeTarget -ErrorAction Stop | Out-Null
        $script:SymlinkCapable = $true
    } catch {
        $script:SymlinkCapable = $false
    } finally {
        Remove-Item -LiteralPath $probeLink -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $probeTarget -Force -ErrorAction SilentlyContinue
    }
    return $script:SymlinkCapable
}

function Get-ItemSafe {
    param([string]$Path)
    # Unlike Test-Path, this still returns a dangling link.
    return (Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue)
}

function Test-IsLink {
    param($Item)
    if ($null -eq $Item) { return $false }
    return [bool]($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
}

function Get-LinkTarget {
    param($Item)
    if ($null -eq $Item) { return $null }
    $linkTarget = $Item.Target
    if (($linkTarget -is [System.Collections.IEnumerable]) -and ($linkTarget -isnot [string])) {
        $linkTarget = @($linkTarget)[0]
    }
    if (-not $linkTarget) { return $null }
    return [string]$linkTarget
}

function Test-SamePath {
    param([string]$Left, [string]$Right)
    if (-not $Left -or -not $Right) { return $false }
    return ($Left.TrimEnd('\', '/') -ieq $Right.TrimEnd('\', '/'))
}

function Remove-LinkOrItem {
    param([string]$Path)
    $item = Get-ItemSafe $Path
    if ($null -eq $item) { return }

    if ((Test-IsLink $item) -and $item.PSIsContainer) {
        # Remove-Item -Recurse can follow a junction and delete the real
        # contents, so unlink the directory entry directly instead.
        [System.IO.Directory]::Delete($Path, $false)
    } elseif ($item.PSIsContainer) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    } else {
        Remove-Item -LiteralPath $Path -Force
    }
}

function Test-SameContent {
    param([string]$Left, [string]$Right)
    if (-not (Test-Path -LiteralPath $Left -PathType Leaf)) { return $false }
    if (-not (Test-Path -LiteralPath $Right -PathType Leaf)) { return $false }
    return ((Get-FileHash -LiteralPath $Left).Hash -eq (Get-FileHash -LiteralPath $Right).Hash)
}

function Clear-Target {
    param([string]$Path, [string]$Source)

    $item = Get-ItemSafe $Path
    if ($null -eq $item) { return }

    # An identical plain file is a copy this script made on an earlier run,
    # so replace it instead of piling up a backup every time.
    if (-not (Test-IsLink $item) -and (Test-SameContent $Path $Source)) {
        if ($DryRun) { Write-Note "would replace unchanged copy at $Path"; return }
        Remove-Item -LiteralPath $Path -Force
        return
    }

    if ((Test-IsLink $item) -or $Force) {
        if ($DryRun) { Write-Note "would remove existing $Path"; return }
        Remove-LinkOrItem $Path
        Write-Note "removed existing entry"
        return
    }

    $backup = "$Path.bak-$Stamp"
    if ($DryRun) { Write-Note "would back up $Path -> $backup"; return }
    Move-Item -LiteralPath $Path -Destination $backup -Force
    Write-Warn "backed up existing -> $(Split-Path -Leaf $backup)"
}

function New-ParentDir {
    param([string]$Path)
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        if ($DryRun) { Write-Note "would create $parent"; return }
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
}

# ---------------------------------------------------------------------------
# Install / uninstall
# ---------------------------------------------------------------------------
function Install-Entry {
    param($Entry)

    $source = $Entry.Source
    $target = $Entry.Target

    if (-not (Test-Path -LiteralPath $source)) {
        Write-Warn "source missing, skipped: $source"
        return 'skipped'
    }

    $existing = Get-ItemSafe $target
    if (Test-IsLink $existing) {
        if (Test-SamePath (Get-LinkTarget $existing) $source) {
            Write-Note "already linked: $target"
            return 'ok'
        }
    }

    # Decide how this entry gets placed.
    if ($Mode -eq 'Copy') {
        $useLink = $false
    } elseif ($Entry.Kind -eq 'Dir') {
        $useLink = $true   # junctions never need elevation
    } elseif ($Mode -eq 'Link') {
        $useLink = $true
    } else {
        $useLink = Test-SymlinkCapable
    }

    Clear-Target -Path $target -Source $source
    New-ParentDir -Path $target

    if ($DryRun) {
        if ($useLink) {
            if ($Entry.Kind -eq 'Dir') { $verb = 'junction' } else { $verb = 'symlink' }
        } else {
            $verb = 'copy'
        }
        Write-Note "would $verb $target -> $source"
        return 'ok'
    }

    if ($useLink) {
        if ($Entry.Kind -eq 'Dir') { $itemType = 'Junction' } else { $itemType = 'SymbolicLink' }
        try {
            New-Item -ItemType $itemType -Path $target -Target $source -ErrorAction Stop | Out-Null
            Write-Ok "$($itemType.ToLower()): $target"
            return 'ok'
        } catch {
            if ($Mode -eq 'Link') {
                Write-Fail "failed to link $target : $($_.Exception.Message)"
                return 'failed'
            }
            Write-Warn "link failed, copying instead: $($_.Exception.Message)"
        }
    }

    if ($Entry.Kind -eq 'Dir') {
        Copy-Item -LiteralPath $source -Destination $target -Recurse -Force
    } else {
        Copy-Item -LiteralPath $source -Destination $target -Force
    }
    Write-Ok "copied: $target"
    return 'copied'
}

function Uninstall-Entry {
    param($Entry)

    $item = Get-ItemSafe $Entry.Target
    if ($null -eq $item) {
        Write-Note "not present: $($Entry.Target)"
        return 'skipped'
    }

    if (-not (Test-IsLink $item)) {
        Write-Warn "not a link, left in place: $($Entry.Target)"
        return 'skipped'
    }

    $current = Get-LinkTarget $item
    if (-not (Test-SamePath $current $Entry.Source)) {
        Write-Warn "links elsewhere, left in place: $($Entry.Target) -> $current"
        return 'skipped'
    }

    if ($DryRun) { Write-Note "would unlink $($Entry.Target)"; return 'ok' }
    Remove-LinkOrItem $Entry.Target
    Write-Ok "unlinked: $($Entry.Target)"
    return 'ok'
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
if ($DryRun) { Write-Host "Dry run - nothing will be modified." -ForegroundColor Cyan }

if ($Uninstall) {
    Write-Step "Removing dotfiles links..."
    $results = @()
    foreach ($entry in $entries) {
        Write-Step $entry.Package
        $results += (Uninstall-Entry $entry)
    }
    $removed = @($results | Where-Object { $_ -eq 'ok' }).Count

    Write-Host ""
    Write-Host "Done. $removed link(s) removed." -ForegroundColor Green
    Write-Note "Backups created during install (*.bak-*) are left untouched."
    return
}

Write-Step "Installing dotfiles from $DotfilesDir"

if ($Mode -ne 'Copy' -and -not (Test-SymlinkCapable)) {
    Write-Host ""
    Write-Warn "This process may not create symbolic links."
    Write-Note "Directories still use junctions, but individual files are copied,"
    Write-Note "so re-run this script after pulling changes."
    Write-Note "To link files instead: enable Developer Mode (ms-settings:developers)"
    Write-Note "or run this script from an elevated PowerShell."
}

Write-Host ""
$results = @()
foreach ($entry in $entries) {
    Write-Step $entry.Package
    $results += (Install-Entry $entry)
}

$copied = @($results | Where-Object { $_ -eq 'copied' }).Count
$failed = @($results | Where-Object { $_ -eq 'failed' }).Count

Write-Host ""
Write-Host "Skipped packages (POSIX only, use install.sh from WSL): $($skippedPackages -join ', ')" -ForegroundColor DarkGray
if ($copied -gt 0) {
    Write-Warn "$copied file(s) were copied, not linked - re-run after updating the repo."
}
if ($failed -gt 0) {
    Write-Fail "$failed entry/entries failed."
    exit 1
}
Write-Host "Done! Dotfiles installed successfully." -ForegroundColor Green
