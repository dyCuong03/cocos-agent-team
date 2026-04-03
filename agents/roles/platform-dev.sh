#!/usr/bin/env bash
# =============================================================================
# platform-dev.sh — 🔗 SDK Integration & Build Engineer
# Role: Ad SDK integration, WebGL export, platform builds, device compat
# =============================================================================
set -euo pipefail

export ROLE_NAME="platform-dev"
export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-$HOME/../PlayableTemplate}"

source "${TEAM_DIR}/agents/role-base.sh"

check_prereqs
validate_team_dir

source "${TEAM_DIR}/agents/shared.sh"
validate_project_dir

# Bootstrap platform directories on startup
bootstrap_platform() {
  banner "🔗 PLATFORM-DEV — Bootstrap"
  for dir in \
    "${PROJECT_DIR}/platforms" \
    "${PROJECT_DIR}/platforms/android" \
    "${PROJECT_DIR}/platforms/ios" \
    "${PROJECT_DIR}/platforms/web" \
    "${PROJECT_DIR}/builds"; do
    [[ ! -d "$dir" ]] && mkdir -p "$dir" && echo "  Created: $dir"
  done

  if [[ ! -f "${PROJECT_DIR}/platforms/build.config.json" ]]; then
    cat > "${PROJECT_DIR}/platforms/build.config.json" << 'EOF'
{
  "platforms": {
    "web":  { "outputPath": "builds/web",  "minify": true,  "splitAssets": true  },
    "android": { "outputPath": "builds/android", "minify": true, "targetApi": 33 },
    "ios":    { "outputPath": "builds/ios",    "minify": true, "targetApi": 17 }
  },
  "bundleBudget": {
    "initialLoadKB": 5120,
    "perAssetBundleKB": 1024
  }
}
EOF
    echo "  Created build.config.json"
  fi
  echo -e "${C_GREEN}  Bootstrap done${C_RESET}"
}

trap 'log_to_team "$ROLE_NAME" "Agent shutting down"; exit 0' INT TERM

bootstrap_platform
run_agent_loop "platform-dev" \
  "platform" "sdk" "integration" "webgl" "build" "export"
