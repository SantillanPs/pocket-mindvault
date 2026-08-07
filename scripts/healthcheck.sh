#!/usr/bin/env bash
# MindVault healthcheck - bash port of scripts/healthcheck.ps1
# Run at every session open, before any problem work. Compares the three
# heartbeats (log.md, newest transcript, last git commit) plus working-tree
# cleanliness against now, then content checks (records vs reality) and
# engine checks (clock, stakes, independence, decay).
#
# Usage:  bash scripts/healthcheck.sh              (default threshold 48h)
#         bash scripts/healthcheck.sh -t 72
#
# Exit codes:
#   0 = healthy - all heartbeats within threshold, tree clean, no flags
#   1 = REPAIR MODE - a gap exists; fix it before proposing anything new
#
# NOTE: keep this file pure ASCII. Requires bash, coreutils (date, grep,
# find), and git.

set -u

THRESHOLD_HOURS=48
while getopts "t:h" opt; do
  case "$opt" in
    t) THRESHOLD_HOURS="$OPTARG" ;;
    h) grep '^#' "$0" | sed 's/^# //' | head -12; exit 0 ;;
  esac
done

VAULT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$VAULT" || { echo "cannot enter vault: $VAULT"; exit 1; }
NOW="$(date +%s)"
PROBLEMS=0
PROBLEM_LIST=""
add_problem() {
  PROBLEMS=$((PROBLEMS + 1))
  PROBLEM_LIST="$PROBLEM_LIST
  - $1"
}

days_ts() { date -d "$1" +%s 2>/dev/null || echo ""; }

echo "=== MindVault healthcheck ($(date '+%Y-%m-%d %H:%M')) ==="

# 1. Newest dated entry in log.md
log_entry="$(grep -oE '\[[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2})?\]' log.md | head -1)"
if [ -n "$log_entry" ]; then
  entry="${log_entry#\[}"; entry="${entry%\]}"
  log_ts="$(days_ts "$entry")"
  if [ -n "$log_ts" ]; then
    h=$(( (NOW - log_ts) / 3600 ))
    echo "log entry    : $entry (${h}h ago)"
    if [ "$h" -gt "$THRESHOLD_HOURS" ]; then add_problem "log.md has no entry in $THRESHOLD_HOURS hours (newest: $entry)"; fi
  else
    echo "log entry    : $entry (unparseable date)"
  fi
else
  echo "log entry    : NONE FOUND"
  add_problem "log.md contains no dated entries"
fi

# 2. Newest transcript file
if [ -d wiki/archive/raw/transcripts ]; then
  newest_t="$(find wiki/archive/raw/transcripts -maxdepth 1 -name '*.md' -printf '%T@ %f\n' 2>/dev/null | sort -rn | head -1)"
  if [ -n "$newest_t" ]; then
    tfile="${newest_t#* }"
    tts="${newest_t%% *}"; tts="${tts%.*}"
    h=$(( (NOW - tts) / 3600 ))
    echo "transcript   : $tfile (${h}h ago)"
    if [ "$h" -gt "$THRESHOLD_HOURS" ]; then add_problem "no transcript written in $THRESHOLD_HOURS hours (newest: $tfile)"; fi
  else
    echo "transcript   : NONE"
    add_problem "no transcript files exist"
  fi
else
  echo "transcript   : DIRECTORY MISSING"
  add_problem "transcript directory missing"
fi

# 3. Last git commit
last_commit="$(git log -1 --format='%cI' 2>/dev/null)"
if [ -n "$last_commit" ]; then
  cts="$(days_ts "$last_commit")"
  if [ -n "$cts" ]; then
    h=$(( (NOW - cts) / 3600 ))
    echo "last commit  : $(date -d "$last_commit" '+%Y-%m-%d %H:%M') (${h}h ago)"
    if [ "$h" -gt "$THRESHOLD_HOURS" ]; then add_problem "no commit in $THRESHOLD_HOURS hours (last: $(date -d "$last_commit" '+%Y-%m-%d %H:%M'))"; fi
  fi
else
  echo "last commit  : NONE"
  add_problem "no commits found"
fi

# 4. Working tree cleanliness (dirty at session open = last session never committed)
dirty="$(git status --porcelain 2>/dev/null)"
if [ -n "$dirty" ]; then
  count="$(printf '%s\n' "$dirty" | wc -l)"
  echo "working tree : DIRTY ($count files)"
  add_problem "working tree is dirty at session open - last session did not commit ($count files)"
else
  echo "working tree : clean"
fi

# 5. Content checks - records vs reality
# 5a. index.md must match the solution files
sol_count="$(ls wiki/solutions/*.md 2>/dev/null | wc -l)"
index_links="$(grep -o 'wiki/solutions/' index.md 2>/dev/null | wc -l)"
echo "solutions     : $sol_count files, index lists $index_links"
if [ "$sol_count" -ne "$index_links" ]; then add_problem "index lists $index_links solutions but $sol_count files exist - regenerate index.md"; fi

