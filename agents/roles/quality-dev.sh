#!/usr/bin/env bash
# =============================================================================
# quality-dev.sh — Quality & Polish Developer Agent
# Role: Playtest, profile, test, debug, and polish the game
# =============================================================================

set -euo pipefail

export ROLE_NAME="quality-dev"
export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-$HOME/../PlayableTemplate}"

source "${TEAM_DIR}/agents/role-base.sh"

check_prereqs
validate_team_dir

banner "🎮 QUALITY-DEV — Quality & Polish Developer"
echo "  Project: ${PROJECT_DIR}"
echo "  Team dir: ${TEAM_DIR}"
echo "  Task board: ${TASK_BOARD}"
echo ""

log_to_team "$ROLE_NAME" "Agent started..."
read_context

# =============================================================================
# Bootstrap quality baseline
# =============================================================================
bootstrap_quality() {
  banner "🎮 QUALITY-DEV — Quality Baseline Phase"

  if [[ ! -d "${PROJECT_DIR}/tests" ]]; then
    mkdir -p "${PROJECT_DIR}/tests"
    log_to_team "$ROLE_NAME" "Created tests/ directory"
  fi

  if [[ ! -d "${PROJECT_DIR}/docs" ]]; then
    mkdir -p "${PROJECT_DIR}/docs"
  fi

  local perf_checklist="${PROJECT_DIR}/docs/quality-checklist.md"
  if [[ ! -f "$perf_checklist" ]]; then
    cat > "$perf_checklist" << 'EOF'
# Quality Checklist

## Pre-Playtest
- [ ] Frame rate ≥ 60fps on target device
- [ ] No console errors on startup
- [ ] All assets loaded without 404s
- [ ] Memory usage < 200MB at rest

## Gameplay
- [ ] Player controls responsive (< 16ms input lag)
- [ ] No jank during scene transitions
- [ ] Audio plays without pops/clicks
- [ ] UI elements are touch-friendly (≥ 44px targets)

## Visual Polish
- [ ] Consistent art style across all scenes
- [ ] Animations run at correct frame rates
- [ ] No z-fighting or clipping issues
- [ ] Dark/light mode contrast ratios ≥ 4.5:1

## Accessibility
- [ ] Font size ≥ 16px for body text
- [ ] Buttons have clear focus states
- [ ] No color-only indicators
- [ ] Touch targets ≥ 44x44px

## Performance
- [ ] Draw calls < 200 per frame
- [ ] No memory leaks after 10 minutes play
- [ ] GPU usage < 80% sustained
- [ ] Scene load time < 3 seconds
EOF
    echo -e "${C_GREEN}[quality-dev] Created quality checklist${C_RESET}"
    log_to_team "$ROLE_NAME" "Created quality checklist at $perf_checklist"
  fi

  local bug_template="${PROJECT_DIR}/docs/bug-report-template.md"
  if [[ ! -f "$bug_template" ]]; then
    cat > "$bug_template" << 'EOF'
# Bug Report — [SHORT TITLE]

## Severity
- [ ] Critical (game breaking)
- [ ] Major (feature broken)
- [ ] Minor (cosmetic/annoyance)

## Summary
One-paragraph description of the bug.

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. See error / observe '...'

## Expected Behavior
What should happen.

## Actual Behavior
What actually happens.

## Environment
- Device: [device name]
- OS: [OS version]
- Cocos Creator: [version]
- Build: [web/native/mobile]

## Screenshots / Video
[Attach media here]

## Notes
Any additional context.
EOF
    log_to_team "$ROLE_NAME" "Created bug report template"
  fi

  echo -e "${C_GREEN}[quality-dev] Quality baseline established!${C_RESET}"
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
      | grep -E "#(bug|perf|test|playtest|polish|accessibility)" \
      | grep -E "@unassigned|@${ROLE_NAME}" \
      | grep -v "@cocos-dev\|@tool-dev" \
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
        --system-prompt "file://${PROMPTS_DIR}/quality-dev-system.md" \
        --resume "You are working on task: $task_id
Project: $(cat "$PROJECT_CONTEXT" 2>/dev/null || echo 'not configured')
Task description: $task_desc
Task type: $task_type
Your role is QUALITY-DEV. Project root: $PROJECT_DIR

Steps:
1. Read $PROJECT_CONTEXT
2. Navigate to $PROJECT_DIR
3. Perform the quality task (playtest, bug fix, audit, etc.)
4. Write findings to docs/playtest-report.md or docs/bug-report-[id].md
5. Mark task $task_id done in $TASK_BOARD
6. Log completion to $TEAM_CHAT
7. Loop back to check for more tasks
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
bootstrap_quality
run_loop
