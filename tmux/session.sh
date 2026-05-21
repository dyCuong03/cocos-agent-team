#!/usr/bin/env bash
# =============================================================================
# session.sh — Launch the cocos-playable-team tmux session
#   4 windows, one per role: design, cocos-engineer, typescript-dev, qa-tester
# =============================================================================
set -euo pipefail

export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-${TEAM_DIR}/..}"
SESSION_NAME="${SESSION_NAME:-cocos-playable-team}"

echo "🚀 Launching cocos-playable-team: $SESSION_NAME"
echo "   TEAM_DIR     = $TEAM_DIR"
echo "   PROJECT_DIR  = $PROJECT_DIR"

tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true

# ── Window 0 — dashboard ─────────────────────────────────────────────────────
tmux new-session -d -s "$SESSION_NAME" -n "dashboard" \
  "echo 'cocos-playable-team — Ctrl+b w to switch windows'; cat ${TEAM_DIR}/README.md 2>/dev/null || cat ${TEAM_DIR}/Setup.md; bash"

# ── Window 1 — design ────────────────────────────────────────────────────────
tmux new-window -t "$SESSION_NAME" -n "design" -d \
  "export ROLE_NAME=design; export TEAM_DIR=${TEAM_DIR}; export PROJECT_DIR=${PROJECT_DIR}; bash ${TEAM_DIR}/agents/roles/design.sh"

# ── Window 2 — cocos-engineer ────────────────────────────────────────────────
tmux new-window -t "$SESSION_NAME" -n "cocos-engineer" -d \
  "export ROLE_NAME=cocos-engineer; export TEAM_DIR=${TEAM_DIR}; export PROJECT_DIR=${PROJECT_DIR}; bash ${TEAM_DIR}/agents/roles/cocos-engineer.sh"

# ── Window 3 — typescript-dev ────────────────────────────────────────────────
tmux new-window -t "$SESSION_NAME" -n "typescript-dev" -d \
  "export ROLE_NAME=typescript-dev; export TEAM_DIR=${TEAM_DIR}; export PROJECT_DIR=${PROJECT_DIR}; bash ${TEAM_DIR}/agents/roles/typescript-dev.sh"

# ── Window 4 — qa-tester ─────────────────────────────────────────────────────
tmux new-window -t "$SESSION_NAME" -n "qa-tester" -d \
  "export ROLE_NAME=qa-tester; export TEAM_DIR=${TEAM_DIR}; export PROJECT_DIR=${PROJECT_DIR}; bash ${TEAM_DIR}/agents/roles/qa-tester.sh"

# ── Status bar ───────────────────────────────────────────────────────────────
tmux set-option -t "$SESSION_NAME" status-interval 5
tmux set-option -t "$SESSION_NAME" status-justify centre
tmux set-option -t "$SESSION_NAME" status-left "#[fg=cyan]🎮 #S#[fg=default]"
tmux set-option -t "$SESSION_NAME" status-right \
  "#[fg=yellow]%H:%M  #[fg=magenta]design#[fg=default] #[fg=cyan]cocos#[fg=default] #[fg=green]ts#[fg=default] #[fg=red]qa#[fg=default]"

tmux source-file "${TEAM_DIR}/tmux/layout.conf" 2>/dev/null || true
tmux select-window -t "$SESSION_NAME:0"

echo ""
echo "✅ Session '$SESSION_NAME' launched!"
echo ""
echo "  Windows:"
echo "    0 — dashboard"
echo "    1 — design          🎨 Wireframes, UI/UX, interaction contracts"
echo "    2 — cocos-engineer  🛠  Scenes, prefabs, components, builds"
echo "    3 — typescript-dev  💻 Gameplay scripts, state machines, input"
echo "    4 — qa-tester       ✅ Playtest, perf, regression, sign-off"
echo ""
echo "  Attach:  ./tmux/attach.sh  or  tmux attach -t $SESSION_NAME"
echo "  Prefix:  Ctrl+b  |  Switch win:  Ctrl+b w"
