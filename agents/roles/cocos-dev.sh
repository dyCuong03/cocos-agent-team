#!/usr/bin/env bash
# =============================================================================
# cocos-dev.sh — Cocos Game Developer Agent
# Role: Build game features, scenes, mechanics, UI, and gameplay systems
# =============================================================================

set -euo pipefail

export ROLE_NAME="cocos-dev"
export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-$HOME/../PlayableTemplate}"

source "${TEAM_DIR}/agents/role-base.sh"

check_prereqs
validate_team_dir

banner "🏗️  COCOS-DEV — Cocos Game Developer"
echo "  Project: ${PROJECT_DIR}"
echo "  Team dir: ${TEAM_DIR}"
echo "  Task board: ${TASK_BOARD}"
echo ""

log_to_team "$ROLE_NAME" "Agent started — reading project context..."
read_context

# =============================================================================
# Agent Loop
# =============================================================================
run_loop() {
  local iteration=0
  while true; do
    iteration=$((iteration + 1))
    echo -e "${C_BLUE}[$ROLE_NAME] Cycle $iteration — checking task board...${C_RESET}"

    local task
    task=$(grep -E "^- \[ \]" "$TASK_BOARD" 2>/dev/null \
      | grep -E "#(feature|scene|ui|gameplay|animation)" \
      | grep -E "@unassigned|@${ROLE_NAME}" \
      | grep -v "@tool-dev\|@quality-dev" \
      | head -1 || true)

    if [[ -n "$task" ]]; then
      local task_id
      task_id=$(echo "$task" | grep -oP '[A-Z]+-[0-9]+' | head -1)
      local task_desc
      task_desc=$(echo "$task" | sed -n 's/.*\[[^]]*\].*\[[^]]*\].*\([A-Z]\+-[0-9]\+\):\s*\(.*\)/\2/p')
      local task_type
      task_type=$(echo "$task" | grep -oP '(?<=\[)[^]]*(?=\])' | head -1)

      echo -e "${C_GREEN}[$ROLE_NAME] Claiming: $task_id — $task_desc${C_RESET}"
      mark_in_progress "$task_id" "$ROLE_NAME"
      log_to_team "$ROLE_NAME" "Working on $task_id — $task_desc"

      # Invoke Claude Code to implement the task
      claude \
        --model "${CLAUDE_MODEL:-opus}" \
        --max-tokens "${CLAUDE_MAX_TOKENS:-4096}" \
        --system-prompt "file://${PROMPTS_DIR}/cocos-dev-system.md" \
        --resume "You are working on task: $task_id
Project: $(cat "$PROJECT_CONTEXT" 2>/dev/null || echo 'not configured')
Task description: $task_desc
Task type: $task_type
Your role is COCOS-DEV. Project root: $PROJECT_DIR

Steps:
1. Read $PROJECT_CONTEXT to understand the game
2. Navigate to $PROJECT_DIR
3. Implement the feature
4. Mark task $task_id done in $TASK_BOARD (change [ ] to [x])
5. Log completion to $TEAM_CHAT
6. Loop back to check for more tasks
" 2>&1 || {
        echo -e "${C_YELLOW}[$ROLE_NAME] Claude exited for $task_id${C_RESET}"
        log_to_team "$ROLE_NAME" "Task $task_id encountered an issue"
      }

    else
      echo -e "${C_YELLOW}[$ROLE_NAME] No tasks found. Waiting 30s...${C_RESET}"
      sleep 30
    fi
  done
}

trap 'log_to_team "$ROLE_NAME" "Agent shutting down"; exit 0' INT TERM
run_loop
