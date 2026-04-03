#!/usr/bin/env bash
# =============================================================================
# shared.sh — Utility library for all agents
# Usage: source "${TEAM_DIR}/agents/shared.sh"
# =============================================================================

# Parse a task line: returns id|type|desc|tags|assignee
parse_task() {
  local line="$1"
  local id desc type tags assignee
  id=$(echo "$line" | grep -oP '[A-Z]+-[0-9]+' | head -1)
  type=$(echo "$line" | grep -oP '(?<=\[)[^]]*(?=\])' | head -1)
  desc=$(echo "$line" | sed -n 's/.*\[[^]]*\].*\[[^]]*\].*\([A-Z]\+-[0-9]\+\):\s*\(.*\)/\2/p')
  tags=$(echo "$line" | grep -oP '#\w+' | tr '\n' ' ' | sed 's/ #/ /g' | xargs)
  assignee=$(echo "$line" | grep -oP '@\w+' | sed 's/@//' | tr '\n' ' ' | xargs)
  echo "$id|$type|$desc|$tags|$assignee"
}

# Get all tasks matching a tag
get_tasks_by_tag() {
  local tag="$1"
  grep -E "^- \[.+\]" "$TASK_BOARD" 2>/dev/null | grep "#${tag}" || true
}

# Count open tasks by role
count_tasks() {
  local role="$1"
  grep -cE "^- \[ \].*@(unassigned|${role})" "$TASK_BOARD" 2>/dev/null || echo "0"
}

# Append a new task to the board
add_task() {
  local id="$1"
  local type="$2"
  local desc="$3"
  local tags="$4"
  local assignee="${5:-unassigned}"
  echo "- [ ] $id: [$type] $desc $tags @$assignee" >> "$TASK_BOARD"
}

# DM another agent by writing to chat
dm_agent() {
  local recipient="$1"
  local message="$2"
  log_to_team "$ROLE_NAME" "[DM→@${recipient}] $message"
}

# Block until project context is configured
wait_for_project() {
  local waited=0
  while ! grep -q "Project name" "${PROJECT_CONTEXT}" 2>/dev/null; do
    sleep 10
    waited=$((waited + 10))
    echo "[${ROLE_NAME}] Waiting for project context... (${waited}s)"
    ((waited >= 300)) && break
  done
}

# Validate project directory
validate_project_dir() {
  if [[ ! -d "$PROJECT_DIR" ]]; then
    echo -e "${C_YELLOW}[${ROLE_NAME}] WARNING: PROJECT_DIR not found: $PROJECT_DIR${C_RESET}"
    echo -e "${C_YELLOW}[${ROLE_NAME}] Create it or set PROJECT_DIR before starting${C_RESET}"
    log_to_team "$ROLE_NAME" "PROJECT_DIR not found: $PROJECT_DIR"
  fi
}
