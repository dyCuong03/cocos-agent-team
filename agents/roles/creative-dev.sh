#!/usr/bin/env bash
# =============================================================================
# creative-dev.sh — 🎯 Playable Ad Creative Designer
# Role: Hook design, core loop, CTA, gameplay mechanics, conversion events
# =============================================================================
set -euo pipefail

export ROLE_NAME="creative-dev"
export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-$HOME/../PlayableTemplate}"

source "${TEAM_DIR}/agents/role-base.sh"

check_prereqs
validate_team_dir

source "${TEAM_DIR}/agents/shared.sh"
validate_project_dir

trap 'log_to_team "$ROLE_NAME" "Agent shutting down"; exit 0' INT TERM

run_agent_loop "creative-dev" \
  "creative" "gameplay-design" "hook" "core-loop" "cta" "conversion"
