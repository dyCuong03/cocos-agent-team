#!/usr/bin/env bash
# =============================================================================
# adops-dev.sh — 📊 Tracking, Analytics & CI/CD Engineer
# Role: Analytics, tracking, CI/CD pipelines, backend scripts
# =============================================================================
set -euo pipefail

export ROLE_NAME="adops-dev"
export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-$HOME/../PlayableTemplate}"

source "${TEAM_DIR}/agents/role-base.sh"

check_prereqs
validate_team_dir

source "${TEAM_DIR}/agents/shared.sh"
validate_project_dir

# Bootstrap tracking infrastructure
bootstrap_adops() {
  banner "📊 ADOPS-DEV — Bootstrap"
  for dir in \
    "${PROJECT_DIR}/tracking" \
    "${PROJECT_DIR}/scripts" \
    "${PROJECT_DIR}/ci" \
    "${PROJECT_DIR}/backend" \
    "${PROJECT_DIR}/docs"; do
    [[ ! -d "$dir" ]] && mkdir -p "$dir" && echo "  Created: $dir"
  done

  # Create tracking event schema
  if [[ ! -f "${PROJECT_DIR}/tracking/events.schema.json" ]]; then
    cat > "${PROJECT_DIR}/tracking/events.schema.json" << 'EOF'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Playable Ad Events",
  "events": {
    "ad_start":          { "type": "event",    "description": "Playable ad started" },
    "hook_played":        { "type": "event",    "description": "Hook segment completed" },
    "core_loop_start":    { "type": "event",    "description": "User entered core loop" },
    "cta_shown":          { "type": "event",    "description": "CTA / end card displayed" },
    "cta_clicked":        { "type": "click",    "description": "User tapped install CTA" },
    "ad_complete":       { "type": "event",    "description": "Playable ad finished" },
    "session_duration":   { "type": "timing",  "description": "Total play time (ms)" },
    "level_reached":      { "type": "progress", "description": "Deepest level reached" },
    "tutorial_skipped":   { "type": "event",    "description": "User skipped tutorial" },
    "install_confirmed":  { "type": "conversion", "description": "Post-install callback" }
  }
}
EOF
    echo "  Created events.schema.json"
  fi

  # Create CI workflow scaffold
  if [[ ! -f "${PROJECT_DIR}/.github/workflows/build.yml" ]]; then
    mkdir -p "${PROJECT_DIR}/.github/workflows"
    cat > "${PROJECT_DIR}/.github/workflows/build.yml" << 'EOF'
name: Build & Deliver Playable Ad

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install dependencies
        run: npm ci
      - name: Build web playable
        run: cocos build -p web --no-compile
      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: playable-web
          path: builds/web/
      - name: Upload to CDN
        run: ./scripts/upload-to-cdn.sh
        env:
          CDN_BUCKET: ${{ secrets.CDN_BUCKET }}
          CDN_KEY: ${{ secrets.CDN_KEY }}

  notify:
    needs: build-web
    runs-on: ubuntu-latest
    steps:
      - name: Notify team
        run: ./scripts/notify-build.sh
        env:
          SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
EOF
    echo "  Created .github/workflows/build.yml"
  fi

  echo -e "${C_GREEN}  Bootstrap done${C_RESET}"
}

trap 'log_to_team "$ROLE_NAME" "Agent shutting down"; exit 0' INT TERM

bootstrap_adops
run_agent_loop "adops-dev" \
  "tracking" "analytics" "ci" "backend" "postback" "ab-test"