# 5b. every solution carries a recheck date
for f in wiki/solutions/*.md; do
  [ -e "$f" ] || continue
  if ! grep -qE '^recheck:' "$f"; then add_problem "solution missing recheck date: $(basename "$f")"; fi
done

# 5c. every dormant file is marked dormant
for f in wiki/dormant/*.md; do
  [ -e "$f" ] || continue
  if ! grep -qE '^status:[[:space:]]*dormant' "$f"; then add_problem "dormant file not marked dormant: $(basename "$f")"; fi
done

# 5d. HANDOFF.md exists
if [ ! -f HANDOFF.md ]; then add_problem "HANDOFF.md is missing"; fi

# 5e. broken internal links in active files
broken=0; broken_list=""
for f in AGENTS.md HANDOFF.md index.md wiki/predictions.md wiki/solutions/*.md wiki/dormant/*.md wiki/skills/*.md; do
  [ -f "$f" ] || continue
  while IFS= read -r link; do
    case "$link" in http:*|https:*|ftp:*|www.*) continue ;; esac
    cand="$link"
    case "$cand" in *.md) ;; *) cand="$cand.md" ;; esac
    if [ ! -e "$VAULT/$cand" ]; then
      broken=$((broken + 1))
      broken_list="$broken_list $(basename "$f"):[[$link]]"
    fi
  done < <(grep -oE '\[\[[^]|]+' "$f" 2>/dev/null | sed 's/\[\[//')
done
if [ "$broken" -gt 0 ]; then add_problem "broken links ($broken):$broken_list"; fi

# 6. Engine checks - clock, stakes, independence, decay
# 6a. prediction ledger: open bets, overdue, stalled (watchdog)
if [ -f wiki/predictions.md ]; then
  open_bets=0; overdue_bets=0; stalled_bets=0; stalled_list=""
  while IFS='|' read -r _ id _date _pred due _stake outcome verdict; do
    id="$(printf '%s' "$id" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    case "$id" in P[0-9]*) ;; *) continue ;; esac
    verdict="$(printf '%s' "$verdict" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [ -n "$verdict" ] && continue
    due="$(printf '%s' "$due" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    open_bets=$((open_bets + 1))
    dts="$(days_ts "$due")"
    if [ -n "$dts" ]; then
      if [ "$dts" -lt "$NOW" ]; then overdue_bets=$((overdue_bets + 1)); fi
      if [ $((NOW - dts)) -gt $((21 * 86400)) ]; then stalled_bets=$((stalled_bets + 1)); stalled_list="$stalled_list $id"; fi
    fi
  done < wiki/predictions.md
  echo "predictions   : $open_bets open, $overdue_bets overdue, $stalled_bets stalled"
  if [ "$overdue_bets" -gt 0 ]; then add_problem "$overdue_bets predictions overdue - resolve or mark as misses at session open"; fi
  if [ "$stalled_bets" -gt 0 ]; then add_problem "STALLED predictions ($stalled_list) older than 21 days - flush to dormant and reset"; fi
else
  echo "predictions   : LEDGER MISSING"
  add_problem "wiki/predictions.md is missing"
fi

# 6b. independence score: solutions that carry themselves (ai-absent)
ai_absent=0; ai_present_list=""
for f in wiki/solutions/*.md; do
  [ -e "$f" ] || continue
  if grep -qE '^mechanism:[[:space:]]*ai-absent' "$f"; then ai_absent=$((ai_absent + 1))
  elif grep -qE '^mechanism:[[:space:]]*ai-present' "$f"; then ai_present_list="$ai_present_list $(basename "$f")"; fi
done
echo "independence  : $ai_absent/$sol_count solutions carry themselves (ai-absent)"
if [ -n "$ai_present_list" ]; then add_problem "AI-dependent solutions - encode into the environment:$ai_present_list"; fi

# 6c. dormant decay: past-due dormant files compress to one line and archive
for f in wiki/dormant/*.md; do
  [ -e "$f" ] || continue
  decay="$(grep -oE '^decay:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$f" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')"
  if [ -n "$decay" ]; then
    dts="$(days_ts "$decay")"
    if [ -n "$dts" ] && [ "$dts" -lt "$NOW" ]; then add_problem "dormant past decay - compress and archive: $(basename "$f")"; fi
  fi
done

# 6d. recheck overdue: solutions past their recheck date surface in the recap
for f in wiki/solutions/*.md; do
  [ -e "$f" ] || continue
  recheck="$(grep -oE '^recheck:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$f" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')"
  if [ -n "$recheck" ]; then
    rts="$(days_ts "$recheck")"
    if [ -n "$rts" ] && [ "$rts" -lt "$NOW" ]; then add_problem "recheck overdue - surface in recap: $(basename "$f")"; fi
  fi
done

echo ""
if [ "$PROBLEMS" -eq 0 ]; then
  echo "HEALTHCHECK OK - all heartbeats within $THRESHOLD_HOURS hours."
  exit 0
else
  echo "HEALTHCHECK FAILED - REPAIR MODE:"
  printf '%s\n' "$PROBLEM_LIST"
  exit 1
fi
