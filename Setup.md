# cocos-agent-team — Setup & Launch Guide

A multi-agent tmux team for Cocos Creator 3.8.x playable development. Roles:
**design**, **cocos-engineer**, **typescript-dev**, **qa-tester**. Wired to
the `cocos-mcp-server` and `agentmemory` MCP servers.

---

## Quick Start (one command)

```bash
./setup.sh
```

This single script does everything in §1–§2 below **plus** installs the four
playable skills (`/cocos-playable-design`, `/cocos-playable-engineer`,
`/cocos-playable-typescript`, `/cocos-playable-qa`) into `~/.claude/skills/`
so they are available as slash commands in **any** Claude Code project on this
machine, not just this repo.

If your Cocos project lives outside this repo:

```bash
./setup.sh --project-dir /path/to/your/cocos-project
# or
PROJECT_DIR=/path/to/your/cocos-project ./setup.sh
```

After `setup.sh` completes, skip to §3 (Configure the Playable).

---

## 0. Prerequisites

- **Cocos Creator 3.8.x** (3.8.6+ recommended) with a project at `${PROJECT_DIR}`
- **claude CLI** in `$PATH` ([install guide](https://docs.claude.com/en/docs/claude-code/setup))
- **tmux** (Linux/macOS native; Windows via Git Bash + tmux package or WSL)
- **Node.js + npx** (for the `agentmemory` MCP server)
- **curl** (for the role-base.sh MCP pre-flight check)

---

## 1. Install the Cocos MCP Server

This server is the engine-side bridge — every role calls it for scene/node/component/prefab/asset operations.

```bash
# 1a. Clone the server into your Cocos project's extensions/
cd "$PROJECT_DIR/extensions"
git clone https://github.com/dyCuong03/cocos-mcp-server.git
cd cocos-mcp-server
npm install
npm run build

# 1b. Restart Cocos Creator
# 1c. In the Cocos Creator editor:
#       Extension menu → Cocos MCP Server → Start
#     Confirm it's listening on port 3000 (configurable in the panel)
```

Verify with:

```bash
curl -v -X POST http://127.0.0.1:3000/mcp
# Should return 200 or a JSON-RPC envelope (not Connection refused)
```

If you remap the port, update `configs/mcp-servers.json` to match.

---

## 2. Register MCP Servers with the claude CLI

You have two options.

### Option A — Per-project (used automatically by every role)

The role bash scripts pass `--mcp-config configs/mcp-servers.json` to every `claude` invocation. Nothing extra to do once Cocos MCP is running.

### Option B — Global (so `claude` from any terminal sees them)

```bash
claude mcp add --transport http cocos-creator http://127.0.0.1:3000/mcp
claude mcp add agentmemory npx -- -y @agentmemory/mcp-server
```

(Adjust the agentmemory command to match your local install — see your agentmemory package's README.)

---

## 3. Configure the Playable

Edit two files:

```bash
$EDITOR configs/project-context.md     # bundle budget, brand, targets, perf budget
$EDITOR configs/playable-spec.md       # the storyboard / script (or use playable-spec.json)
```

If you prefer JSON, follow `configs/spec-schema.json` and write `configs/playable-spec.json` instead — JSON wins over markdown when both are present.

Drop raw assets into your Cocos project (typically under `assets/raw/` or the directory `design`'s asset request points at — `cocos-engineer` imports them via `asset_manage` MCP tool).

---

## 4. Launch the Team

```bash
./tmux/session.sh
./tmux/attach.sh
```

Tmux shortcuts:

| Key | Action |
|-----|--------|
| `Ctrl+b w` | Window switcher |
| `Ctrl+b d` | Detach (team keeps running) |
| `Ctrl+b 0–4` | Jump to window |

Each window starts its role's autonomous loop. Roles poll `configs/task-board.md`, claim matching tasks, and execute.

---

## 5. The Communication Protocol

### Task board — `configs/task-board.md`

```
- [ ] PB-001: [design] Wireframe HOOK screen #design #wireframe @design @unassigned
- [~] PB-012: [cocos] Build HOOK scene from wireframe #cocos #scene @cocos-engineer
- [x] PB-002: [design] Wireframe CORE LOOP #design @design
```

- `[ ]` open → `[~]` in progress → `[x]` done
- Tags route tasks to roles (see `agents/roles/<role>.sh` for the tag list)
- `@unassigned` → first matching agent claims it

### Team chat — `configs/team-chat.md`

```
> [2026-05-21 14:02] [design] Hook wireframe ready in docs/design/02-hook.md @cocos-engineer
> [2026-05-21 14:08] [cocos-engineer] HOOK scene built, mounted SwipeHook.ts @qa-tester
> [2026-05-21 14:30] [qa-tester] QA FAIL — bundle 6.1MB > budget. Filed PB-501 @cocos-engineer
```

### agentmemory — cross-session whiteboard

Every role calls `memory_recall` on startup and `memory_save` after each deliverable. Keys are namespaced by playable slug + role:

```
playable:my-playable:design:S01_hook
playable:my-playable:engineer:HookScene
playable:my-playable:typescript:SwipeHook
playable:my-playable:qa:milestone-1
```

This is what makes the team **token-efficient** across long-running campaigns — you don't pay the cost of re-reading `playable-spec.md` and every wireframe on every session.

---

## 6. Adding or Modifying a Role

1. **Skill file** — `skills/<new-role>/SKILL.md` (follow the existing 4 as templates)
2. **System prompt** — `prompts/<new-role>-system.md` (autonomous-loop wrapper)
3. **Bash launcher** — `agents/roles/<new-role>.sh` (call `run_agent_loop` with tag list)
4. **tmux window** — add a `new-window` block to `tmux/session.sh`
5. Restart: `./tmux/session.sh`

---

## 7. Troubleshooting

| Symptom | Fix |
|---------|-----|
| Role exits immediately | `tmux capture-pane -t <session>:<window>` to read the stderr |
| `WARN: cocos-mcp-server not reachable` | Open Cocos Creator → Extension → Cocos MCP Server → Start; verify port 3000 with `curl` |
| Roles all claim the same task | A `sed` race on the board — fix manually, then ensure only one tmux session is active |
| `agentmemory` errors on first call | Check `configs/mcp-servers.json` command/args match your local install; check `claude mcp list` |
| `claude: command not found` | Install Claude CLI, ensure it's on `$PATH` in the tmux shell |
| Tasks stuck `[~]` after restart | Manually rewind `[~] → [ ]` and clear `@<role>` back to `@unassigned` |
| Build fails inside Cocos | The engineer's bash output will surface the Cocos console errors; `debug_console` MCP tool also dumps them |

---

## 8. Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `TEAM_DIR` | `$HOME/cocos-agent-team` | Repo root |
| `PROJECT_DIR` | `${TEAM_DIR}/..` | Cocos project root |
| `SESSION_NAME` | `cocos-playable-team` | tmux session name |
| `CLAUDE_MODEL` | `opus` | Claude model passed to the CLI |
| `CLAUDE_MAX_TOKENS` | `4096` | Per-turn cap |

---

## 9. Windows Notes

The bash scripts assume a POSIX shell. On Windows:

- Use **Git Bash** (ships with Git for Windows) and `tmux` from MSYS2, **or** run inside WSL2.
- Paths in `configs/*.json` use forward slashes; the bash scripts already export `PROJECT_DIR` to work either way.
- `sed -i` on Windows Git Bash works in-place without a backup arg.
