# cocos-agent-team

> A 4-agent tmux team that builds **Cocos Creator 3.8.x playables** from a script + assets folder. Coordination via shared filesystem, MCP servers for engine access, agentmemory for token-efficient context.

---

## The 4 Roles

| Agent | Window | Mission | Task tags |
|-------|--------|---------|-----------|
| 🎨 `design` | `Ctrl+b 1` | Wireframes, UI/UX, interaction contracts, asset spec | `#design` `#ui` `#ux` `#wireframe` `#layout` `#flow` `#screen` |
| 🛠 `cocos-engineer` | `Ctrl+b 2` | Scenes, prefabs, components, asset import, animation, builds — Cocos Creator 3.8.x specialist | `#cocos` `#scene` `#prefab` `#editor` `#asset-import` `#anim` `#particle` `#build` |
| 💻 `typescript-dev` | `Ctrl+b 3` | All `.ts` gameplay code: state machines, input, audio, CTA | `#ts` `#typescript` `#gameplay` `#logic` `#script` `#state-machine` `#input` `#audio` |
| ✅ `qa-tester` | `Ctrl+b 4` | Playtest, perf profiling, regression, scene/asset validation, milestone sign-off | `#qa` `#test` `#perf` `#regression` `#playtest` `#release` `#signoff` `#qa-bug` |

Each role has:

