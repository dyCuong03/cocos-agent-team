#!/usr/bin/env bash
# =============================================================================
# qa-tester.sh — Cocos Creator 3.8.x Playable QA Tester
# Role: Playtest, perf profiling, regression, scene/asset validation, sign-off
# =============================================================================
set -euo pipefail

export ROLE_NAME="qa-tester"
export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-${TEAM_DIR}/..}"

source "${TEAM_DIR}/agents/role-base.sh"
check_prereqs
validate_team_dir

source "${TEAM_DIR}/agents/shared.sh"
validate_project_dir

trap 'log_to_team "$ROLE_NAME" "Agent shutting down"; exit 0' INT TERM

run_agent_loop "qa-tester" \
  "qa" "test" "perf" "regression" "playtest" "release" "signoff" "qa-bug"
