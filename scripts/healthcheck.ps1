# MindVault healthcheck - run at every session open, before any problem work.
# Compares the three heartbeats (log.md, newest transcript, last git commit)
# plus working-tree cleanliness against now, then content checks (records vs
# reality) and engine checks (clock, stakes, independence, decay).
#
# Usage:  powershell -ExecutionPolicy Bypass -File scripts/healthcheck.ps1
#         (optionally: -ThresholdHours 72)
#
# Exit codes:
#   0 = healthy - all heartbeats within threshold, tree clean, no flags
#   1 = REPAIR MODE - a gap exists; fix it before proposing anything new
#
# NOTE: this file must stay pure ASCII. Windows PowerShell 5.1 reads .ps1
# files as ANSI; UTF-8 characters become mojibake and break parsing.

param([int]$ThresholdHours = 48)

$ErrorActionPreference = 'Stop'
$vault = Split-Path -Parent $PSScriptRoot
Set-Location $vault
$now = Get-Date
$problems = @()

Write-Host "=== MindVault healthcheck ($(Get-Date -Format 'yyyy-MM-dd HH:mm')) ==="

# 1. Newest dated entry in log.md
$log = Get-Content "$vault\log.md" -Raw
$m = [regex]::Match($log, '\[(\d{4}-\d{2}-\d{2})(?: (\d{2}:\d{2}))?\]')
if ($m.Success) {
    $dateStr = $m.Groups[1].Value
    $timeStr = if ($m.Groups[2].Success) { $m.Groups[2].Value } else { '00:00' }
    $logDate = [datetime]::ParseExact("$dateStr $timeStr", 'yyyy-MM-dd HH:mm', [System.Globalization.CultureInfo]::InvariantCulture)
    $h = ($now - $logDate).TotalHours
    Write-Host ("log entry    : {0} ({1:N0}h ago)" -f $dateStr, $h)
    if ($h -gt $ThresholdHours) { $problems += "log.md has no entry in $ThresholdHours hours (newest: $dateStr)" }
} else {
    Write-Host "log entry    : NONE FOUND"
    $problems += "log.md contains no dated entries"
}

# 2. Newest transcript file
$transcripts = Join-Path $vault 'wiki/archive/raw/transcripts'
if (Test-Path $transcripts) {
    $newest = Get-ChildItem $transcripts -Filter *.md | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($newest) {
        $h = ($now - $newest.LastWriteTime).TotalHours
        Write-Host ("transcript   : {0} ({1:N0}h ago)" -f $newest.Name, $h)
        if ($h -gt $ThresholdHours) { $problems += "no transcript written in $ThresholdHours hours (newest: $($newest.Name))" }
    } else {
        Write-Host "transcript   : NONE"
        $problems += "no transcript files exist"
    }
} else {
    Write-Host "transcript   : DIRECTORY MISSING"
    $problems += "transcript directory missing"
}

# 3. Last git commit
$lastCommit = git log -1 --format='%cI' 2>$null
if ($LASTEXITCODE -eq 0 -and $lastCommit) {
    $cDate = [datetime]::Parse($lastCommit)
    $h = ($now - $cDate).TotalHours
    Write-Host ("last commit  : {0} ({1:N0}h ago)" -f $cDate.ToString('yyyy-MM-dd HH:mm'), $h)
    if ($h -gt $ThresholdHours) { $problems += "no commit in $ThresholdHours hours (last: $($cDate.ToString('yyyy-MM-dd HH:mm')))" }
} else {
    Write-Host "last commit  : NONE"
    $problems += "no commits found"
}

# 4. Working tree cleanliness (dirty at session open = last session never committed)
$dirty = git status --porcelain 2>$null
if ($dirty) {
    $count = ($dirty | Measure-Object -Line).Lines
    Write-Host ("working tree : DIRTY ($count files)")
    $problems += "working tree is dirty at session open - last session did not commit ($count files)"
} else {
    Write-Host "working tree : clean"
}

# 5. Content checks - records vs reality
# 5a. index.md must match the solution files
$solCount = (Get-ChildItem "$vault\wiki\solutions\*.md").Count
$indexLinks = (Select-String -Path "$vault\index.md" -Pattern 'wiki/solutions/' -AllMatches).Matches.Count
Write-Host ("solutions     : {0} files, index lists {1}" -f $solCount, $indexLinks)
if ($solCount -ne $indexLinks) { $problems += "index lists $indexLinks solutions but $solCount files exist - regenerate index.md" }

# 5b. every solution carries a recheck date
foreach ($f in Get-ChildItem "$vault\wiki\solutions\*.md") {
    if (-not (Select-String -Path $f.FullName -Pattern '^recheck:' -Quiet)) { $problems += "solution missing recheck date: $($f.Name)" }
}

# 5c. every dormant file is marked dormant
foreach ($f in Get-ChildItem "$vault\wiki\dormant\*.md") {
    if (-not (Select-String -Path $f.FullName -Pattern '^status: dormant' -Quiet)) { $problems += "dormant file not marked dormant: $($f.Name)" }
}

# 5d. HANDOFF.md exists
if (-not (Test-Path "$vault\HANDOFF.md")) { $problems += "HANDOFF.md is missing" }

