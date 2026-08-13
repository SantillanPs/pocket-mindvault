#!/usr/bin/env bash
# MindVault operational healthcheck.
# This checks whether the AI environment can operate; it does NOT require
# activity heartbeats, daily notes, transcripts, or a recent commit.
# Usage: bash scripts/healthcheck.sh

set -u
VAULT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$VAULT" || { echo "cannot enter vault: $VAULT"; exit 1; }

PROBLEMS=0
problem() { PROBLEMS=$((PROBLEMS + 1)); echo "  - $1"; }
check_file() { [ -f "$1" ] && echo "✓ $1" || problem "missing required file: $1"; }
check_dir() { [ -d "$1" ] && echo "✓ $1/" || problem "missing required directory: $1/"; }

echo "=== MindVault operational healthcheck ($(date '+%Y-%m-%d %H:%M')) ==="

echo ""
echo "Core state"
check_file AGENTS.md
check_file HANDOFF.md
check_file index.md
check_dir wiki
check_dir scripts

# Git is a storage/rollback dependency, not a heartbeat.
echo ""
echo "Git"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "✓ repository"
  echo "  branch: $(git branch --show-current 2>/dev/null || echo unknown)"
  echo "  commits: $(git rev-list --count HEAD 2>/dev/null || echo unknown)"
else
  problem "not a Git repository"
fi

# Check the durable knowledge areas that currently exist. Empty areas are OK.
echo ""
echo "Durable knowledge"
for d in wiki/solutions wiki/skills wiki/navigate/maps wiki/dormant wiki/archive; do
  if [ -d "$d" ]; then
    count="$(find "$d" -type f -not -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ')"
    echo "✓ $d/ ($count files)"
  fi
done

# Validate the small amount of current state without requiring it to exist.
echo ""
echo "Current state"
if [ -f HANDOFF.md ]; then
  if grep -qE '^status:[[:space:]]*active|^##[[:space:]]+(Active|Current|Next)' HANDOFF.md; then
    echo "✓ HANDOFF.md contains current-state markers"
  else
    echo "✓ HANDOFF.md exists; no active work is currently required"
  fi
fi

# Basic internal-link validation for the small set of operational files.
echo ""
echo "Links"
broken=0
for f in AGENTS.md HANDOFF.md index.md wiki/solutions/*.md wiki/skills/*.md wiki/dormant/*.md; do
  [ -f "$f" ] || continue
  while IFS= read -r link; do
    case "$link" in http:*|https:*|ftp:*|www.*) continue ;; esac
    cand="$link"
    case "$cand" in *.md) ;; *) cand="$cand.md" ;; esac
    if [ ! -e "$VAULT/$cand" ]; then
      broken=$((broken + 1))
      echo "  broken: $f -> [[$link]]"
    fi
  done < <(grep -oE '\[\[[^]|]+' "$f" 2>/dev/null | sed 's/\[\[//')
done
if [ "$broken" -eq 0 ]; then echo "✓ no broken operational links"; else problem "$broken broken operational links"; fi

# A malformed solution is worth flagging; an old or missing recheck date is not.
solution_count=0
malformed=0
for f in wiki/solutions/*.md; do
  [ -f "$f" ] || continue
  solution_count=$((solution_count + 1))
  if ! grep -qE '^recheck:' "$f" && ! grep -qE '^status:' "$f"; then
    malformed=$((malformed + 1)); echo "  malformed solution metadata: $f"
  fi
done
echo "✓ solutions: $solution_count"
[ "$malformed" -eq 0 ] || problem "$malformed solution files have no recognizable metadata"

echo ""
if [ "$PROBLEMS" -eq 0 ]; then
  echo "HEALTHCHECK OK - MindVault is operational."
  exit 0
else
  echo "HEALTHCHECK FAILED - operational problems found: $PROBLEMS"
  exit 1
fi
