#!/usr/bin/env bash
# =============================================================================
# asset-dev.sh — 🎨 Visual Artist & UI Designer
# Role: Art, UI design, VFX, end cards, icons, animations
# =============================================================================
set -euo pipefail

export ROLE_NAME="asset-dev"
export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-$HOME/../PlayableTemplate}"

source "${TEAM_DIR}/agents/role-base.sh"

check_prereqs
validate_team_dir

source "${TEAM_DIR}/agents/shared.sh"
validate_project_dir

# Bootstrap asset directories
bootstrap_assets() {
  banner "🎨 ASSET-DEV — Bootstrap"
  for dir in \
    "${PROJECT_DIR}/assets/art" \
    "${PROJECT_DIR}/assets/art/ui" \
    "${PROJECT_DIR}/assets/art/icons" \
    "${PROJECT_DIR}/assets/art/endcards" \
    "${PROJECT_DIR}/assets/art/vfx" \
    "${PROJECT_DIR}/assets/art/characters" \
    "${PROJECT_DIR}/assets/atlas"; do
    [[ ! -d "$dir" ]] && mkdir -p "$dir" && echo "  Created: $dir"
  done

  if [[ ! -f "${PROJECT_DIR}/assets/art/BRAND_GUIDE.md" ]]; then
    cat > "${PROJECT_DIR}/assets/art/BRAND_GUIDE.md" << 'EOF'
# Playable Ad Brand Guide

## Color Palette
| Name | Hex | Usage |
|------|-----|-------|
| Primary | #XXXXXX | Buttons, CTAs |
| Accent  | #XXXXXX | Highlights, rewards |
| BG Dark | #XXXXXX | Background |
| BG Light | #XXXXXX | Text bg |

## Typography
- Headline: [Font] — Bold — [size]px
- Body:     [Font] — Regular — [size]px
- CTA:      [Font] — Bold — [size]px

## Tap Target Spec
- Min size: 44×44px
- Safe zone: 16px from edges

## Export Specs
- Icons:   PNG 512×512 @2x, PNG-8 acceptable
- BG:      WebP or PNG-24, max 1024×1024
- VFX:     Spritesheet PNG-32 @1x
EOF
    echo "  Created BRAND_GUIDE.md"
  fi
  echo -e "${C_GREEN}  Bootstrap done${C_RESET}"
}

trap 'log_to_team "$ROLE_NAME" "Agent shutting down"; exit 0' INT TERM

bootstrap_assets
run_agent_loop "asset-dev" \
  "asset" "ui-design" "vfx" "animation" "end-card" "icons"
