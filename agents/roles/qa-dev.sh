#!/usr/bin/env bash
# =============================================================================
# qa-dev.sh — ✅ Quality Assurance & Compliance Engineer
# Role: Playtest, perf profiling, device testing, compliance review
# =============================================================================
set -euo pipefail

export ROLE_NAME="qa-dev"
export TEAM_DIR="${TEAM_DIR:-$HOME/cocos-agent-team}"
export PROJECT_DIR="${PROJECT_DIR:-$HOME/../PlayableTemplate}"

source "${TEAM_DIR}/agents/role-base.sh"

check_prereqs
validate_team_dir

source "${TEAM_DIR}/agents/shared.sh"
validate_project_dir

# Bootstrap QA infrastructure
bootstrap_qa() {
  banner "✅ QA-DEV — Bootstrap"

  for dir in \
    "${PROJECT_DIR}/tests" \
    "${PROJECT_DIR}/docs" \
    "${PROJECT_DIR}/docs/qa"; do
    [[ ! -d "$dir" ]] && mkdir -p "$dir" && echo "  Created: $dir"
  done

  # Playable ad QA checklist
  if [[ ! -f "${PROJECT_DIR}/docs/qa/pre-launch-checklist.md" ]]; then
    cat > "${PROJECT_DIR}/docs/qa/pre-launch-checklist.md" << 'EOF'
# Pre-Launch QA Checklist — Playable Ad

## Load & Performance
- [ ] Initial load ≤ 5 seconds on 4G
- [ ] Bundle size ≤ 5MB (initial load)
- [ ] FPS ≥ 30 on mid-range Android (Snapdragon 660+)
- [ ] FPS ≥ 30 on iPhone 8 / SE (2017)
- [ ] No memory leaks after 3 min continuous play
- [ ] WebGL context created without errors
- [ ] No 404 resources

## Gameplay
- [ ] Hook plays within 2 seconds of load
- [ ] Core mechanic understood without text/tutorial
- [ ] All tap/swipe interactions responsive (< 16ms)
- [ ] Reward/feedback on every action
- [ ] Game winnable / completable
- [ ] No soft-locks or infinite loops

## Tracking Verification
- [ ] AppsFlyer / Adjust events firing in SDK debug mode
- [ ] All events in events.schema.json mapped
- [ ] `cta_clicked` fires on button tap
- [ ] `ad_complete` fires on session end
- [ ] No duplicate events on scene reload

## CTA & End Card
- [ ] CTA button ≥ 44×44px
- [ ] CTA contrast ratio ≥ 4.5:1
- [ ] CTA copy matches platform requirements
- [ ] End card displays correctly at all aspect ratios
- [ ] Store logo / icon visible on end card

## Compliance
- [ ] Google AWV policy: no violence, gambling, misleading claims
- [ ] Meta creative: brand safety, prohibited content check
- [ ] AppLovin MAX: no incentive-to-install language
- [ ] No personal data collected without consent
- [ ] Age gate if applicable (13+ / 18+)

## Browser / OS Matrix
| Device | OS | Browser | Expected FPS |
|--------|----|---------|-------------|
| Pixel 4 | Android 12 | Chrome | ≥ 55 |
| Galaxy S10 | Android 11 | Chrome | ≥ 50 |
| iPhone 12 | iOS 16 | Safari | ≥ 55 |
| iPhone 8 | iOS 15 | Safari | ≥ 30 |
| Desktop | Win 10 | Chrome | ≥ 60 |

## Accessibility
- [ ] Font size ≥ 16px
- [ ] Tap targets ≥ 44×44px
- [ ] No color-only indicators
- [ ] No flashing content > 3Hz

## Deliverables
- [ ] Build artifact uploaded to CDN
- [ ] Test report in docs/qa/playtest-report.md
- [ ] Performance report in docs/qa/perf-report.md
- [ ] Tracking verification report in docs/qa/tracking-report.md
- [ ] Creative benchmark in docs/qa/creative-benchmark.md
EOF
    echo "  Created pre-launch-checklist.md"
  fi

  # Bug report template
  if [[ ! -f "${PROJECT_DIR}/docs/qa/bug-template.md" ]]; then
    cat > "${PROJECT_DIR}/docs/qa/bug-template.md" << 'EOF'
# QA Bug Report — [AD-XXX] Short Title

## Severity
- [ ] P0 — Critical (ad won't load / crash)
- [ ] P1 — Major (tracking broken / CTA non-functional)
- [ ] P2 — Minor (visual glitch / minor perf drop)
- [ ] P3 — Cosmetic (spacing, font, color off)

## Summary
One sentence describing the issue.

## Steps to Reproduce
1. Load playable ad at [URL]
2. ...
3. Observe: ...

## Expected / Actual
**Expected:** ...
**Actual:** ...

## Environment
- Device: ...
- OS: ...
- Browser: ...
- Build: [hash or URL]
- Network: 4G / WiFi

## Screenshots / Screen Recording
[Attach]

## Tracking Impact
Does this affect event tracking? Yes / No / Unknown

## Suggested Fix
(If obvious)
EOF
    echo "  Created bug-template.md"
  fi

  echo -e "${C_GREEN}  Bootstrap done${C_RESET}"
}

trap 'log_to_team "$ROLE_NAME" "Agent shutting down"; exit 0' INT TERM

bootstrap_qa
run_agent_loop "qa-dev" \
  "qa" "perf" "test" "compliance" "playtest" "device-test"
