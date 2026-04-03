# cocos-agent-team

> Multi-agent tmux team for **playable ad development** — from creative hook design to SDK integration, asset production, tracking, and QA.

## Quick Start

```bash
# 1. Configure your campaign
vim configs/project-context.md

# 2. Add / edit tasks
vim configs/task-board.md

# 3. Launch the team
cd ~/cocos-agent-team
./tmux/session.sh

# 4. Attach and watch
./tmux/attach.sh
```

See **[Setup.md](Setup.md)** for full documentation.

---

## The 5 Roles

| Agent | Window | Mission | Task Tags |
|-------|--------|---------|-----------|
| 🎯 `creative-dev` | `Ctrl+b 1` | Hook design, core loop, CTA, gameplay mechanics | `#creative` `#hook` `#core-loop` `#cta` |
| 🔗 `platform-dev` | `Ctrl+b 2` | Ad SDK integration, WebGL, build export | `#platform` `#sdk` `#webgl` `#build` |
| 🎨 `asset-dev` | `Ctrl+b 3` | Art, UI, VFX, end cards, icons, animations | `#asset` `#ui-design` `#vfx` `#end-card` |
| 📊 `adops-dev` | `Ctrl+b 4` | Tracking, analytics, CI/CD, backend scripts | `#tracking` `#analytics` `#ci` `#backend` |
| ✅ `qa-dev` | `Ctrl+b 5` | Playtest, perf profiling, compliance, device testing | `#qa` `#perf` `#compliance` `#playtest` |

---

## Directory Structure

```
cocos-agent-team/
├── agents/
│   ├── role-base.sh              # Shared helpers (colors, board utils, Claude runner)
│   ├── shared.sh                 # Task parsing, DM utils
│   └── roles/
│       ├── creative-dev.sh        # 🎯 Entry point
│       ├── platform-dev.sh        # 🔗 Entry point
│       ├── asset-dev.sh           # 🎨 Entry point
│       ├── adops-dev.sh           # 📊 Entry point
│       └── qa-dev.sh             # ✅ Entry point
├── configs/
│   ├── task-board.md              # Shared task board (25 pre-loaded tasks)
│   ├── project-context.md         # Campaign configuration
│   └── team-chat.md              # Inter-agent communication log
├── prompts/
│   ├── creative-dev-system.md     # 🎯 Skills + workflow
│   ├── platform-dev-system.md    # 🔗 Skills + workflow
│   ├── asset-dev-system.md        # 🎨 Skills + workflow
│   ├── adops-dev-system.md        # 📊 Skills + workflow
│   └── qa-dev-system.md          # ✅ Skills + workflow
└── tmux/
    ├── session.sh                # Launch full session
    ├── layout.conf               # Tmux styling
    └── attach.sh                 # Attach to session
```

---

## Tmux Navigation

| Key | Action |
|-----|--------|
| `Ctrl+b w` | Interactive window switcher |
| `Ctrl+b d` | Detach session |
| `Ctrl+b 0` | Dashboard |
| `Ctrl+b 1` | creative-dev |
| `Ctrl+b 2` | platform-dev |
| `Ctrl+b 3` | asset-dev |
| `Ctrl+b 4` | adops-dev |
| `Ctrl+b 5` | qa-dev |

---

## Task Board Format

```
- [ ] AD-001: [creative] Design 5-second hook #creative @creative-dev @unassigned
- [ ] AD-010: [platform] Integrate AppsFlyer SDK #platform #sdk @platform-dev @unassigned
```

Status: `[ ]` open → `[~]` in progress → `[x]` done

---

## Communication

All agents communicate via shared files:
- **Task board** → who picks up what
- **Team chat** → status updates, questions, blockers
- **Project context** → single source of truth for campaign config

Mention agents directly: `@creative-dev`, `@platform-dev`, `@asset-dev`, `@adops-dev`, `@qa-dev`
