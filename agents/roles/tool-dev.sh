#!/usr/bin/env bash
# =============================================================================
# tool-dev.sh — Tool & Infrastructure Developer Agent
# Role: Build and maintain tooling, automation, CI/CD, asset pipelines
# =============================================================================

set -euo pipefail

export ROLE_NAME="tool-dev"
export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-$HOME/../PlayableTemplate}"

source "${TEAM_DIR}/agents/role-base.sh"

check_prereqs
validate_team_dir

banner "🔧 TOOL-DEV — Tool & Infrastructure Developer"
echo "  Project: ${PROJECT_DIR}"
echo "  Team dir: ${TEAM_DIR}"
echo "  Task board: ${TASK_BOARD}"
echo ""

log_to_team "$ROLE_NAME" "Agent started..."
read_context

# =============================================================================
# Bootstrap tools on startup
# =============================================================================
bootstrap_tools() {
  banner "🔧 TOOL-DEV — Bootstrap Phase"

  for dir in "${PROJECT_DIR}/scripts" "${PROJECT_DIR}/build" "${PROJECT_DIR}/tools" "${PROJECT_DIR}/docs"; do
    if [[ ! -d "$dir" ]]; then
      echo -e "${C_YELLOW}[tool-dev] Creating: $dir${C_RESET}"
      mkdir -p "$dir"
      log_to_team "$ROLE_NAME" "Created directory: $dir"
    fi
  done

  if [[ ! -f "${PROJECT_DIR}/build.config.json" ]]; then
    cat > "${PROJECT_DIR}/build.config.json" << 'EOF'
{
  "builds": {
    "web": { "platform": "web", "outputPath": "build/web", "debug": false },
    "android": { "platform": "android", "outputPath": "build/android", "debug": false }
  },
  "assetBundle": { "enabled": true, "compressionType": "zip" }
}
EOF
    log_to_team "$ROLE_NAME" "Created build.config.json template"
  fi

  if [[ ! -f "${PROJECT_DIR}/package.json" ]]; then
    cat > "${PROJECT_DIR}/package.json" << 'EOF'
{
  "name": "cocos-game",
  "version": "0.1.0",
  "description": "Cocos Creator game project",
  "scripts": {
    "dev": "cocos run -p web",
    "build:web": "cocos build -p web --no-compile",
    "build:android": "cocos build -p android --no-compile",
    "lint": "eslint assets --ext .ts,.js",
    "test": "node scripts/run-tests.js"
  },
  "devDependencies": {}
}
EOF
    log_to_team "$ROLE_NAME" "Created package.json"
  fi

  echo -e "${C_GREEN}[tool-dev] Bootstrap complete!${C_RESET}"
}

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
      | grep -E "#(tool|automation|pipeline|infra|cli)" \
      | grep -E "@unassigned|@${ROLE_NAME}" \
      | grep -v "@cocos-dev\|@quality-dev" \
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

      claude \
        --model "${CLAUDE_MODEL:-opus}" \
        --max-tokens "${CLAUDE_MAX_TOKENS:-4096}" \
        --system-prompt "file://${PROMPTS_DIR}/tool-dev-system.md" \
        --resume "You are working on task: $task_id
Project: $(cat "$PROJECT_CONTEXT" 2>/dev/null || echo 'not configured')
Task description: $task_desc
Task type: $task_type
Your role is TOOL-DEV. Project root: $PROJECT_DIR

Steps:
1. Read $PROJECT_CONTEXT
2. Navigate to $PROJECT_DIR
3. Build/implement the tool described
4. Mark task $task_id done in $TASK_BOARD
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
bootstrap_tools
run_loop
