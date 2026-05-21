#!/usr/bin/env bash
# =============================================================================
# typescript-dev.sh — Cocos Creator 3.8.x Gameplay TypeScript Coder
# Role: All .ts components, state machines, input, audio, CTA flow
# =============================================================================
set -euo pipefail

export ROLE_NAME="typescript-dev"
export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-${TEAM_DIR}/..}"

source "${TEAM_DIR}/agents/role-base.sh"
check_prereqs
validate_team_dir

source "${TEAM_DIR}/agents/shared.sh"
validate_project_dir

trap 'log_to_team "$ROLE_NAME" "Agent shutting down"; exit 0' INT TERM

run_agent_loop "typescript-dev" \
  "ts" "typescript" "gameplay" "logic" "script" "state-machine" "input" "audio"
