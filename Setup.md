# Cocos Playable Ad Agent Team — Setup & Launch Guide

## Overview

A **multi-agent tmux team** for autonomous playable ad development. Each agent owns a specialized domain — from gameplay hook design to SDK integration to compliance. They coordinate via a shared filesystem task board and team chat.

```
cocos-agent-team/
├── agents/
│   ├── role-base.sh              # Shared helpers (colors, paths, board utils)
│   ├── shared.sh                 # Task parsing, agent messaging
│   └── roles/
│       ├── creative-dev.sh        # 🎯 Hook design, core loop, gameplay mechanics
│       ├── platform-dev.sh        # 🔗 SDK integration, WebGL, build export
│       ├── asset-dev.sh           # 🎨 Art, UI, VFX, end cards
│       ├── adops-dev.sh           # 📊 Tracking, CI/CD, backend scripts
│       └── qa-dev.sh             # ✅ Playtest, perf, compliance testing
├── configs/
│   ├── task-board.md             # Shared task board
│   ├── project-context.md         # Ad campaign configuration
│   └── team-chat.md              # Inter-agent communication log
├── prompts/
│   ├── creative-dev-system.md     # 🎯 creative-dev skills + workflow
│   ├── platform-dev-system.md    # 🔗 platform-dev skills + workflow
│   ├── asset-dev-system.md        # 🎨 asset-dev skills + workflow
│   ├── adops-dev-system.md        # 📊 adops-dev skills + workflow
│   └── qa-dev-system.md           # ✅ qa-dev skills + workflow
├── tmux/
│   ├── session.sh                # Launch full tmux session
│   ├── layout.conf               # Tmux window/pane styling
│   └── attach.sh                 # Attach to running session
└── README.md
```

---

## The 5 Roles

### 🎯 creative-dev — Playable Ad Creative Designer

**Mission:** Design the hook, core loop, pacing, CTA, and gameplay mechanics that make the ad compelling and conversion-focused.

**Skills:**
- Playable ad psychology (AARRR funnel, hook model)
- Rapid onboarding loop design (first 5 seconds)
- Core mechanic prototyping in Cocos
- CTA placement and end-card flow
- Conversion event design (install, signup, purchase)
- Game feel: juicy feedback, micro-rewards, dopamine hits
- Mobile UX: tap/swipe/drag interactions

**Task Tags:** `#creative` `#gameplay-design` `#hook` `#core-loop` `#cta`

---

### 🔗 platform-dev — SDK Integration & Build Engineer

**Mission:** Integrate ad platform SDKs (Google Play Games, AppLovin, Meta, Unity Ads), handle WebGL export, platform-specific build quirks, and device compatibility.

**Skills:**
- Ad SDK integration: Google Play Install Referrer, AppLovin MAX, Meta Audience Network, Unity Ads, ironSource
- WebGL 2.0 / WebGL 1.0 compatibility
- Cocos Creator build pipeline (`cocos build`, `--no-compile`)
- Cross-platform JS bridging (native ↔ JS)
- Minification, code splitting, bundle size optimization
- Device compatibility matrix (Android, iOS, Huawei)
- Memory budget enforcement (<5MB initial load)

**Task Tags:** `#platform` `#sdk` `#integration` `#webgl` `#build`

---

### 🎨 asset-dev — Visual Artist & UI Designer

**Mission:** Produce all visual assets — hero art, icons, UI elements, VFX, end cards, and brand-consistent graphics that drive click-through and install rates.

**Skills:**
- Vector illustration (SVG → PNG export)
- Sprite sheet and atlas creation (TexturePacker CLI)
- Lottie / DOTween animation for UI micro-interactions
- End card design (store screenshot, CTA button, logo)
- Iconography (material icons, custom game icons)
- VFX: particle systems, screen flashes, pop-in animations
- Font subsetting for bundle size
- Image optimization (WebP, PNG-8 with alpha, tinypng)
- Dark/light theme asset variants

**Task Tags:** `#asset` `#ui-design` `#vfx` `#animation` `#end-card` `#icons`

---

### 📊 adops-dev — Tracking, Analytics & CI/CD Engineer

