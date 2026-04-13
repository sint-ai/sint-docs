#!/usr/bin/env bash
# verify-redirects.sh — confirm every legacy docs.sint.gg path 301s to the right destination.
#
# Usage:
#   ./scripts/verify-redirects.sh                          # runs against docs.sint.gg
#   DOCS_HOST=https://staging-docs.example.sint.gg ./scripts/verify-redirects.sh
#
# Exits 0 on full success, 1 on any miss. Missed paths print to stderr.

set -euo pipefail

DOCS_HOST="${DOCS_HOST:-https://docs.sint.gg}"

# Format: <legacy_path>|<expected_destination_path>
REDIRECTS=$(cat <<'EOF'
/introduction|/origin
/whitepaper|/origin
/whitepaper/chapter-1|/origin
/whitepaper/tokenomics|/origin
/whitepaper/roadmap|/origin
/security|/protocol/security
/mcp-marketplace|/origin
/sintbridge|/protocol/layers/bridge
/sintasibridge|/origin
/presskit|/press
/tokenomics|/origin
/tokenomics/distribution|/origin
/marketplace|/origin
/marketplace/listings|/origin
/airdrop|/origin
/token|/origin
/asi|/origin
/agents/trading|/origin
/agents/defi|/origin
/agents/social|/origin
EOF
)

MISS=0
PASS=0
echo "Verifying redirects against: $DOCS_HOST"
echo

while IFS= read -r line; do
  [ -z "$line" ] && continue
  src="${line%|*}"
  expected="${line#*|}"

  # -s silent, -o discard body, -w print status, -L NO (we want the 301 itself), -I head request
  status=$(curl -sS -o /dev/null -w "%{http_code}" -I "${DOCS_HOST}${src}")
  location=$(curl -sS -D - -o /dev/null "${DOCS_HOST}${src}" | awk 'tolower($1)=="location:" {print $2}' | tr -d '\r\n' | sed "s|${DOCS_HOST}||")

  if [ "$status" = "301" ] && [ "$location" = "$expected" ]; then
    printf "  \033[32m✓\033[0m %s  →  %s  (301)\n" "$src" "$location"
    PASS=$((PASS + 1))
  else
    printf "  \033[31m✗\033[0m %s  →  %s  (got status=%s, location=%s)\n" \
      "$src" "$expected" "$status" "$location" >&2
    MISS=$((MISS + 1))
  fi
done <<< "$REDIRECTS"

echo
echo "Passed: $PASS   Missed: $MISS"
exit $([ "$MISS" -eq 0 ] && echo 0 || echo 1)
