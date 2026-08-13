#!/usr/bin/env bash
# Relevance-first retrieval for MindVault.
# Usage: bash scripts/search_context.sh "query" [limit]
# Searches high-value durable state first and falls back to broader history only
# when explicitly requested with --archive or --all.

set -u
VAULT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$VAULT" || exit 1

usage() {
  echo "Usage: bash scripts/search_context.sh \"query\" [limit] [--archive|--all]"
}

QUERY="${1:-}"
LIMIT="${2:-12}"
SCOPE="core"
for arg in "$@"; do
  case "$arg" in
    --archive) SCOPE="archive" ;;
    --all) SCOPE="all" ;;
  esac
done

if [ -z "$QUERY" ]; then usage; exit 2; fi
if ! [[ "$LIMIT" =~ ^[0-9]+$ ]]; then echo "limit must be an integer" >&2; exit 2; fi

# Deliberately exclude raw history from normal retrieval. This prevents a
# conversational query from turning into a whole-vault dump.
PATHS=(
  AGENTS.md HANDOFF.md index.md
  state knowledge wiki/solutions wiki/skills wiki/navigate wiki/learn wiki/reflect
)
if [ "$SCOPE" = "archive" ] || [ "$SCOPE" = "all" ]; then
  PATHS+=(archive transcripts)
fi

SEARCHER=""
if command -v rg >/dev/null 2>&1; then SEARCHER="rg"; elif command -v grep >/dev/null 2>&1; then SEARCHER="grep"; fi
if [ -z "$SEARCHER" ]; then echo "Neither rg nor grep is available." >&2; exit 1; fi

echo "=== MindVault context retrieval ==="
echo "query: $QUERY"
echo "scope: $SCOPE"
echo ""

if [ "$SEARCHER" = "rg" ]; then
  # Filename matches are surfaced naturally by rg; line context stays small.
  rg -n -i -S --hidden \
    --glob '!**/.git/**' \
    --glob '*.md' \
    -- "$QUERY" "${PATHS[@]}" 2>/dev/null | head -n "$LIMIT"
else
  grep -RniE --include='*.md' --exclude-dir='.git' -- "$QUERY" "${PATHS[@]}" 2>/dev/null | head -n "$LIMIT"
fi
