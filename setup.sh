#!/usr/bin/env bash
# =============================================================================
# setup.sh — One-command full setup for cocos-agent-team
#
# What it does:
#   1. Checks prerequisites (claude, curl, npx, git)
#   2. Sets up MCP servers (cocos-creator + agentmemory)
#   3. Installs the 5 playable skills into ~/.claude/skills/ so they are
#      available in ANY Claude Code project, not just this one:
#        /playable-team         — coordinate & launch a task-specific team
#        /cocos-playable-design
#        /cocos-playable-engineer
#        /cocos-playable-typescript
#        /cocos-playable-qa
#
# Usage:
#   ./setup.sh
#   PROJECT_DIR=/path/to/cocos-project ./setup.sh
#   ./setup.sh --project-dir /path/to/cocos-project
# =============================================================================
set -euo pipefail

TEAM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${PROJECT_DIR:-${TEAM_DIR}/..}"

C_RESET='\033[0m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_CYAN='\033[0;36m'

# ── Parse args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: ./setup.sh [--project-dir /path/to/cocos-project]"
      exit 0
      ;;
    *) echo -e "${C_RED}Unknown argument: $1${C_RESET}"; exit 1 ;;
  esac
done

echo -e "${C_CYAN}============================================${C_RESET}"
echo -e "${C_CYAN}  cocos-agent-team — Full Setup${C_RESET}"
echo -e "${C_CYAN}============================================${C_RESET}"
echo "  TEAM_DIR     = ${TEAM_DIR}"
echo "  PROJECT_DIR  = ${PROJECT_DIR}"
echo ""

# ── Step 1: Prerequisites ─────────────────────────────────────────────────────
echo -e "${C_GREEN}[1/3] Checking prerequisites...${C_RESET}"
MISSING=0
for bin in claude curl npx git; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo -e "  ${C_RED}✗ MISSING: $bin not in PATH${C_RESET}"
    MISSING=1
  else
    echo -e "  ${C_GREEN}✓ $bin${C_RESET}"
  fi
done
if [[ "$MISSING" == "1" ]]; then
  echo ""
  echo -e "${C_RED}Install the missing tools and retry. See Setup.md §0.${C_RESET}"
  exit 1
fi

# ── Step 2: MCP servers ───────────────────────────────────────────────────────
echo ""
echo -e "${C_GREEN}[2/3] Setting up MCP servers...${C_RESET}"
TEAM_DIR="$TEAM_DIR" PROJECT_DIR="$PROJECT_DIR" bash "${TEAM_DIR}/scripts/bootstrap-mcp.sh"

# ── Step 3: Install skills globally ──────────────────────────────────────────
echo ""
echo -e "${C_GREEN}[3/3] Installing Claude Code skills globally (5 skills)...${C_RESET}"

CLAUDE_SKILLS_DIR="${HOME}/.claude/skills"
mkdir -p "$CLAUDE_SKILLS_DIR"

install_skill() {
  local src="$1"
  local name="$2"
  local src_path="${TEAM_DIR}/skills/${src}"
  local dst_path="${CLAUDE_SKILLS_DIR}/${name}.md"
  if [[ -f "$src_path" ]]; then
    cp "$src_path" "$dst_path"
    echo -e "  ${C_GREEN}✓ ${name}${C_RESET}  →  ${dst_path}"
  else
    echo -e "  ${C_YELLOW}⚠ source not found: ${src_path}${C_RESET}"
  fi
}

install_skill "playable-team/SKILL.md"  "playable-team"
install_skill "design/SKILL.md"         "cocos-playable-design"
install_skill "cocos-engineer/SKILL.md" "cocos-playable-engineer"
install_skill "typescript-dev/SKILL.md" "cocos-playable-typescript"
install_skill "qa-tester/SKILL.md"      "cocos-playable-qa"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${C_CYAN}============================================${C_RESET}"
echo -e "${C_GREEN}  Setup complete!${C_RESET}"
echo -e "${C_CYAN}============================================${C_RESET}"
echo ""
echo "  Skills installed to: ${CLAUDE_SKILLS_DIR}"
echo "  Available as slash commands in any Claude Code project:"
echo "    /playable-team           ← start here: describe a task, get a team"
echo "    /cocos-playable-design"
echo "    /cocos-playable-engineer"
echo "    /cocos-playable-typescript"
echo "    /cocos-playable-qa"
echo ""
echo "  Next steps:"
echo "    1. Edit configs/project-context.md  (playable identity & budget)"
echo "    2. Edit configs/playable-spec.md    (storyboard)"
echo "    3. /playable-team in Claude Code    (describe your task → team auto-assembled)"
echo "       or: ./tmux/session.sh            (launch all four agents at once)"
echo ""
echo "  See Setup.md for details."
echo ""
