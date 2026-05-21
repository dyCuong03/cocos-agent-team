#!/usr/bin/env bash
# =============================================================================
# design.sh — Cocos Playable UI/UX Designer
# Role: Wireframes, scene layouts, asset specs, interaction contracts
# =============================================================================
set -euo pipefail

export ROLE_NAME="design"
export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-${TEAM_DIR}/..}"

source "${TEAM_DIR}/agents/role-base.sh"
check_prereqs
validate_team_dir

source "${TEAM_DIR}/agents/shared.sh"
validate_project_dir

trap 'log_to_team "$ROLE_NAME" "Agent shutting down"; exit 0' INT TERM

run_agent_loop "design" \
  "design" "ui" "ux" "wireframe" "layout" "flow" "screen"