- A canonical **SKILL.md** in `skills/<role>/SKILL.md` (Claude Code skill format, discoverable when this repo's `skills/` is linked into `.claude/skills/`)
- A thin **autonomous loop prompt** in `prompts/<role>-system.md` that the bash launcher uses
- A bash launcher in `agents/roles/<role>.sh`

### Shared Standards

All roles are trained on **TheOne Studio Cocos Creator Development Standards** (`skills/theone-cocos-standards/`), which enforce:

| Priority | Area | Key Rules |
|----------|------|-----------|
| 🔴 1 | Code Quality | strict mode, access modifiers, throw exceptions, no `any`, no `console.log` in production |
| 🟡 2 | Modern TypeScript | array methods, `?.` / `??`, destructuring, type guards |
| 🟢 3 | Cocos Architecture | lifecycle order, event cleanup, `@property` validation |
| 🔵 4 | Playable Performance | `<10` DrawCalls, sprite atlas, zero allocs in `update()`, `<5 MB` bundle |

- `typescript-dev` applies these standards to every component written
- `qa-tester` runs the quality/architecture/performance review checklists during QA passes
- `cocos-engineer` references the size and DrawCall optimization guides during build

---

## MCP Servers

Every role wires to two MCP servers (config in `configs/mcp-servers.json`):

1. **`cocos-creator`** — HTTP at `http://127.0.0.1:3000/mcp`, provided by [dyCuong03/cocos-mcp-server](https://github.com/dyCuong03/cocos-mcp-server). Install as a Cocos Creator extension, start from **Extension → Cocos MCP Server**. 50 tools across scene / node / component / prefab / asset / project / debug.
2. **`agentmemory`** — cross-session memory. Every role calls `memory_recall` on session start and `memory_save` after each deliverable, so context survives between runs **without** re-reading the same large docs. This is the team's token-saving lifeline.

See [Setup.md](Setup.md) for installation and wiring details.

---

## Quick Start

```bash
# 1. Bootstrap MCP servers
./scripts/bootstrap-mcp.sh

# 2. Configure your playable
$EDITOR configs/project-context.md
$EDITOR configs/playable-spec.md    # or playable-spec.json

# 3. Drop assets into your Cocos project (PROJECT_DIR)
cp -r raw-assets/* $PROJECT_DIR/assets/raw/

# 4. Launch the team
./tmux/session.sh

# 5. Attach and watch
./tmux/attach.sh
```

---

## Directory Structure

```
cocos-agent-team/
├── README.md
├── Setup.md
├── LICENSE
├── skills/                          # Claude Code skills (one per role)
│   ├── design/
│   │   ├── SKILL.md
│   │   └── references/*.md
│   ├── cocos-engineer/
│   │   ├── SKILL.md
│   │   └── references/*.md
│   ├── typescript-dev/
│   │   ├── SKILL.md
│   │   └── references/*.md
│   └── qa-tester/
│       ├── SKILL.md
│       └── references/*.md
├── prompts/                         # Autonomous-loop system prompts
│   ├── design-system.md
│   ├── cocos-engineer-system.md
│   ├── typescript-dev-system.md
│   └── qa-tester-system.md
├── agents/
│   ├── role-base.sh                 # Shared helpers + run_agent_loop
│   ├── shared.sh                    # Task parsing, DM utils
│   └── roles/
│       ├── design.sh
│       ├── cocos-engineer.sh
│       ├── typescript-dev.sh
│       └── qa-tester.sh
├── configs/
│   ├── project-context.md           # Per-playable config (fill before launch)
│   ├── project-context-template.md  # Template used by new-playable.sh
│   ├── playable-spec.md             # Markdown spec (see spec-template.md)
│   ├── playable-spec.json           # OR JSON spec (see spec-schema.json)
│   ├── spec-template.md
│   ├── spec-schema.json
│   ├── mcp-servers.json             # cocos-creator + agentmemory MCP config (never reset)
│   ├── task-board.md                # Shared task board (live)
│   ├── task-board.default.md        # Blank template — source for /new resets
│   └── team-chat.md                 # Inter-agent log
├── archive/                         # Prior-run snapshots (created by /new)
│   └── {slug}/{YYYY-MM-DD}/         # One folder per run; configs + docs preserved
├── skills/
│   └── cocos-agent-team/SKILL.md    # Orchestrator skill (install → .claude/skills/)
├── scripts/
│   ├── bootstrap-mcp.sh             # One-shot MCP setup
│   └── new-playable.sh              # Scaffold a new playable run (archives prior)
└── tmux/
    ├── session.sh
    ├── layout.conf
    └── attach.sh
```

---

## How the Team Works

1. **You** drop a playable script (`configs/playable-spec.md` or `configs/playable-spec.json`) + raw assets into the Cocos project's `assets/raw/`.
2. **`design`** parses the spec, produces wireframes in `docs/design/`, writes asset request lists, posts handoffs.
3. **`cocos-engineer`** reads wireframes, imports missing assets via the cocos-mcp-server, builds scenes/prefabs/components in the live Cocos Creator editor.
4. **`typescript-dev`** reads each wireframe's interaction contract, writes `.ts` components in `assets/scripts/`, hands the mount contract back to the engineer.
5. **`qa-tester`** builds, playtests, profiles, files bugs against specific agents, and issues PASS/FAIL.
6. **agentmemory** is the team's whiteboard — every decision, every contract, every QA verdict is saved with a compact summary so the next session doesn't re-read everything.

---

## Tmux Navigation

| Key | Action |
|-----|--------|
| `Ctrl+b w` | Interactive window switcher |
| `Ctrl+b d` | Detach |
| `Ctrl+b 0` | Dashboard |
| `Ctrl+b 1` | design |
| `Ctrl+b 2` | cocos-engineer |
| `Ctrl+b 3` | typescript-dev |
| `Ctrl+b 4` | qa-tester |

---

## Communication Protocol

| Channel | File | Purpose |
|---------|------|---------|
| Task board | `configs/task-board.md` | Who picks up what; `[ ] [~] [x]` states |
| Team chat | `configs/team-chat.md` | Status updates, questions, blockers, `@<role>` mentions |
| Project context | `configs/project-context.md` | Single source of truth for the campaign |
| Playable spec | `configs/playable-spec.{md,json}` | The brief — what to build |
| agentmemory | (MCP) | Compact decision summaries shared across all roles |

Mentions: `@design`, `@cocos-engineer`, `@typescript-dev`, `@qa-tester`.

---

## Starting a New Playable (`/new`)

```bash
# Terminal
./scripts/new-playable.sh --slug bubble-pop

# Claude Code skill
/cocos-agent-team new
```

`/new` is safe by default:
1. **Archives** the current run to `archive/{slug}/{YYYY-MM-DD}/` before touching anything
2. **Shows a manifest** of what will be archived, reset, and protected — requires confirmation
3. **Resets** only the run-specific files: `team-chat.md`, `task-board.md`, `playable-spec.md`, `project-context.md`, `docs/`
4. **Never touches** `mcp-servers.json`, `skills/`, `prompts/`, `agents/`, `scripts/`, or agentmemory

| Flag | Behavior |
|------|----------|
| `--slug <slug>` | Set new slug without interactive prompt |
| `--keep-tasks` | Skip task-board reset (preserve in-progress board) |
| `--no-archive` | Skip archive step (destructive — use only for scratch runs) |
| `--force` | Skip all confirmation prompts (for CI/automation) |
