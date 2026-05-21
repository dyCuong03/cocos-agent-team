#!/usr/bin/env bash
# =============================================================================
# new-playable.sh — Scaffold a fresh playable run.
#   1. Resets team-chat
#   2. Re-emits a clean task-board (preserving custom additions if --keep-tasks)
#   3. Copies spec-template to configs/playable-spec.md if missing
#   4. Wipes docs/design and docs/qa from prior runs (with confirmation)
# =============================================================================
set -euo pipefail

TEAM_DIR="${TEAM_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

C_RESET='\033[0m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[0;33m'

KEEP_TASKS=0
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --keep-tasks) KEEP_TASKS=1 ;;
    --force) FORCE=1 ;;
    -h|--help)
      echo "Usage: $0 [--keep-tasks] [--force]"
      echo "  --keep-tasks  Preserve current task-board.md (default: reset)"
      echo "  --force       Skip confirmation prompts"
      exit 0
      ;;
  esac
done

echo -e "${C_GREEN}=== Scaffold new playable run ===${C_RESET}"
echo "  TEAM_DIR = ${TEAM_DIR}"
echo ""

# ── 1. Reset team-chat ──────────────────────────────────────────────────────
echo "" > "${TEAM_DIR}/configs/team-chat.md"
echo "# Team Chat" >> "${TEAM_DIR}/configs/team-chat.md"
echo "" >> "${TEAM_DIR}/configs/team-chat.md"
echo "Agents post here with timestamped \`@role\` mentions." >> "${TEAM_DIR}/configs/team-chat.md"
echo -e "${C_GREEN}✓${C_RESET} reset configs/team-chat.md"

# ── 2. Task board ──────────────────────────────────────────────────────────
if (( KEEP_TASKS == 0 )); then
  if (( FORCE == 0 )); then
    read -r -p "Reset configs/task-board.md to the default backlog? [y/N] " ans
    [[ "$ans" =~ ^[yY]$ ]] || { echo "Skipping task-board reset."; SKIP_TB=1; }
  fi
  if [[ "${SKIP_TB:-0}" == "0" ]]; then
    # Re-emit defaults by sourcing the template if present, else leave existing
    if [[ -f "${TEAM_DIR}/configs/task-board.default.md" ]]; then
      cp "${TEAM_DIR}/configs/task-board.default.md" "${TEAM_DIR}/configs/task-board.md"
    fi
    echo -e "${C_GREEN}✓${C_RESET} reset configs/task-board.md"
  fi
fi

# ── 3. Playable spec ───────────────────────────────────────────────────────
if [[ ! -f "${TEAM_DIR}/configs/playable-spec.md" ]] && [[ ! -f "${TEAM_DIR}/configs/playable-spec.json" ]]; then
  cp "${TEAM_DIR}/configs/spec-template.md" "${TEAM_DIR}/configs/playable-spec.md"
  echo -e "${C_GREEN}✓${C_RESET} created configs/playable-spec.md from template"
  echo -e "${C_YELLOW}  → Edit configs/playable-spec.md before launching the team${C_RESET}"
else
  echo -e "${C_YELLOW}-${C_RESET} configs/playable-spec.{md,json} already present, leaving as-is"
fi

# ── 4. docs/ wipe ──────────────────────────────────────────────────────────
for d in docs/design docs/qa; do
  if [[ -d "${TEAM_DIR}/${d}" ]] && [[ -n "$(ls -A "${TEAM_DIR}/${d}" 2>/dev/null)" ]]; then
    if (( FORCE == 0 )); then
      read -r -p "Wipe ${d}/ (contains prior-run artifacts)? [y/N] " ans
      [[ "$ans" =~ ^[yY]$ ]] || continue
    fi
    rm -rf "${TEAM_DIR}/${d}"/*
    echo -e "${C_GREEN}✓${C_RESET} wiped ${d}/"
  fi
done

mkdir -p "${TEAM_DIR}/docs/design" "${TEAM_DIR}/docs/qa"

echo ""
echo -e "${C_GREEN}Ready. Next:${C_RESET}"
echo "  1. Edit configs/project-context.md"
echo "  2. Edit configs/playable-spec.md (or use playable-spec.json)"
echo "  3. Drop raw assets into \$PROJECT_DIR/assets/"
echo "  4. ./scripts/bootstrap-mcp.sh"
echo "  5. ./tmux/session.sh"
