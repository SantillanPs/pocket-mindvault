# MindVault operational healthcheck.
# Checks whether the AI environment can operate; it does NOT require activity
# heartbeats, daily notes, transcripts, or a recent commit.
# Usage: powershell -ExecutionPolicy Bypass -File scripts/healthcheck.ps1

param()
$ErrorActionPreference = 'Stop'
$vault = Split-Path -Parent $PSScriptRoot
Set-Location $vault
$problems = @()

function Problem([string]$Message) { $script:problems += $Message; Write-Host "  - $Message" -ForegroundColor Yellow }
function Check-File([string]$Path) { if (Test-Path $Path -PathType Leaf) { Write-Host "✓ $Path" } else { Problem "missing required file: $Path" } }
function Check-Dir([string]$Path) { if (Test-Path $Path -PathType Container) { Write-Host "✓ $Path/" } else { Problem "missing required directory: $Path/" } }

Write-Host "=== MindVault operational healthcheck ($(Get-Date -Format 'yyyy-MM-dd HH:mm')) ==="

Write-Host ""
Write-Host "Core state"
Check-File 'AGENTS.md'
Check-File 'HANDOFF.md'
Check-File 'index.md'
Check-Dir 'wiki'
Check-Dir 'scripts'

Write-Host ""
Write-Host "Git"
try {
    $inside = git rev-parse --is-inside-work-tree 2>$null
    if ($inside -eq 'true') {
        Write-Host "✓ repository"
        Write-Host "  branch: $(git branch --show-current 2>$null)"
        Write-Host "  commits: $(git rev-list --count HEAD 2>$null)"
    } else { Problem 'not a Git repository' }
} catch { Problem 'Git is unavailable' }

Write-Host ""
Write-Host "Durable knowledge"
foreach ($d in @('wiki/solutions','wiki/skills','wiki/navigate/maps','wiki/dormant','wiki/archive')) {
    if (Test-Path $d -PathType Container) {
        $count = @(Get-ChildItem $d -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne '.gitkeep' }).Count
        Write-Host "✓ $d/ ($count files)"
    }
}

Write-Host ""
Write-Host "Current state"
if (Test-Path 'HANDOFF.md') {
    $handoff = Get-Content 'HANDOFF.md' -Raw
    if ($handoff -match '(?m)^status:\s*active|(?m)^##\s+(Active|Current|Next)') {
        Write-Host '✓ HANDOFF.md contains current-state markers'
    } else {
        Write-Host '✓ HANDOFF.md exists; no active work is currently required'
    }
}

Write-Host ""
Write-Host "Links"
$broken = @()
$activeFiles = @('AGENTS.md','HANDOFF.md','index.md')
$activeFiles += @(Get-ChildItem 'wiki/solutions/*.md' -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
$activeFiles += @(Get-ChildItem 'wiki/skills/*.md' -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
$activeFiles += @(Get-ChildItem 'wiki/dormant/*.md' -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
foreach ($f in $activeFiles) {
    if (-not (Test-Path $f)) { continue }
    $content = Get-Content $f -Raw
    foreach ($m in [regex]::Matches($content, '\[\[([^\|\]]+)(?:\|[^\]]*)?\]\]')) {
        $link = $m.Groups[1].Value.Trim()
        if ($link -match '^(https?:|ftp:|www\.)') { continue }
        $cand = $link
        if (-not $cand.EndsWith('.md')) { $cand += '.md' }
        if (-not (Test-Path (Join-Path $vault $cand))) { $broken += "$f -> [[$link]]" }
    }
}
if ($broken.Count -eq 0) { Write-Host '✓ no broken operational links' } else { $broken | ForEach-Object { Write-Host "  broken: $_" }; Problem "$($broken.Count) broken operational links" }

$solutionFiles = @(Get-ChildItem 'wiki/solutions/*.md' -File -ErrorAction SilentlyContinue)
$malformed = @()
foreach ($f in $solutionFiles) {
    $c = Get-Content $f.FullName -Raw
    if ($c -notmatch '(?m)^recheck:' -and $c -notmatch '(?m)^status:') { $malformed += $f.Name }
}
Write-Host "✓ solutions: $($solutionFiles.Count)"
if ($malformed.Count -gt 0) { $malformed | ForEach-Object { Write-Host "  malformed solution metadata: $_" }; Problem "$($malformed.Count) solution files have no recognizable metadata" }

Write-Host ""
if ($problems.Count -eq 0) {
    Write-Host 'HEALTHCHECK OK - MindVault is operational.' -ForegroundColor Green
    exit 0
} else {
    Write-Host "HEALTHCHECK FAILED - operational problems found: $($problems.Count)" -ForegroundColor Red
    exit 1
}
