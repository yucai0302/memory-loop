#!/usr/bin/env bash
# memory-loop: check-compress.sh
# Runs at every Stop event.
# Warns the user when MEMORY.md is getting large and compression is recommended.

set -euo pipefail

MEMORY_FILE="${CLAUDE_PROJECT_DIR}/.claude/memory/MEMORY.md"
SCHEMA_FILE="${CLAUDE_PROJECT_DIR}/.claude/memory/schema.yaml"

# If no memory file yet, nothing to check.
[ -f "${MEMORY_FILE}" ] || exit 0

CHAR_COUNT=$(wc -c < "${MEMORY_FILE}")

# Read threshold from schema.yaml (default 8000 if not set or yq not available).
THRESHOLD=8000
if command -v yq &>/dev/null && [ -f "${SCHEMA_FILE}" ]; then
  VAL=$(yq '.compression.trigger_chars' "${SCHEMA_FILE}" 2>/dev/null || echo "")
  [ -n "${VAL}" ] && [ "${VAL}" != "null" ] && THRESHOLD="${VAL}"
fi

if [ "${CHAR_COUNT}" -gt "${THRESHOLD}" ]; then
  echo ""
  echo "[memory-loop] ⚠️  MEMORY.md is ${CHAR_COUNT} chars (threshold: ${THRESHOLD})."
  echo "[memory-loop] Run /memory-loop:compress to archive older entries and keep the hot layer lean."
  echo ""
fi
