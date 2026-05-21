#!/usr/bin/env bash
# =============================================================================
# cocos-engineer.sh — Cocos Creator 3.8.x Editor Specialist
# Role: Scenes, prefabs, components, asset import, animations, builds
# =============================================================================
set -euo pipefail

export ROLE_NAME="cocos-engineer"
export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-${TEAM_DIR}/..}"

source "${TEAM_DIR}/agents/role-base.sh"
check_prereqs
validate_team_dir

source "${TEAM_DIR}/agents/shared.sh"
validate_project_dir

trap 'log_to_team "$ROLE_NAME" "Agent shutting down"; exit 0' INT TERM

run_agent_loop "cocos-engineer" \
  "cocos" "scene" "prefab" "editor" "asset-import" "anim" "particle" "build"
