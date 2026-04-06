<#
manage-repo.ps1

Helper script to run common repository operations from any current directory.

Usage examples:
  # Run default (reorganize + cleanup + commit)
  powershell -NoProfile -ExecutionPolicy Bypass -File "C:\path\to\repo\scripts\manage-repo.ps1" -Action all -RepoPath "C:\path\to\repo"

  # Run a specific action inside the repo you are currently in
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\manage-repo.ps1 -Action reorganize

Available Actions:
  all                    : cleanup assets, reorganize files, rename, commit and optionally build
  cleanup-assets         : remove src/assets/hero.png and src/assets/react.svg (if present)
  restore-helper-contract: try to restore `helper-contract` from previous commit if missing
  reorganize             : move frontend files to `frontend/` and contract files to `contracts/`
  rename-english         : rename Chinese folders `前端`/`合约` to `frontend`/`contracts` when present
  build-frontend         : run `pnpm --prefix frontend run build` (optionally install deps with -InstallDependencies)
  status                 : show repo status and locations

Notes:
  - If the working tree has uncommitted changes the script will abort unless -Force is supplied.
  - This script uses `git mv` where possible and falls back to copy/delete when necessary.
#>

[CmdletBinding()]
param(
    [ValidateSet('all','cleanup-assets','restore-helper-contract','reorganize','rename-english','build-frontend','status')]
    [string]$Action = 'all',

    [string]$RepoPath = '',

    [switch]$Force,

    [switch]$InstallDependencies
)

$ErrorActionPreference = 'Stop'

function Get-RepoRoot([string]$path) {
    if ($path) {
        try {
            $top = git -C $path rev-parse --show-toplevel 2>$null
            if ($LASTEXITCODE -eq 0) { return $top.Trim() }
        } catch { }
        if (Test-Path $path) { return (Get-Item -LiteralPath $path).FullName }
    }

    try {
        $top = git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0) { return $top.Trim() }
    } catch { }

    $p = Get-Location
    while ($p -ne $null) {
        if (Test-Path (Join-Path $p.FullName '.git')) { return $p.FullName }
        $p = $p.Parent
    }

    throw "Repository root not found. Run inside a git repo or provide -RepoPath."
}

function Ensure-CleanWorkingTree($repoRoot) {
    Push-Location $repoRoot
    try {
        $status = git status --porcelain
        if ($status -and (-not $Force)) {
            throw "Working tree has uncommitted changes. Re-run with -Force to override.\n$status"
        }
    } finally { Pop-Location }
}

function Move-WithGitFallback($srcRel, $dstRel) {
    $src = Join-Path $repoRoot $srcRel
    $dst = Join-Path $repoRoot $dstRel
    if (-not (Test-Path $src)) { Write-Output "Source not found: $srcRel"; return $false }

    $dstDir = Split-Path -Parent $dst
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }

    Push-Location $repoRoot
    try {
        git mv -f -- $srcRel $dstRel 2>$null
        if ($LASTEXITCODE -eq 0) { Write-Output "git mv $srcRel -> $dstRel"; return $true }

        Write-Output "git mv failed, falling back to copy for $srcRel -> $dstRel"
        if (Test-Path $src -PathType Container) {
            robocopy $src $dst /E /COPYALL /R:0 /W:0 | Out-Null
            Remove-Item -Recurse -Force $src
            git add -A $dstRel 2>$null
        } else {
            Copy-Item -Path $src -Destination $dst -Force
            git add $dstRel 2>$null
            Remove-Item -Force $src
        }
        Write-Output "copied $srcRel -> $dstRel"
        return $true
    } finally { Pop-Location }
}

function Commit-And-Push($message) {
    Push-Location $repoRoot
    try {
        git add -A
        $st = git status --porcelain
        if ($st) {
            git commit -m $message
            git push
            Write-Output "Committed and pushed: $message"
        } else {
            Write-Output "No changes to commit."
        }
    } finally { Pop-Location }
}

