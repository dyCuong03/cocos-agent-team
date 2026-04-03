# cocos-agent-team

> Multi-agent tmux team for autonomous Cocos Creator game development.

## Quick Start

```bash
# 1. Configure your game project
vim configs/project-context.md

# 2. Add tasks to the shared board
vim configs/task-board.md

# 3. Launch all 3 agents in tmux
./tmux/session.sh

# 4. Attach and watch
./tmux/attach.sh
```

See **[Setup.md](Setup.md)** for the full documentation.

## The 3 Roles

| Agent | Role | Picks up tasks tagged |
|-------|------|-----------------------|
| `cocos-dev` | Game features, scenes, UI, gameplay | `#feature` `#scene` `#ui` `#gameplay` `#animation` |
| `tool-dev` | Build tools, CI/CD, asset pipelines | `#tool` `#automation` `#pipeline` `#infra` `#cli` |
| `quality-dev` | Playtesting, bug reports, profiling | `#bug` `#perf` `#test` `#playtest` `#polish` `#accessibility` |

## Directory Structure

```
cocos-agent-team/
├── agents/
│   ├── role-base.sh          # Shared base (colors, paths, helpers)
│   ├── shared.sh              # Utility functions
│   └── roles/
│       ├── cocos-dev.sh       # 🏗️ Game dev agent entry point
│       ├── tool-dev.sh        # 🔧 Tool dev agent entry point
│       └── quality-dev.sh     # 🎮 Quality dev agent entry point
├── configs/
│   ├── task-board.md          # Shared task board (all agents read/write)
│   ├── project-context.md     # Game project configuration
│   └── team-chat.md           # Inter-agent communication log
├── prompts/
│   ├── cocos-dev-system.md    # 🏗️ cocos-dev skills + workflow
│   ├── tool-dev-system.md     # 🔧 tool-dev skills + workflow
│   └── quality-dev-system.md  # 🎮 quality-dev skills + workflow
├── tmux/
│   ├── session.sh             # Launch full tmux session
│   ├── layout.conf            # Tmux window/pane styling
│   └── attach.sh              # Attach to running session
└── Setup.md                   # Full documentation
```

## Tmux Navigation

| Key | Action |
|-----|--------|
| `Ctrl+b w` | Switch between windows (roles) |
| `Ctrl+b d` | Detach session |
| `Ctrl+b 0` | Go to dashboard |
| `Ctrl+b 1` | Go to cocos-dev |
| `Ctrl+b 2` | Go to tool-dev |
| `Ctrl+b 3` | Go to quality-dev |

## Communication

All agents communicate via the shared filesystem:
- **Task board:** `configs/task-board.md` — read to find work, write to update status
- **Team chat:** `configs/team-chat.md` — post status updates and questions
- **Project context:** `configs/project-context.md` — single source of truth for project state
