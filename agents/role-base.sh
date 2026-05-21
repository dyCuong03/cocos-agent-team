#!/usr/bin/env bash
# =============================================================================
# role-base.sh — Shared base loaded by every agent role
# Usage: source "${TEAM_DIR}/agents/role-base.sh"
# =============================================================================

set -euo pipefail

export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-${TEAM_DIR}/..}"

# Terminal colors
export C_RESET='\033[0m'
export C_RED='\033[0;31m'
export C_GREEN='\033[0;32m'
export C_YELLOW='\033[0;33m'
export C_BLUE='\033[0;34m'
export C_CYAN='\033[0;36m'
export C_MAGENTA='\033[0;35m'

# Shared paths
export TASK_BOARD="${TEAM_DIR}/configs/task-board.md"
export PROJECT_CONTEXT="${TEAM_DIR}/configs/project-context.md"
export TEAM_CHAT="${TEAM_DIR}/configs/team-chat.md"
export PROMPTS_DIR="${TEAM_DIR}/prompts"
export SKILLS_DIR="${TEAM_DIR}/skills"
export MCP_CONFIG="${TEAM_DIR}/configs/mcp-servers.json"
export PLAYABLE_SPEC_MD="${TEAM_DIR}/configs/playable-spec.md"
export PLAYABLE_SPEC_JSON="${TEAM_DIR}/configs/playable-spec.json"

# ── Logging ──────────────────────────────────────────────────────────────────

log_to_team() {
  local role="$1"
  local message="$2"
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M")
  echo "> [$timestamp] [$role] $message" >> "$TEAM_CHAT"
}

# ── Task board helpers ────────────────────────────────────────────────────────

mark_done() {
  local task_id="$1"
  sed -i "s/^- \[ \] ${task_id}/- [x] ${task_id}/" "$TASK_BOARD"
  sed -i "s/^- \[~\] ${task_id}/- [x] ${task_id}/" "$TASK_BOARD"
}

mark_in_progress() {
  local task_id="$1"
  local agent="$2"
  sed -i "s/^- \[ \] \(.*${task_id}.*\)/- [~] \1/" "$TASK_BOARD"
  sed -i "s/@unassigned/@${agent}/" "$TASK_BOARD"
  :
}

# Find next unassigned task matching tag patterns
find_task() {
  local role="$1"
  shift
  local tags=("$@")
  local tag_pattern
  tag_pattern=$(printf "%s|" "${tags[@]}" | sed 's/|$//')
  grep -E "^- \[ \]" "$TASK_BOARD" 2>/dev/null \
    | grep -E "#(${tag_pattern})" \
    | grep -E "@unassigned|@${role}" \
    | head -1 || true
}

# ── Read helpers ─────────────────────────────────────────────────────────────

read_board()   { cat "$TASK_BOARD"; }
read_context() { cat "$PROJECT_CONTEXT"; }

# ── Display ──────────────────────────────────────────────────────────────────

banner() {
  echo ""
  echo -e "${C_CYAN}========================================${C_RESET}"
  echo -e "${C_CYAN}  $1${C_RESET}"
  echo -e "${C_CYAN}========================================${C_RESET}"
  echo ""
}

# ── Prereqs ──────────────────────────────────────────────────────────────────

