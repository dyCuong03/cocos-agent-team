#!/usr/bin/env bash
# =============================================================================
# bootstrap-mcp.sh — Wire the two MCP servers the team depends on.
#   1. Cocos MCP Server (HTTP)   — provided by dyCuong03/cocos-mcp-server
#   2. agentmemory MCP (stdio)   — cross-session memory
# =============================================================================
set -euo pipefail

TEAM_DIR="${TEAM_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
PROJECT_DIR="${PROJECT_DIR:-${TEAM_DIR}/..}"

C_RESET='\033[0m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[0;33m'; C_RED='\033[0;31m'

echo -e "${C_GREEN}=== cocos-agent-team — MCP bootstrap ===${C_RESET}"
echo "  TEAM_DIR     = ${TEAM_DIR}"
echo "  PROJECT_DIR  = ${PROJECT_DIR}"
echo ""

# ── Prereqs ────────────────────────────────────────────────────────────────
for bin in claude curl npx git; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo -e "${C_RED}MISSING: $bin not in PATH${C_RESET}"
    MISSING=1
  fi
done
[[ "${MISSING:-0}" == "1" ]] && { echo "Install the missing tools and retry."; exit 1; }

# ── 1. cocos-mcp-server ────────────────────────────────────────────────────
EXT_DIR="${PROJECT_DIR}/extensions/cocos-mcp-server"
if [[ -d "$EXT_DIR" ]]; then
  echo -e "${C_GREEN}[1/2] cocos-mcp-server already at ${EXT_DIR}${C_RESET}"
else
  echo -e "${C_YELLOW}[1/2] Cloning cocos-mcp-server into ${EXT_DIR}${C_RESET}"
  mkdir -p "${PROJECT_DIR}/extensions"
  git clone https://github.com/dyCuong03/cocos-mcp-server.git "$EXT_DIR"
  ( cd "$EXT_DIR" && npm install && npm run build )
  echo -e "${C_YELLOW}    → Now restart Cocos Creator and start the server from:${C_RESET}"
  echo -e "${C_YELLOW}      Extension menu → Cocos MCP Server → Start${C_RESET}"
fi

# Probe the HTTP endpoint
if curl -sf --max-time 2 -X POST http://127.0.0.1:3000/mcp >/dev/null 2>&1; then
  echo -e "${C_GREEN}    ✓ cocos-mcp-server responding on http://127.0.0.1:3000/mcp${C_RESET}"
else
  echo -e "${C_YELLOW}    ⚠ cocos-mcp-server not reachable. Open Cocos Creator and start it.${C_RESET}"
fi

# ── 2. agentmemory registration ────────────────────────────────────────────
# We rely on configs/mcp-servers.json being passed to each `claude` call via
# --mcp-config. This is wired in agents/role-base.sh. Also register globally
# so ad-hoc `claude` invocations see it.

echo -e "${C_GREEN}[2/2] Registering MCP servers globally via 'claude mcp add'${C_RESET}"
claude mcp list 2>/dev/null | grep -q "cocos-creator" \
  || claude mcp add --transport http cocos-creator http://127.0.0.1:3000/mcp \
  || echo -e "${C_YELLOW}    ⚠ 'claude mcp add cocos-creator' failed — add manually${C_RESET}"

claude mcp list 2>/dev/null | grep -q "agentmemory" \
  || claude mcp add agentmemory npx -- -y @agentmemory/mcp-server \
  || echo -e "${C_YELLOW}    ⚠ 'claude mcp add agentmemory' failed — adjust command in configs/mcp-servers.json${C_RESET}"

echo ""
echo -e "${C_GREEN}✓ Bootstrap done. Verify with:${C_RESET}"
echo "    claude mcp list"
echo ""
echo "Then launch the team:"
echo "    ./tmux/session.sh"
