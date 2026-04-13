#!/usr/bin/env bash
# verify-pages.sh — confirm every page in mint.json resolves with HTTP 200.
#
# Usage:
#   ./scripts/verify-pages.sh
#   DOCS_HOST=https://staging-docs.example.sint.gg ./scripts/verify-pages.sh
#
# Requires: jq

set -euo pipefail

DOCS_HOST="${DOCS_HOST:-https://docs.sint.gg}"
MINT="${MINT:-$(dirname "$0")/../mint.json}"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 2
fi

# Walk mint.json "navigation" tree; "pages" entries are either strings (paths)
# or objects with their own "pages" arrays. Flatten recursively.
PAGES=$(jq -r '
  def walk_pages:
    if type == "string" then .
    elif type == "object" then
      if has("pages") then .pages[] | walk_pages else empty end
    elif type == "array" then .[] | walk_pages
    else empty
    end;
  .navigation[] | .pages[] | walk_pages
' "$MINT" | sort -u)

MISS=0
PASS=0
echo "Verifying pages against: $DOCS_HOST"
echo

while IFS= read -r page; do
  [ -z "$page" ] && continue
  status=$(curl -sS -o /dev/null -w "%{http_code}" -L "${DOCS_HOST}/${page}")
  if [ "$status" = "200" ]; then
    printf "  \033[32m✓\033[0m /%s\n" "$page"
    PASS=$((PASS + 1))
  else
    printf "  \033[31m✗\033[0m /%s (status=%s)\n" "$page" "$status" >&2
    MISS=$((MISS + 1))
  fi
done <<< "$PAGES"

echo
echo "Passed: $PASS   Missed: $MISS"
exit $([ "$MISS" -eq 0 ] && echo 0 || echo 1)
