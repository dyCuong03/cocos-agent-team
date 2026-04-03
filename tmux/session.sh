#!/usr/bin/env bash
# =============================================================================
# session.sh — Launch full playable-ad team tmux session
# =============================================================================
set -euo pipefail

export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-$HOME/../PlayableTemplate}"
SESSION_NAME="playable-team"

echo "🚀 Launching playable-ad team: $SESSION_NAME"

tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true

# Dashboard window
tmux new-session -d -s "$SESSION_NAME" -n "dashboard" \
  "echo 'Playable Ad Agent Team — Ctrl+b w to switch windows'; cat ${TEAM_DIR}/Setup.md; bash"

# Window 1 — creative-dev
tmux new-window -t "$SESSION_NAME" -n "creative-dev" -d \
  "export ROLE_NAME=creative-dev; export TEAM_DIR=${TEAM_DIR}; export PROJECT_DIR=${PROJECT_DIR}; bash ${TEAM_DIR}/agents/roles/creative-dev.sh"

# Window 2 — platform-dev
tmux new-window -t "$SESSION_NAME" -n "platform-dev" -d \
  "export ROLE_NAME=platform-dev; export TEAM_DIR=${TEAM_DIR}; export PROJECT_DIR=${PROJECT_DIR}; bash ${TEAM_DIR}/agents/roles/platform-dev.sh"

# Window 3 — asset-dev
tmux new-window -t "$SESSION_NAME" -n "asset-dev" -d \
  "export ROLE_NAME=asset-dev; export TEAM_DIR=${TEAM_DIR}; export PROJECT_DIR=${PROJECT_DIR}; bash ${TEAM_DIR}/agents/roles/asset-dev.sh"

# Window 4 — adops-dev
tmux new-window -t "$SESSION_NAME" -n "adops-dev" -d \
  "export ROLE_NAME=adops-dev; export TEAM_DIR=${TEAM_DIR}; export PROJECT_DIR=${PROJECT_DIR}; bash ${TEAM_DIR}/agents/roles/adops-dev.sh"

# Window 5 — qa-dev
tmux new-window -t "$SESSION_NAME" -n "qa-dev" -d \
  "export ROLE_NAME=qa-dev; export TEAM_DIR=${TEAM_DIR}; export PROJECT_DIR=${PROJECT_DIR}; bash ${TEAM_DIR}/agents/roles/qa-dev.sh"

# Status bar
tmux set-option -t "$SESSION_NAME" status-interval 5
tmux set-option -t "$SESSION_NAME" status-justify centre
tmux set-option -t "$SESSION_NAME" status-left "#[fg=cyan]🎯 #S#[fg=default]"
tmux set-option -t "$SESSION_NAME" status-right \
  "#[fg=yellow]%H:%M  #[fg=cyan]creative#[fg=default] #[fg=green]platform#[fg=default] #[fg=magenta]asset#[fg=default] #[fg=red]adops#[fg=default] #[fg=blue]qa#[fg=default]"

tmux source-file "${TEAM_DIR}/tmux/layout.conf" 2>/dev/null || true
tmux select-window -t "$SESSION_NAME:0"

echo ""
echo -e "${C_GREEN}✅ Session '$SESSION_NAME' launched!${C_RESET}"
echo ""
echo "  Windows:"
echo "    0 — dashboard"
echo "    1 — creative-dev   🎯 Hook design, gameplay mechanics"
echo "    2 — platform-dev   🔗 SDK integration, WebGL, builds"
echo "    3 — asset-dev      🎨 Art, UI, VFX, end cards"
echo "    4 — adops-dev      📊 Tracking, CI/CD, backend"
echo "    5 — qa-dev         ✅ Playtest, perf, compliance"
echo ""
echo "  Attach:  ./tmux/attach.sh  or  tmux attach -t $SESSION_NAME"
echo "  Prefix:  Ctrl+b  |  Switch win:  Ctrl+b w"