try {
    $repoRoot = Get-RepoRoot $RepoPath
    Write-Output "Repository root: $repoRoot"

    if ($Action -ne 'status') { Ensure-CleanWorkingTree $repoRoot }

    switch ($Action) {
        'status' {
            Write-Output "--- status ---"
            Push-Location $repoRoot
            try { git status --short; Write-Output ''; Get-ChildItem -Name } finally { Pop-Location }
            break
        }

        'cleanup-assets' {
            Push-Location $repoRoot
            try {
                $removed = $false
                $assets = @('src/assets/hero.png','src/assets/react.svg')
                foreach ($a in $assets) {
                    if (Test-Path $a) {
                        git rm -f -- $a 2>$null
                        if ($LASTEXITCODE -ne 0) { Remove-Item -Force $a -ErrorAction SilentlyContinue }
                        Write-Output "Removed $a"
                        $removed = $true
                    } else { Write-Output "Not found: $a" }
                }
                if ($removed) { Commit-And-Push 'chore: remove unused assets (hero.png, react.svg)' }
            } finally { Pop-Location }
            break
        }

        'restore-helper-contract' {
            Push-Location $repoRoot
            try {
                if (Test-Path 'helper-contract' -or Test-Path 'contracts/helper-contract') { Write-Output 'helper-contract already exists; nothing to restore.'; break }
                Write-Output 'Attempting to restore helper-contract from previous commit (HEAD^ or origin/main).'
                git checkout HEAD^ -- helper-contract 2>$null
                if ($LASTEXITCODE -ne 0) { git checkout origin/main -- helper-contract 2>$null }
                if (Test-Path 'helper-contract') { Commit-And-Push 'chore: restore helper-contract files accidentally deleted' } else { Write-Output 'Could not restore helper-contract automatically.' }
            } finally { Pop-Location }
            break
        }

        'reorganize' {
            Push-Location $repoRoot
            try {
                if (-not (Test-Path 'frontend')) { New-Item -ItemType Directory -Path frontend | Out-Null }
                if (-not (Test-Path 'contracts')) { New-Item -ItemType Directory -Path contracts | Out-Null }

                $frontendItems = @('index.html','package.json','pnpm-lock.yaml','public','tsconfig.app.json','tsconfig.json','tsconfig.node.json','vite.config.ts','eslint.config.js')
                foreach ($it in $frontendItems) {
                    if (Test-Path $it) {
                        Move-WithGitFallback $it "frontend/$it" | Out-Null
                    }
                }

                if (Test-Path 'helper-contract') { Move-WithGitFallback 'helper-contract' 'contracts/helper-contract' | Out-Null }

                # If any changes were made commit them
                $st = git status --porcelain
                if ($st) { Commit-And-Push 'chore: reorganize repository layout: frontend/ and contracts/' }
            } finally { Pop-Location }
            break
        }

        'rename-english' {
            Push-Location $repoRoot
            try {
                if (Test-Path '前端') { Move-WithGitFallback '前端' 'frontend' | Out-Null }
                if (Test-Path '合约') { Move-WithGitFallback '合约' 'contracts' | Out-Null }
                $st = git status --porcelain
                if ($st) { Commit-And-Push 'chore: rename directories to English (frontend, contracts)' }
            } finally { Pop-Location }
            break
        }

        'build-frontend' {
            $frontendPath = Join-Path $repoRoot 'frontend'
            if (-not (Test-Path $frontendPath)) { throw "frontend directory not found at $frontendPath" }
            if ($InstallDependencies) {
                Write-Output 'Installing frontend dependencies (pnpm install)...'
                pnpm --prefix $frontendPath install
            }
            Write-Output 'Running frontend build...'
            pnpm --prefix $frontendPath run build
            break
        }

        'all' {
            # do cleanup, reorganize, rename english. Do NOT auto-rewrite history.
            Push-Location $repoRoot
            try {
                & $MyInvocation.MyCommand.Definition -Action cleanup-assets -RepoPath $repoRoot -Force:$Force | Out-Null
                & $MyInvocation.MyCommand.Definition -Action reorganize -RepoPath $repoRoot -Force:$Force | Out-Null
                & $MyInvocation.MyCommand.Definition -Action rename-english -RepoPath $repoRoot -Force:$Force | Out-Null
                if ($InstallDependencies) { & $MyInvocation.MyCommand.Definition -Action build-frontend -RepoPath $repoRoot -InstallDependencies }
            } finally { Pop-Location }
            break
        }

        default { throw "Unknown action: $Action" }
    }

    Write-Output "Done."
} catch {
    Write-Error "Error: $_"
    exit 1
}