check_prereqs() {
  local missing=()
  command -v claude >/dev/null 2>&1 || missing+=(claude)
  command -v tmux >/dev/null 2>&1 || missing+=(tmux)
  if ((${#missing[@]} > 0)); then
    echo -e "${C_RED}[ERROR] Missing: ${missing[*]}${C_RESET}"
    exit 1
  fi
}

validate_team_dir() {
  if [[ ! -d "$TEAM_DIR" ]]; then
    echo -e "${C_RED}[FATAL] TEAM_DIR not found: $TEAM_DIR${C_RESET}"
    echo "Set TEAM_DIR or ensure cocos-agent-team exists"
    exit 1
  fi
}

# ── MCP server pre-flight ────────────────────────────────────────────────────
# Check that the two MCP servers this team depends on are configured.
# We don't fail hard if they're missing — the role's autonomous loop will
# notice via tool errors and post to team-chat. But we DO warn loudly.

check_mcp_servers() {
  local cocos_ok=0
  local memory_ok=0

  # Check cocos-creator HTTP endpoint
  if command -v curl >/dev/null 2>&1; then
    if curl -sf --max-time 2 "http://127.0.0.1:3000/mcp" >/dev/null 2>&1 \
       || curl -sf --max-time 2 -X POST "http://127.0.0.1:3000/mcp" >/dev/null 2>&1; then
      cocos_ok=1
    fi
  fi

  if (( cocos_ok == 0 )); then
    echo -e "${C_YELLOW}[${ROLE_NAME}] WARN: cocos-mcp-server not reachable at http://127.0.0.1:3000/mcp${C_RESET}"
    echo -e "${C_YELLOW}[${ROLE_NAME}]       Open Cocos Creator → Extension → Cocos MCP Server → Start${C_RESET}"
    log_to_team "$ROLE_NAME" "WARN: cocos-mcp-server not reachable on startup"
  fi

  # agentmemory presence is harder to probe from bash (it's claude-side MCP).
  # The role's autonomous loop validates it on first memory_recall call.
  echo -e "${C_BLUE}[${ROLE_NAME}] MCP config: ${MCP_CONFIG}${C_RESET}"
}

# ── Claude invocation ────────────────────────────────────────────────────────

run_claude() {
  local task_id="$1"
  local task_desc="$2"
  local task_type="$3"

  # Build claude command with MCP config if present
  local mcp_args=()
  if [[ -f "$MCP_CONFIG" ]]; then
    mcp_args+=(--mcp-config "$MCP_CONFIG")
  fi

  local spec_path="(no spec found)"
  if [[ -f "$PLAYABLE_SPEC_MD" ]]; then
    spec_path="$PLAYABLE_SPEC_MD"
  elif [[ -f "$PLAYABLE_SPEC_JSON" ]]; then
    spec_path="$PLAYABLE_SPEC_JSON"
  fi

  claude \
    --model "${CLAUDE_MODEL:-opus}" \
    --max-tokens "${CLAUDE_MAX_TOKENS:-4096}" \
    "${mcp_args[@]}" \
    --system-prompt "file://${PROMPTS_DIR}/${ROLE_NAME}-system.md" \
    --resume "You are working on task: $task_id

Role:           ${ROLE_NAME}
Skill file:     ${SKILLS_DIR}/${ROLE_NAME}/SKILL.md  (read this first)
Project context: ${PROJECT_CONTEXT}
Playable spec:  ${spec_path}
Task board:     ${TASK_BOARD}
Team chat:      ${TEAM_CHAT}
Project root:   ${PROJECT_DIR}

Task: $task_id
Description: $task_desc
Type: $task_type

Steps:
1. mcp__agentmemory__memory_recall  with key pattern: playable:*:${ROLE_NAME}:*
2. Read ${SKILLS_DIR}/${ROLE_NAME}/SKILL.md
3. Read ${PROJECT_CONTEXT} and the playable spec (markdown or JSON)
4. Execute the workflow from your SKILL.md
5. Mark ${task_id} done in ${TASK_BOARD} (change [~] to [x])
6. Log completion to ${TEAM_CHAT}, mentioning the next agent
7. mcp__agentmemory__memory_save  the decision summary
8. Loop back to find more tasks
" 2>&1 || {
      echo -e "${C_YELLOW}[${ROLE_NAME}] Claude exited for $task_id${C_RESET}"
      log_to_team "$ROLE_NAME" "Task $task_id encountered an issue"
    }
}

# ── Generic agent loop ─────────────────────────────────────────────────────────

run_agent_loop() {
  local role="$1"
  export ROLE_NAME="$role"
  shift
  local tags=("$@")

  banner "${role} — ${ROLE_NAME}"
  echo "  Team dir : $TEAM_DIR"
  echo "  Project  : $PROJECT_DIR"
  echo "  Board    : $TASK_BOARD"
  echo "  Skill    : ${SKILLS_DIR}/${ROLE_NAME}/SKILL.md"
  echo "  Tags     : ${tags[*]}"
  echo ""

  check_mcp_servers

  log_to_team "$ROLE_NAME" "Agent started"
  read_context

  local iteration=0
  while true; do
    iteration=$((iteration + 1))
    echo -e "${C_BLUE}[${ROLE_NAME}] Cycle $iteration — polling board...${C_RESET}"

    local task
    task=$(find_task "$role" "${tags[@]}" || true)

    if [[ -n "$task" ]]; then
      local task_id task_desc task_type
      task_id=$(echo "$task" | grep -oP '[A-Z]+-[0-9]+' | head -1)
      task_desc=$(echo "$task" | sed -n 's/.*\[[^]]*\].*\[[^]]*\].*\([A-Z]\+-[0-9]\+\):\s*\(.*\)/\2/p')
      task_type=$(echo "$task" | grep -oP '(?<=\[)[^]]*(?=\])' | head -1)

      echo -e "${C_GREEN}[${ROLE_NAME}] Claiming: $task_id — $task_desc${C_RESET}"
      mark_in_progress "$task_id" "$ROLE_NAME"
      log_to_team "$ROLE_NAME" "Working on $task_id — $task_desc"
      run_claude "$task_id" "$task_desc" "$task_type"
    else
      echo -e "${C_YELLOW}[${ROLE_NAME}] No tasks. Waiting 30s...${C_RESET}"
      sleep 30
    fi
  done
}
