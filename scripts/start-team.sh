#!/usr/bin/env bash
# =============================================================================
# start-team.sh — Launch a selective agent team in tmux
#
# Creates a session with:
#   Window 0: dashboard  — README + live tail of configs/team-chat.md
#   Window 1: team       — one pane per selected role, tiled layout
#
# Usage:
#   ./scripts/start-team.sh [role ...] [--task "description"]
#
# Valid roles (any subset, any order):
#   design  cocos-engineer  typescript-dev  qa-tester
#
# If no roles are given, all four are launched.
#
# Examples:
#   ./scripts/start-team.sh design
#   ./scripts/start-team.sh design cocos-engineer
#   ./scripts/start-team.sh typescript-dev qa-tester --task "fix CTA logic"
#   ./scripts/start-team.sh                               # all four
# =============================================================================
set -euo pipefail

TEAM_DIR="${TEAM_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PROJECT_DIR="${PROJECT_DIR:-${TEAM_DIR}/..}"
SESSION="${SESSION_NAME:-cocos-playable-team}"
ROLES_DIR="${TEAM_DIR}/agents/roles"

C_RESET='\033[0m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_CYAN='\033[0;36m'

ALL_ROLES=(design cocos-engineer typescript-dev qa-tester)
SELECTED=()
TASK_DESC=""

# ── Parse args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task|-t)
      TASK_DESC="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: ./scripts/start-team.sh [role ...] [--task 'description']"
      echo ""
      echo "Roles: design  cocos-engineer  typescript-dev  qa-tester"
      echo "       (omit all to launch all four)"
      exit 0
      ;;
    design|cocos-engineer|typescript-dev|qa-tester)
      SELECTED+=("$1"); shift ;;
    *)
      echo -e "${C_RED}Unknown role or flag: $1${C_RESET}"
      echo "Valid roles: ${ALL_ROLES[*]}"
      exit 1 ;;
  esac
done

# Default: all roles
[[ ${#SELECTED[@]} -eq 0 ]] && SELECTED=("${ALL_ROLES[@]}")

N=${#SELECTED[@]}

# ── Preflight ─────────────────────────────────────────────────────────────────
for role in "${SELECTED[@]}"; do
  if [[ ! -f "${ROLES_DIR}/${role}.sh" ]]; then
    echo -e "${C_RED}Agent script not found: ${ROLES_DIR}/${role}.sh${C_RESET}"
    exit 1
  fi
done

echo -e "${C_CYAN}============================================${C_RESET}"
echo -e "${C_CYAN}  cocos-agent-team — start-team${C_RESET}"
echo -e "${C_CYAN}============================================${C_RESET}"
echo "  Agents  : ${SELECTED[*]}"
[[ -n "$TASK_DESC" ]] && echo "  Task    : $TASK_DESC"
echo "  Session : $SESSION"
echo "  TEAM_DIR: $TEAM_DIR"
echo ""

tmux kill-session -t "$SESSION" 2>/dev/null || true

# Log kickoff to team-chat
if [[ -n "$TASK_DESC" ]]; then
  TS=$(date "+%Y-%m-%d %H:%M")
  printf "> [%s] [coordinator] Kickoff: %s — agents: %s\n" \
    "$TS" "$TASK_DESC" "${SELECTED[*]}" >> "${TEAM_DIR}/configs/team-chat.md"
fi

# ── Window 0 — dashboard ─────────────────────────────────────────────────────
tmux new-session -d -s "$SESSION" -n "dashboard" "bash -c \
  'cat ${TEAM_DIR}/README.md 2>/dev/null; \
   echo; echo \"--- team-chat (live) ---\"; \
   tail -f ${TEAM_DIR}/configs/team-chat.md 2>/dev/null || true; \
   exec bash'"

# ── Window 1 — team (one pane per selected agent) ────────────────────────────
FIRST="${SELECTED[0]}"
tmux new-window -t "$SESSION" -n "team" \
  "TEAM_DIR='${TEAM_DIR}' PROJECT_DIR='${PROJECT_DIR}' bash '${ROLES_DIR}/${FIRST}.sh'"

FIRST_PANE=$(tmux display-message -t "$SESSION:team" -p "#{pane_id}")
tmux select-pane -t "$FIRST_PANE" -T "$FIRST"

for (( i=1; i<N; i++ )); do
  ROLE="${SELECTED[$i]}"
  NEW_PANE=$(tmux split-window -t "$SESSION:team" -d -P -F "#{pane_id}" \
    "TEAM_DIR='${TEAM_DIR}' PROJECT_DIR='${PROJECT_DIR}' bash '${ROLES_DIR}/${ROLE}.sh'")
  tmux select-pane -t "$NEW_PANE" -T "$ROLE"
done

# Even out pane sizes
tmux select-layout -t "$SESSION:team" tiled

# Show role name in each pane's top border
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

# ── Summary ───────────────────────────────────────────────────────────────────
echo -e "${C_GREEN}Session '$SESSION' ready — ${N} agent(s)${C_RESET}"
echo ""
for role in "${SELECTED[@]}"; do
  echo "  • $role"
done
echo ""
echo "  Attach:      ./tmux/attach.sh  or  tmux attach -t $SESSION"
echo "  Zoom pane:   Ctrl+b z  (toggle fullscreen)"
echo "  Nav panes:   Ctrl+b ←↑→↓"
echo "  Windows:     Ctrl+b w"
echo ""
