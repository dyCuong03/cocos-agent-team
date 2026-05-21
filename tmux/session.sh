#!/usr/bin/env bash
# =============================================================================
# session.sh — Launch the cocos-playable-team tmux session
#
#   Window 0: dashboard  — README + live tail of team-chat.md
#   Window 1: team       — 2×2 pane grid, one pane per agent:
#
#       ┌─────────────────────┬─────────────────────┐
#       │  design             │  cocos-engineer      │
#       │  (wireframes/UX)    │  (scenes/prefabs)    │
#       ├─────────────────────┼─────────────────────┤
#       │  typescript-dev     │  qa-tester           │
#       │  (scripts/logic)    │  (playtest/perf)     │
#       └─────────────────────┴─────────────────────┘
#
#   Zoom a pane to full-screen:   Ctrl+b z  (toggle)
#   Navigate panes:               Ctrl+b ←↑→↓
#   Switch windows:               Ctrl+b w
# =============================================================================
set -euo pipefail

export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-${TEAM_DIR}/..}"
SESSION="${SESSION_NAME:-cocos-playable-team}"
ROLES="${TEAM_DIR}/agents/roles"

C_RESET='\033[0m'; C_GREEN='\033[0;32m'; C_CYAN='\033[0;36m'

echo -e "${C_CYAN}Launching $SESSION...${C_RESET}"
echo "  TEAM_DIR    = $TEAM_DIR"
echo "  PROJECT_DIR = $PROJECT_DIR"

tmux kill-session -t "$SESSION" 2>/dev/null || true

# ── Window 0 — dashboard ─────────────────────────────────────────────────────
tmux new-session -d -s "$SESSION" -n "dashboard" "bash -c \
  'cat ${TEAM_DIR}/README.md 2>/dev/null; \
   echo; \
   echo \"--- team-chat (live) ---\"; \
   tail -f ${TEAM_DIR}/configs/team-chat.md 2>/dev/null || true; \
   exec bash'"

# ── Window 1 — team (2×2 pane grid) ──────────────────────────────────────────

# Top-left pane: design
tmux new-window -t "$SESSION" -n "team" \
  "TEAM_DIR='${TEAM_DIR}' PROJECT_DIR='${PROJECT_DIR}' bash '${ROLES}/design.sh'"
PANE_DESIGN=$(tmux display-message -t "$SESSION:team" -p "#{pane_id}")

# Top-right pane: cocos-engineer  (split design horizontally)
PANE_COCOS=$(tmux split-window -t "$PANE_DESIGN" -h -d -P -F "#{pane_id}" \
  "TEAM_DIR='${TEAM_DIR}' PROJECT_DIR='${PROJECT_DIR}' bash '${ROLES}/cocos-engineer.sh'")

# Bottom-left pane: typescript-dev  (split design vertically)
PANE_TS=$(tmux split-window -t "$PANE_DESIGN" -v -d -P -F "#{pane_id}" \
  "TEAM_DIR='${TEAM_DIR}' PROJECT_DIR='${PROJECT_DIR}' bash '${ROLES}/typescript-dev.sh'")

# Bottom-right pane: qa-tester  (split cocos-engineer vertically)
PANE_QA=$(tmux split-window -t "$PANE_COCOS" -v -d -P -F "#{pane_id}" \
  "TEAM_DIR='${TEAM_DIR}' PROJECT_DIR='${PROJECT_DIR}' bash '${ROLES}/qa-tester.sh'")

# Even out the 2×2 grid
tmux select-layout -t "$SESSION:team" tiled

# Label each pane — shown in the pane border header
tmux select-pane -t "$PANE_DESIGN" -T "design"
tmux select-pane -t "$PANE_COCOS"  -T "cocos-engineer"
tmux select-pane -t "$PANE_TS"     -T "typescript-dev"
tmux select-pane -t "$PANE_QA"     -T "qa-tester"

# Show pane titles in top border of each pane
tmux set-option -t "$SESSION" pane-border-status top
tmux set-option -t "$SESSION" pane-border-format \
  "#[fg=cyan,bold] #{pane_title} #[fg=default,nobold]"

# ── Status bar ────────────────────────────────────────────────────────────────
tmux set-option -t "$SESSION" status-interval 5
tmux set-option -t "$SESSION" status-justify centre
tmux set-option -t "$SESSION" status-left  "#[fg=cyan,bold] #S #[fg=default,nobold]"
tmux set-option -t "$SESSION" status-right \
  "#[fg=yellow]%H:%M  #[fg=cyan]z:zoom  arrows:nav  w:wins#[fg=default]"

tmux source-file "${TEAM_DIR}/tmux/layout.conf" 2>/dev/null || true
tmux select-window -t "$SESSION:0"

echo ""
echo -e "${C_GREEN}Session '$SESSION' ready!${C_RESET}"
echo ""
echo "  Window 0 — dashboard  (README + live team-chat)"
echo "  Window 1 — team       (2×2 pane grid)"
echo "    top-left  : design"
echo "    top-right : cocos-engineer"
echo "    bot-left  : typescript-dev"
echo "    bot-right : qa-tester"
echo ""
echo "  Attach:         ./tmux/attach.sh  or  tmux attach -t $SESSION"
echo "  Zoom pane:      Ctrl+b z  (toggle fullscreen for one agent)"
echo "  Navigate panes: Ctrl+b ←↑→↓"
echo "  Switch windows: Ctrl+b w"
echo ""
