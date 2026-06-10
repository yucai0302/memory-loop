#!/usr/bin/env bash
# memory-loop: session-start.sh
# Runs at every SessionStart.
# 1. Initializes .claude/memory/ if this is the first time.
# 2. Prints memory file content so CC injects it into the session context.

set -euo pipefail

MEMORY_DIR="${CLAUDE_PROJECT_DIR}/.claude/memory"
MEMORY_FILE="${MEMORY_DIR}/MEMORY.md"
SCHEMA_FILE="${MEMORY_DIR}/schema.yaml"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"

# ── Init: create memory dir and files if missing ──────────────────────────────

if [ ! -d "${MEMORY_DIR}" ]; then
  mkdir -p "${MEMORY_DIR}"
fi

if [ ! -f "${SCHEMA_FILE}" ]; then
  cp "${PLUGIN_ROOT}/templates/schema.yaml" "${SCHEMA_FILE}"
fi

if [ ! -f "${MEMORY_FILE}" ]; then
  DATE=$(date '+%Y-%m-%d')
  sed "s/{{DATE}}/${DATE}/" "${PLUGIN_ROOT}/templates/MEMORY.md.tpl" > "${MEMORY_FILE}"
  echo "[memory-loop] Initialized project memory at .claude/memory/MEMORY.md"
  echo "[memory-loop] Edit .claude/memory/schema.yaml to customize tracked fields."
fi

# ── Inject: print memory content into session context ─────────────────────────

CHAR_COUNT=$(wc -c < "${MEMORY_FILE}")

echo ""
echo "======= PROJECT MEMORY (memory-loop) ======="
cat "${MEMORY_FILE}"
echo "============================================="
echo "[memory-loop] Memory loaded (${CHAR_COUNT} chars). Update it at the end of your work with /memory-loop:save"
echo ""
