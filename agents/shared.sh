#!/usr/bin/env bash
# =============================================================================
# shared.sh — Utility library sourced by all agents
# Usage: source "${TEAM_DIR}/agents/shared.sh"
# =============================================================================

# Parse a task line from the task board
# Example line: "- [ ] TASK-001: [feature] Implement jump #feature @cocos-dev"
parse_task() {
  local line="$1"
  local id desc type tags assignee
  id=$(echo "$line" | sed -n 's/.*\-\[.\?\].*\([A-Z]\+-[0-9]\+\):.*/\1/p')
  desc=$(echo "$line" | sed -n 's/.*\[[^]]*\].*\[[^]]*\].*\([A-Z]\+-[0-9]\+\):\s*\(.*\)/\2/p')
  type=$(echo "$line" | grep -oP '(?<=\[)[^]]*(?=\])' | head -1)
  tags=$(echo "$line" | grep -oP '#\w+' | tr '\n' ' ' | xargs)
  assignee=$(echo "$line" | grep -oP '@\w+' | sed 's/@//' | tr '\n' ' ' | xargs)
  echo "$id|$type|$desc|$tags|$assignee"
}

# Get all open tasks for a given tag
get_tasks_by_tag() {
  local tag="$1"
  local board_file="${TASK_BOARD:-${TEAM_DIR}/configs/task-board.md}"
  grep -E "^- \[ [~ ]\]" "$board_file" 2>/dev/null | grep "#${tag}" || true
}

# Get next available unassigned task for a set of tags
get_next_task() {
  local role="$1"
  local board_file="${TASK_BOARD:-${TEAM_DIR}/configs/task-board.md}"
  grep -E "^- \[ \]" "$board_file" 2>/dev/null | grep "@unassigned\|@${role}" | head -1 || true
}

# Send a message to another agent (write to chat file)
send_to_agent() {
  local recipient="$1"
  local message="$2"
  log_to_team "SYSTEM" "[DM to $recipient] $message"
}

# Block until project context is configured
wait_for_project() {
  local max_wait=300
  local waited=0
  while ! grep -q "Project name" "${PROJECT_CONTEXT:-${TEAM_DIR}/configs/project-context.md}" 2>/dev/null; do
    sleep 10
    waited=$((waited + 10))
    echo "[SYSTEM] Waiting for project context to be configured... (${waited}s)"
    if ((waited >= max_wait)); then
      echo -e "${C_YELLOW}[WARN] Project context not configured. Set it in configs/project-context.md${C_RESET}"
      break
    fi
  done
}

# Validate that team directory is accessible
validate_team_dir() {
  if [[ ! -d "$TEAM_DIR" ]]; then
    echo -e "${C_RED}[FATAL] TEAM_DIR not found: $TEAM_DIR${C_RESET}"
    echo "Set TEAM_DIR environment variable or ensure ~/cocos-agent-team exists"
    exit 1
  fi
}
