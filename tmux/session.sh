#!/usr/bin/env bash
# =============================================================================
# session.sh — Launch full cocos-agent-team tmux session
# Usage: ./session.sh
# =============================================================================

set -euo pipefail

export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-$HOME/../PlayableTemplate}"
SESSION_NAME="cocos-team"

echo "🚀 Launching cocos-agent-team tmux session: $SESSION_NAME"

# Kill existing session if it exists
tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true

# Create new session — dashboard window
tmux new-session -d -s "$SESSION_NAME" -n "dashboard" \
  "echo 'Cocos Agent Team — Ctrl+b w to switch windows'; cat ${TEAM_DIR}/Setup.md; bash"

# Window 1 — cocos-dev
tmux new-window -t "$SESSION_NAME" -n "cocos-dev" -d \
  "export ROLE_NAME=cocos-dev; export TEAM_DIR=${TEAM_DIR}; export PROJECT_DIR=${PROJECT_DIR}; bash ${TEAM_DIR}/agents/roles/cocos-dev.sh"

# Window 2 — tool-dev
tmux new-window -t "$SESSION_NAME" -n "tool-dev" -d \
  "export ROLE_NAME=tool-dev; export TEAM_DIR=${TEAM_DIR}; export PROJECT_DIR=${PROJECT_DIR}; bash ${TEAM_DIR}/agents/roles/tool-dev.sh"

# Window 3 — quality-dev
tmux new-window -t "$SESSION_NAME" -n "quality-dev" -d \
  "export ROLE_NAME=quality-dev; export TEAM_DIR=${TEAM_DIR}; export PROJECT_DIR=${PROJECT_DIR}; bash ${TEAM_DIR}/agents/roles/quality-dev.sh"

# Configure status bar
tmux set-option -t "$SESSION_NAME" status-interval 5
tmux set-option -t "$SESSION_NAME" status-justify centre
tmux set-option -t "$SESSION_NAME" status-left "#[fg=cyan]🏗️ #S#[fg=default]"
tmux set-option -t "$SESSION_NAME" status-right \
  "#[fg=yellow]%H:%M  #[fg=cyan]cocos-dev#[fg=default] | #[fg=green]tool-dev#[fg=default] | #[fg=magenta]quality-dev#[fg=default]"

# Load custom layout
tmux source-file "${TEAM_DIR}/tmux/layout.conf" 2>/dev/null || true

# Return to dashboard
tmux select-window -t "$SESSION_NAME:0"

echo ""
echo -e "${C_GREEN}✅ Session '$SESSION_NAME' launched!${C_RESET}"
echo ""
echo "  Windows:"
echo "    0 — dashboard  (team overview + task board)"
echo "    1 — cocos-dev  (game features & gameplay)"
echo "    2 — tool-dev   (tooling & automation)"
echo "    3 — quality-dev (playtest & polish)"
echo ""
echo "  Attach:  ./tmux/attach.sh  or  tmux attach -t $SESSION_NAME"
echo "  Prefix:  Ctrl+b  |  Switch win:  Ctrl+b w"