# 5e. broken internal links in active files
$activeFiles = @("$vault\AGENTS.md", "$vault\HANDOFF.md", "$vault\index.md", "$vault\wiki\predictions.md")
$activeFiles += (Get-ChildItem "$vault\wiki\solutions\*.md").FullName
$activeFiles += (Get-ChildItem "$vault\wiki\dormant\*.md").FullName
$activeFiles += (Get-ChildItem "$vault\wiki\skills\*.md").FullName
$broken = @()
foreach ($f in ($activeFiles | Where-Object { $_ -and (Test-Path $_) })) {
    $content = Get-Content $f -Raw
    $matches = [regex]::Matches($content, '\[\[([^\|\]]+)(?:\|[^\]]*)?\]\]')
    foreach ($mm in $matches) {
        $link = $mm.Groups[1].Value.Trim()
        if ($link -match '^(https?:|ftp:|www\.)') { continue }
        $cand = $link
        if (-not $cand.EndsWith('.md')) { $cand += '.md' }
        if (-not (Test-Path (Join-Path $vault $cand))) { $broken += "$($f.Split('\')[-1]): [[$link]]" }
    }
}
if ($broken.Count -gt 0) { $problems += "broken links ($($broken.Count)): $($broken -join ' | ')" }

# 6. Engine checks - clock, stakes, independence, decay
# 6a. prediction ledger: open bets, overdue, stalled (watchdog)
$predFile = "$vault\wiki\predictions.md"
if (Test-Path $predFile) {
    $openBets = 0; $overdueBets = 0; $stalledBets = 0; $stalledList = @()
    foreach ($line in (Get-Content $predFile)) {
        if ($line -match '^\|') {
            $cells = $line.Split('|') | ForEach-Object { $_.Trim() }
            # row shape: | ID | Date | Prediction | Due | Stake | Outcome | Verdict |
            if ($cells.Count -ge 8 -and $cells[1] -match '^P\d') {
                if ([string]::IsNullOrWhiteSpace($cells[7])) {
                    $openBets++
                    $dueDate = $null
                    try { $dueDate = [datetime]::ParseExact($cells[4], 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture) } catch { $dueDate = $null }
                    if ($dueDate) {
                        if ($dueDate -lt $now) { $overdueBets++ }
                        if (($now - $dueDate).TotalDays -gt 21) { $stalledBets++; $stalledList += $cells[1] }
                    }
                }
            }
        }
    }
    Write-Host ("predictions   : {0} open, {1} overdue, {2} stalled" -f $openBets, $overdueBets, $stalledBets)
    if ($overdueBets -gt 0) { $problems += "$overdueBets predictions overdue - resolve or mark as misses at session open" }
    if ($stalledBets -gt 0) { $problems += "STALLED predictions ($($stalledList -join ', ')) older than 21 days - flush to dormant and reset" }
} else {
    Write-Host "predictions   : LEDGER MISSING"
    $problems += "wiki/predictions.md is missing"
}

# 6b. independence score: solutions that carry themselves (ai-absent)
$sols = Get-ChildItem "$vault\wiki\solutions\*.md"
$aiAbsent = 0; $aiPresent = @()
foreach ($f in $sols) {
    $c = Get-Content $f.FullName -Raw
    if ($c -match 'mechanism:\s*ai-absent') { $aiAbsent++ }
    elseif ($c -match 'mechanism:\s*ai-present') { $aiPresent += $f.Name }
}
Write-Host ("independence  : {0}/{1} solutions carry themselves (ai-absent)" -f $aiAbsent, $sols.Count)
if ($aiPresent.Count -gt 0) { $problems += "AI-dependent solutions - encode into the environment: $($aiPresent -join ', ')" }

# 6c. dormant decay: past-due dormant files compress to one line and archive
foreach ($f in (Get-ChildItem "$vault\wiki\dormant\*.md")) {
    $c = Get-Content $f.FullName -Raw
    if ($c -match 'decay:\s*(\d{4}-\d{2}-\d{2})') {
        $decayDate = $null
        try { $decayDate = [datetime]::ParseExact($Matches[1], 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture) } catch { $decayDate = $null }
        if ($decayDate -and $decayDate -lt $now) { $problems += "dormant past decay - compress and archive: $($f.Name)" }
    }
}

# 6d. recheck overdue: solutions past their recheck date surface in the recap
foreach ($f in $sols) {
    $c = Get-Content $f.FullName -Raw
    if ($c -match 'recheck:\s*(\d{4}-\d{2}-\d{2})') {
        $recheckDate = $null
        try { $recheckDate = [datetime]::ParseExact($Matches[1], 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture) } catch { $recheckDate = $null }
        if ($recheckDate -and $recheckDate -lt $now) { $problems += "recheck overdue - surface in recap: $($f.Name)" }
    }
}

Write-Host ""
if ($problems.Count -eq 0) {
    Write-Host "HEALTHCHECK OK - all heartbeats within $ThresholdHours hours." -ForegroundColor Green
    exit 0
} else {
    Write-Host "HEALTHCHECK FAILED - REPAIR MODE:" -ForegroundColor Red
    foreach ($p in $problems) { Write-Host ("  - " + $p) -ForegroundColor Yellow }
    exit 1
}
