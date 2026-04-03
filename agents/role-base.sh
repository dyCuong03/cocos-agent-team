#!/usr/bin/env bash
# =============================================================================
# role-base.sh — Shared base prompt loaded by every agent role
# Loaded via: source "${TEAM_DIR}/agents/role-base.sh"
# =============================================================================

set -euo pipefail

# Resolve team directory (works even if not set)
export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-$HOME/../PlayableTemplate}"

# Colors for terminal output
export C_RESET='\033[0m'
export C_RED='\033[0;31m'
export C_GREEN='\033[0;32m'
export C_YELLOW='\033[0;33m'
export C_BLUE='\033[0;34m'
export C_CYAN='\033[0;36m'

# Convenience paths
export TASK_BOARD="${TEAM_DIR}/configs/task-board.md"
export PROJECT_CONTEXT="${TEAM_DIR}/configs/project-context.md"
export TEAM_CHAT="${TEAM_DIR}/configs/team-chat.md"
export PROMPTS_DIR="${TEAM_DIR}/prompts"

# Log to team chat
log_to_team() {
  local role="$1"
  local message="$2"
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M")
  echo "> [$timestamp] [$role] $message" >> "$TEAM_CHAT"
}

# Read current task board
read_board() {
  cat "$TASK_BOARD"
}

# Read project context
read_context() {
  cat "$PROJECT_CONTEXT"
}

# Append to task board
append_board() {
  local tag="${2:-}"
  local assignee="${3:-unassigned}"
  echo "- [ ] $1 #$tag @${assignee}" >> "$TASK_BOARD"
}

# Mark task done in task board (inline sed — finds first match by ID)
mark_done() {
  local task_id="$1"
  sed -i "s/^- \[ \] ${task_id}/- [x] ${task_id}/" "$TASK_BOARD"
}

# Mark task in-progress
mark_in_progress() {
  local task_id="$1"
  local agent="$2"
  sed -i "s/^- \[ \] ${task_id}/- [~] ${task_id}/" "$TASK_BOARD"
  sed -i "s/@unassigned/@${agent}/" "$(grep -n "${task_id}" "$TASK_BOARD" | cut -d: -f1 | head -1)dummy" 2>/dev/null || true
  # Simple approach: just tag in team chat
  :
}

# Print a banner
banner() {
  echo ""
  echo -e "${C_CYAN}========================================${C_RESET}"
  echo -e "${C_CYAN}  $1${C_RESET}"
  echo -e "${C_CYAN}========================================${C_RESET}"
  echo ""
}

# Check prerequisites
check_prereqs() {
  local missing=()
  command -v claude >/dev/null 2>&1 || missing+=(claude)
  command -v tmux >/dev/null 2>&1 || missing+=(tmux)
  if ((${#missing[@]} > 0)); then
    echo -e "${C_RED}[ERROR] Missing required tools: ${missing[*]}${C_RESET}"
    exit 1
  fi
}

# Load role-specific system prompt if it exists
load_role_prompt() {
  local role="$1"
  local prompt_file="${PROMPTS_DIR}/${role}-system.md"
  if [[ -f "$prompt_file" ]]; then
    echo "Loaded role prompt: $prompt_file"
  fi
}
