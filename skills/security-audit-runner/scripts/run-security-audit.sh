#!/usr/bin/env bash
#
# run-security-audit.sh
# ------------------------------------------------------------------
# Automated security audit using the Cloudflare security-audit skill.
#
# What this does:
#   Runs the security-audit skill against the target codebase via
#   opencode in headless mode. The skill handles recon, hunting,
#   validation, reporting, and verification in a 6-phase pipeline.
#
# Requirements:
#   - opencode CLI installed and authenticated (non-interactive).
#   - jq installed (for parsing findings.json).
#   - security-audit skill installed in the target project:
#       npx skills add https://github.com/cloudflare/security-audit-skill \
#         --skill security-audit
#   - .env in this directory with TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID (optional).
#
# Usage:
#   ./run-security-audit.sh           # audits the current working directory
#   TARGET=/path/to/repo ./run-security-audit.sh
#
# Output:
#   Audit artifacts are written to <project-root>/.audit-results/
# ------------------------------------------------------------------

set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${TARGET:-$PWD}"
SKILL_DIR="$PROJECT_ROOT/.agents/skills/security-audit"
RESULTS_DIR="$PROJECT_ROOT/.audit-results"
DATE=$(date +%F)
ENV_FILE="$SCRIPT_DIR/.env"

# --- Pre-condition: skill must be installed locally ---

if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
  echo "ERROR: security-audit skill not found at $SKILL_DIR/"
  echo ""
  echo "Install it in the target project first:"
  echo "  cd $PROJECT_ROOT"
  echo "  npx skills add https://github.com/cloudflare/security-audit-skill --skill security-audit"
  echo ""
  echo "The skill must be installed locally (not globally) so the agent"
  echo "has pre-approved permissions for headless (non-interactive) runs."
  exit 1
fi

# --- Telegram credentials (optional) ---

TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""

if [ -f "$ENV_FILE" ]; then
  TELEGRAM_BOT_TOKEN=$(grep -E '^TELEGRAM_BOT_TOKEN=' "$ENV_FILE" | cut -d '=' -f2- || true)
  TELEGRAM_CHAT_ID=$(grep -E '^TELEGRAM_CHAT_ID=' "$ENV_FILE" | cut -d '=' -f2- || true)
fi

TELEGRAM_ENABLED=false
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
  TELEGRAM_ENABLED=true
  echo "Telegram notifications enabled."
else
  echo "Telegram notifications disabled (TELEGRAM_BOT_TOKEN / TELEGRAM_CHAT_ID not set)."
fi

send_telegram() {
  local message="$1"
  if [ "$TELEGRAM_ENABLED" = true ]; then
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
      -d chat_id="${TELEGRAM_CHAT_ID}" \
      -d parse_mode="Markdown" \
      --data-urlencode text="$message" > /dev/null
  fi
}

# --- Run audit ---

echo "Starting security audit of $PROJECT_ROOT ..."
echo "Output directory: $RESULTS_DIR/"

set +e
opencode run \
  "Security audit this codebase. Also identify high-impact improvements for reliability, performance, and code quality. Write all audit artifacts (architecture.md, REPORT.md, FINDINGS-DETAIL.md, findings.json) to .audit-results/ at the project root. Create the directory if it does not exist. Do not use ~/security-audit-skill/ or any other default output path." \
  --dir "$PROJECT_ROOT" \
  --thinking \
  --auto \
  --title "audit-$DATE" \
  2>&1 | tee "$RESULTS_DIR/raw-output-$DATE.md"

OPENCODE_EXIT_CODE=${PIPESTATUS[0]}
set -e

# --- Parse results ---

INCOMPLETE=false
INCOMPLETE_REASON=""

if [ "$OPENCODE_EXIT_CODE" -ne 0 ]; then
  INCOMPLETE=true
  INCOMPLETE_REASON="opencode exited with status $OPENCODE_EXIT_CODE"
elif grep -qiE "permission requested|auto-rejecting|rejected permission to use this|^Error:" "$RESULTS_DIR/raw-output-$DATE.md" 2>/dev/null; then
  INCOMPLETE=true
  INCOMPLETE_REASON="a tool call was rejected or errored mid-run"
fi

CRITICAL_COUNT=0
HIGH_COUNT=0
MEDIUM_COUNT=0
ISSUE_TITLES=""

if [ -f "$RESULTS_DIR/findings.json" ]; then
  CRITICAL_COUNT=$(jq '[.[] | select(.verdict == "confirmed" and .severity.overall_severity == "critical")] | length' "$RESULTS_DIR/findings.json" 2>/dev/null || echo 0)
  HIGH_COUNT=$(jq '[.[] | select(.verdict == "confirmed" and .severity.overall_severity == "high")] | length' "$RESULTS_DIR/findings.json" 2>/dev/null || echo 0)
  MEDIUM_COUNT=$(jq '[.[] | select(.verdict == "confirmed" and .severity.overall_severity == "medium")] | length' "$RESULTS_DIR/findings.json" 2>/dev/null || echo 0)
  ISSUE_TITLES=$(jq -r '.[] | select(.verdict == "confirmed" and (.severity.overall_severity == "critical" or .severity.overall_severity == "high")) | "\(.severity.overall_severity | ascii_upcase): \(.title)"' "$RESULTS_DIR/findings.json" 2>/dev/null || true)
fi

# --- Telegram notification ---

if [ "$INCOMPLETE" = true ]; then
  SUMMARY="⚠️ *audit ($DATE)*: INCOMPLETE — ${INCOMPLETE_REASON}. This is NOT a clean result; do not treat it as \"all good.\"

Full log: \`.audit-results/raw-output-$DATE.md\`"
elif [ "$CRITICAL_COUNT" -eq 0 ] && [ "$HIGH_COUNT" -eq 0 ]; then
  SUMMARY="✅ *audit ($DATE)*: All good — no CRITICAL or HIGH issues found."
else
  SUMMARY="🚨 *audit ($DATE)*: ${CRITICAL_COUNT} CRITICAL, ${HIGH_COUNT} HIGH, ${MEDIUM_COUNT} MEDIUM issue(s) found:
${ISSUE_TITLES}

Full report: \`.audit-results/\`"
fi

echo "$SUMMARY"
send_telegram "$SUMMARY"

if [ "$INCOMPLETE" = true ]; then
  exit 1
fi