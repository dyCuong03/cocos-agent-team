# Cocos Agent Team — Setup & Launch Guide

## Overview

This is a **multi-agent tmux team** for autonomous Cocos game development. Each agent has a dedicated role with specialized skills and tools. They communicate via a shared task board and file system.

```
cocos-agent-team/
├── agents/
│   ├── roles/
│   │   ├── cocos-dev.sh          # 🏗️ Cocos Game Dev — builds game features
│   │   ├── tool-dev.sh           # 🔧 Tool Dev — builds and maintains tooling
│   │   └── quality-dev.sh        # 🎮 Quality Dev — playtests & polishes
│   ├── shared.sh                 # Shared prompt/utility loader
│   └── role-base.sh             # Base system prompt for all roles
├── configs/
│   ├── task-board.md            # Shared task board (markdown)
│   ├── project-context.md        # Current project state snapshot
│   └── team-chat.md             # Inter-agent communication log
├── tmux/
│   ├── session.sh               # Launches full tmux session with all agents
│   ├── layout.conf              # Tmux window/pane layout definition
│   └── attach.sh                # Attach to running session
├── prompts/
│   ├── cocos-dev-system.md      # System prompt for cocos-dev
│   ├── tool-dev-system.md       # System prompt for tool-dev
│   └── quality-dev-system.md    # System prompt for quality-dev
└── README.md                    # This file
```

---

## Quick Start

### Prerequisites

```bash
# Required tools
which claude          # Claude CLI installed
which tmux            # Terminal multiplexer
which node || which bun  # For running dev servers

# Optional: Claude Code settings
ls ~/.claude/settings.json   # Global Claude Code config (optional)
```

### Step 1 — Configure Project Context

Before launching, edit `configs/project-context.md` to describe your game project:

```bash
vim configs/project-context.md
```

Minimum needed:
- **Project name** and engine version (Cocos Creator 3.x / 2.x)
- **Game type** (puzzle, RPG, arcade, etc.)
- **Entry file** (`assets/scene.fire`, `main.js`, etc.)
- **Build target** (Web / Native / Mobile)

### Step 2 — Launch the Team

```bash
cd ~/cocos-agent-team

# Option A: Launch full session (3 agents + task board)
./tmux/session.sh

# Option B: Launch individual agents manually
tmux new-session -s cocos-dev -d "bash agents/roles/cocos-dev.sh"
tmux new-session -s tool-dev  -d "bash agents/roles/tool-dev.sh"
tmux new-session -s quality-dev -d "bash agents/roles/quality-dev.sh"
```

### Step 3 — Attach and Work

```bash
# Attach to the tmux session dashboard
./tmux/attach.sh

# Or attach to a specific agent
tmux attach -t cocos-dev
```

**Tmux keybindings** (prefix = `Ctrl+b`):
| Key | Action |
|-----|--------|
| `Ctrl+b w` | Switch windows (roles) |
| `Ctrl+b d` | Detach session |
| `Ctrl+b :` | Command prompt |

---

## Role Definitions

### 🏗️ cocos-dev — Cocos Game Developer

**Mission:** Build and implement game features, scenes, mechanics, UI, and gameplay systems in Cocos Creator.

**Skills:**
- Cocos Creator 3.x TypeScript API (`cc.Component`, `@property`, `cc.Color`, etc.)
- Cocos 2D sprite, animation, physics (builtin + Box2D)
- Cocos 3D scene construction and lighting
- Prefab instantiation, scene loading, resources management
- UI System (Label, Button, Layout, ScrollView, Mask)
- Audio playback and effect management
- Shader and material authoring
- Build pipeline and asset bundling

**Task Board Tags:** `#feature`, `#scene`, `#ui`, `#gameplay`, `#animation`

---

### 🔧 tool-dev — Tool & Infrastructure Developer

**Mission:** Build and maintain development tools, build scripts, CI/CD pipelines, code generators, and asset pipelines that make the team productive.

**Skills:**
- Shell scripting (bash/zsh) for automation
- Node.js build tooling (esbuild, webpack plugins, rollup)
- Asset pipeline scripts (texture atlas, sprite sheet generation)
- CLI tool development (Commander, Inquirer)
- Git hooks and pre-commit validation
- JSON/YAML config file generation and validation
- Cocos build settings automation (`build.config.json`)
- Docker containerization for build environments

**Task Board Tags:** `#tool`, `#automation`, `#pipeline`, `#infra`, `#cli`

---

### 🎮 quality-dev — Quality & Polish Developer

**Mission:** Playtest, debug, profile performance, write tests, and ensure the game meets quality bar before release. Reports bugs and regressions.

**Skills:**
- Cocos profiling (`cc.profiler`, performance timeline)
- Memory leak detection and resource cleanup audits
- Playtesting — identifying feel issues, pacing, difficulty
- Automated UI testing via scripting
- Bug report writing with reproduction steps
- Accessibility review (touch targets, contrast, font sizes)
- Frame rate and draw call optimization
- Unit test authoring for game logic (Jest / Mocha)

**Task Board Tags:** `#bug`, `#perf`, `#test`, `#playtest`, `#polish`, `#accessibility`

---

## Communication Protocol

### Task Board (`configs/task-board.md`)

All tasks are written in the shared markdown task board:

```markdown
## Backlog
- [ ] TASK-001: [feature] Implement player movement controls #feature #cocos-dev
- [ ] TASK-002: [tool] Create sprite sheet packer CLI #tool #tool-dev

## In Progress
- [ ] TASK-003: [ui] Main menu screen layout #ui #cocos-dev @cocos-dev

## Done
- [x] TASK-000: [setup] Initialize Cocos project #setup
```

### Adding a Task

```bash
# Edit the task board
vim configs/task-board.md

# Or use the CLI (if tool-dev built it)
./scripts/add-task.sh "Implement pause menu" feature ui
```

### Agent Communication

Agents write notes to `configs/team-chat.md` when they:
- Start a task: `> [cocos-dev] Starting TASK-003`
- Finish a task: `> [cocos-dev] Done: TASK-003 — added pause menu`
- Hit a blocker: `> [cocos-dev] BLOCKED: needs sprite assets from @tool-dev`
- Have a question: `> [quality-dev] Q: Is the jump height intentional at 800px?`

---

## Adding New Roles

1. Create `agents/roles/<role>.sh`
2. Create `prompts/<role>-system.md`
3. Add a window to `tmux/layout.conf`
4. Add `tmux new-window -t cocos-team -n <role> -d "bash agents/roles/<role>.sh"` to `tmux/session.sh`
5. Restart the session: `./tmux/session.sh`

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Agent exits immediately | Check `tmux capture-pane -t <session>` for errors |
| Tasks not updating | All agents read/write `configs/task-board.md` via filesystem |
| Claude not responding | Detach (`Ctrl+b d`) and reattach `./tmux/attach.sh` |
| New agent can't find team config | Set `TEAM_DIR=~/cocos-agent-team` before launching |

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TEAM_DIR` | `~/cocos-agent-team` | Root of the team folder |
| `PROJECT_DIR` | `../PlayableTemplate` | Your Cocos game project root |
| `CLAUDE_MODEL` | `opus` | Claude model for all agents |
| `CLAUDE_MAX_TOKENS` | `4096` | Max tokens per agent response |