**Mission:** Implement tracking events, analytics pipelines, CI/CD automation, backend scripts for server-side events, and build delivery workflows.

**Skills:**
- Tracking implementation: AppsFlyer, Adjust, Branch, Firebase Analytics
- Server-side postback scripts (Node.js, Python)
- Google Tag Manager / dataLayer events
- GitHub Actions CI/CD (build → upload → notify)
- S3 / Google Cloud Storage upload pipelines
- Build versioning and changelog automation
- CSV/JSON report generation from analytics data
- Playable ad delivery APIs (doubleVerify, IAS brand safety)
- A/B test event schema design
- Docker build environments for reproducible builds

**Task Tags:** `#tracking` `#analytics` `#ci` `#backend` `#postback` `#ab-test`

---

### ✅ qa-dev — Quality Assurance & Compliance Engineer

**Mission:** Playtest the playable ad, profile performance, validate tracking, test across devices/browsers, and ensure compliance with ad platform policies.

**Skills:**
- Playable ad playtesting: hook retention, CTA conversion, play duration
- Performance profiling: FPS, memory, load time, WebGL stats
- Device matrix testing (Android 8–14, iOS 14–17, Chrome/Safari/Firefox)
- Ad policy compliance: Google AWV policy, Meta creative guidelines
- Tracking verification: AppsFlyer SDK debug mode, Charles Proxy
- Accessibility review: tap targets ≥ 44px, contrast ≥ 4.5:1
- Crash reporting integration (Firebase Crashlytics)
- Pre-launch QA checklist sign-off
- Regression testing after SDK / asset updates
- Competitive creative audit (benchmark against top playable ads)

**Task Tags:** `#qa` `#perf` `#test` `#compliance` `#playtest` `#device-test`

---

## Quick Start

### 1. Configure the campaign

```bash
vim configs/project-context.md
```

Fill in: game name, brand guidelines, CTA copy, target platforms, tracking IDs, bundle size budget.

### 2. Add tasks

```bash
vim configs/task-board.md
```

Tasks use this format:
```markdown
- [ ] AD-001: [creative] Design 5-second hook with swipe mechanic #creative @creative-dev @unassigned
```

### 3. Launch the team

```bash
cd ~/cocos-agent-team
./tmux/session.sh
```

### 4. Attach and watch

```bash
./tmux/attach.sh
```

**Tmux shortcuts:**
| Key | Action |
|-----|--------|
| `Ctrl+b w` | Switch windows (roles) |
| `Ctrl+b d` | Detach session |
| `Ctrl+b 0–4` | Jump to window |

---

## Communication Protocol

### Task Board (`configs/task-board.md`)

All tasks tracked here. Format:
```
- [ ] AD-001: [type] Description #tag1 #tag2 @role @unassigned
```

Status markers:
- `[ ]` = open
- `[~]` = in progress (agent marks this)
- `[x]` = done

### Team Chat (`configs/team-chat.md`)

Agents post here with `@role` mentions:
```
> [creative-dev] Hook v1 done — moving to CTA integration @platform-dev
> [adops-dev] BLOCKED: Need AppsFlyer key from @creative-dev
> [qa-dev] Perf audit: Load time 4.2s — needs optimization @platform-dev
```

---

## Adding a New Role

1. `agents/roles/<new-role>.sh` — entry point script
2. `prompts/<new-role>-system.md` — system prompt
3. Add window to `tmux/session.sh`
4. Restart: `./tmux/session.sh`

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TEAM_DIR` | `~/cocos-agent-team` | Team root |
| `PROJECT_DIR` | `../PlayableTemplate` | Ad project root |
| `CLAUDE_MODEL` | `opus` | Claude model |
| `CLAUDE_MAX_TOKENS` | `4096` | Max tokens per turn |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Agent exits | `tmux capture-pane -t <window>` to see error |
| Tasks stuck | Check `configs/task-board.md` — remove stale `@role` locks |
| Remote push fails | `eval $(ssh-agent)` then `ssh-add ~/.ssh/id_ed25519_personal` |
| Claude not found | Ensure `claude` CLI is in PATH |
