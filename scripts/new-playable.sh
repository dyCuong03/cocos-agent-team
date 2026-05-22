#!/usr/bin/env bash
# =============================================================================
# new-playable.sh — Scaffold a fresh playable run.
#
#   Archives the prior run (configs + docs/) before resetting the workspace.
#   Templates (skills/, prompts/, agents/, configs/mcp-servers.json) are
#   NEVER touched.
#
#   Options:
#     --slug <slug>    New project slug (prompted if omitted)
#     --keep-tasks     Preserve task-board.md (skip reset)
#     --no-archive     Skip archive step (destructive — use only for scratch runs)
#     --force          Skip all confirmation prompts
#     -h|--help
# =============================================================================
set -euo pipefail

TEAM_DIR="${TEAM_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

C_RESET='\033[0m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_DIM='\033[2m'

KEEP_TASKS=0
FORCE=0
NO_ARCHIVE=0
NEW_SLUG=""

# ── Parse args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --keep-tasks)  KEEP_TASKS=1 ;;
    --force)       FORCE=1 ;;
    --no-archive)  NO_ARCHIVE=1 ;;
    --slug)        shift; NEW_SLUG="${1:-}" ;;
    -h|--help)
      echo "Usage: $0 [--slug <slug>] [--keep-tasks] [--no-archive] [--force]"
      echo "  --slug <slug>   New project slug, kebab-case (prompted if omitted)"
      echo "  --keep-tasks    Preserve current task-board.md (skip reset)"
      echo "  --no-archive    Skip archiving prior run (destructive)"
      echo "  --force         Skip all confirmation prompts"
      exit 0
      ;;
    *) echo -e "${C_RED}Unknown option: $1${C_RESET}" >&2; exit 1 ;;
  esac
  shift
done

echo -e "${C_BOLD}=== New Playable — cocos-agent-team ===${C_RESET}"
echo -e "${C_DIM}  TEAM_DIR = ${TEAM_DIR}${C_RESET}"
echo ""

# ── 0. Read current slug from project-context.md ──────────────────────────────
PRIOR_SLUG=""
CTX_FILE="${TEAM_DIR}/configs/project-context.md"
if [[ -f "$CTX_FILE" ]]; then
  PRIOR_SLUG=$(grep -oP "(?<=Project slug:\*\* \`)[^\`]+" "$CTX_FILE" 2>/dev/null || true)
fi

# ── 1. Get and validate new slug ──────────────────────────────────────────────
if [[ -z "$NEW_SLUG" ]]; then
  read -r -p "New project slug (kebab-case, e.g. bubble-pop): " NEW_SLUG
fi
if [[ -z "$NEW_SLUG" ]]; then
  echo -e "${C_RED}Error: slug is required.${C_RESET}" >&2; exit 1
fi
if ! echo "$NEW_SLUG" | grep -qP '^[a-z0-9]+(-[a-z0-9]+)*$'; then
  echo -e "${C_RED}Error: slug must be lowercase kebab-case (letters, digits, hyphens only).${C_RESET}" >&2
  exit 1
fi

# ── 2. Count archive-able artifacts ──────────────────────────────────────────
N_DESIGN=0; N_QA=0
if [[ -d "${TEAM_DIR}/docs/design" ]]; then
  N_DESIGN=$(find "${TEAM_DIR}/docs/design" -maxdepth 1 -type f 2>/dev/null | wc -l)
fi
if [[ -d "${TEAM_DIR}/docs/qa" ]]; then
  N_QA=$(find "${TEAM_DIR}/docs/qa" -maxdepth 1 -type f 2>/dev/null | wc -l)
fi
HAS_PRIOR=0
[[ -n "$PRIOR_SLUG" ]] && HAS_PRIOR=1
ARCHIVE_DATE=$(date +%Y-%m-%d)

# ── 3. Show manifest and confirm ──────────────────────────────────────────────
if (( FORCE == 0 )); then
  echo -e "${C_BOLD}┌── Reset Manifest ────────────────────────────────────────────┐${C_RESET}"
  echo -e "│  New playable : ${C_GREEN}${NEW_SLUG}${C_RESET}"
  if (( HAS_PRIOR == 1 )); then
    echo -e "│  Replacing    : ${C_YELLOW}${PRIOR_SLUG}${C_RESET}"
  fi
  echo -e "${C_BOLD}├── ARCHIVE ───────────────────────────────────────────────────┤${C_RESET}"
  if (( NO_ARCHIVE == 1 )); then
    echo -e "│  ${C_RED}--no-archive set: prior run will NOT be archived${C_RESET}"
  elif (( HAS_PRIOR == 1 )); then
    echo -e "│  Destination: archive/${PRIOR_SLUG}/${ARCHIVE_DATE}/"
    for f in team-chat.md task-board.md playable-spec.md playable-spec.json project-context.md; do
      [[ -f "${TEAM_DIR}/configs/${f}" ]] && echo "│    ✦ configs/${f}"
    done
    echo "│    ✦ docs/design/  (${N_DESIGN} files)"
    echo "│    ✦ docs/qa/      (${N_QA} files)"
  else
    echo "│  (no prior run detected — nothing to archive)"
  fi
  echo -e "${C_BOLD}├── RESET ─────────────────────────────────────────────────────┤${C_RESET}"
  echo "│    ↺ configs/team-chat.md       → system header"
  if (( KEEP_TASKS == 0 )); then
    echo "│    ↺ configs/task-board.md      → blank backlog"
  else
    echo "│    — configs/task-board.md      (--keep-tasks: preserved)"
  fi
  echo "│    ↺ configs/playable-spec.md   → spec template"
  echo "│    ↺ configs/project-context.md → ${NEW_SLUG} stub"
  echo "│    ↺ docs/design/ + docs/qa/    → empty"
  echo -e "${C_BOLD}├── PROTECTED (never touched) ────────────────────────────────┤${C_RESET}"
  echo "│    ✓ configs/mcp-servers.json"
  echo "│    ✓ skills/  (all role skills + theone-cocos-standards)"
  echo "│    ✓ prompts/ · agents/ · scripts/"
  echo "│    ✓ agentmemory  (slug-namespaced — old keys stay intact)"
  echo -e "${C_BOLD}└──────────────────────────────────────────────────────────────┘${C_RESET}"
  echo ""
  read -r -p "Proceed? [y/N] " ans
  [[ "$ans" =~ ^[yY]$ ]] || { echo "Aborted. Nothing changed."; exit 0; }
  echo ""
fi

# ── 4. Archive prior run ──────────────────────────────────────────────────────
if (( NO_ARCHIVE == 0 )) && (( HAS_PRIOR == 1 )); then
  ARCHIVE_BASE="${TEAM_DIR}/archive/${PRIOR_SLUG}/${ARCHIVE_DATE}"
  ARCHIVE_DIR="$ARCHIVE_BASE"
  N_SUFFIX=0
  while [[ -d "$ARCHIVE_DIR" ]]; do
    N_SUFFIX=$(( N_SUFFIX + 1 ))
    ARCHIVE_DIR="${ARCHIVE_BASE}-${N_SUFFIX}"
  done

  mkdir -p "${ARCHIVE_DIR}/configs" "${ARCHIVE_DIR}/docs/design" "${ARCHIVE_DIR}/docs/qa"

  for f in team-chat.md task-board.md playable-spec.md playable-spec.json project-context.md; do
    src="${TEAM_DIR}/configs/${f}"
    if [[ -f "$src" ]]; then
      cp "$src" "${ARCHIVE_DIR}/configs/${f}"
      echo -e "  ${C_GREEN}✦${C_RESET} archived configs/${f}"
    fi
  done

  for d in docs/design docs/qa; do
    src="${TEAM_DIR}/${d}"
    if [[ -d "$src" ]] && [[ -n "$(ls -A "$src" 2>/dev/null)" ]]; then
      cp -r "$src/." "${ARCHIVE_DIR}/${d}/"
      echo -e "  ${C_GREEN}✦${C_RESET} archived ${d}/ ($(ls "$src" | wc -l | tr -d ' ') files)"
    fi
  done

  echo -e "${C_GREEN}✓${C_RESET} Archived to archive/${PRIOR_SLUG}/$(basename "$ARCHIVE_DIR")/"
  echo ""
fi

# ── 5. Reset team-chat ────────────────────────────────────────────────────────
cat > "${TEAM_DIR}/configs/team-chat.md" <<'HEREDOC'
# Team Chat — cocos-agent-team

Format: `> [YYYY-MM-DD HH:MM] [role] message`

Mentions: `@design` `@cocos-engineer` `@typescript-dev` `@qa-tester`

---

> [SYSTEM] cocos-playable team initialized
> [SYSTEM] Edit configs/project-context.md and configs/playable-spec.{md,json} before launch
> [SYSTEM] 4 roles: 🎨 design  🛠 cocos-engineer  💻 typescript-dev  ✅ qa-tester
HEREDOC
echo -e "${C_GREEN}✓${C_RESET} reset configs/team-chat.md"

# ── 6. Task board ─────────────────────────────────────────────────────────────
if (( KEEP_TASKS == 0 )); then
  DEFAULT_TB="${TEAM_DIR}/configs/task-board.default.md"
  if [[ -f "$DEFAULT_TB" ]]; then
    sed "s/{{slug}}/${NEW_SLUG}/g" "$DEFAULT_TB" > "${TEAM_DIR}/configs/task-board.md"
    echo -e "${C_GREEN}✓${C_RESET} reset configs/task-board.md from task-board.default.md"
  else
    # Minimal inline fallback (task-board.default.md missing)
    cat > "${TEAM_DIR}/configs/task-board.md" <<HEREDOC
# Cocos Playable Team — Task Board
# Project: ${NEW_SLUG}

Format: \`- [ ] PB-NNN: [type] Description #tag1 #tag2 @role\`
Status:  \`[ ]\` open → \`[~]\` in progress → \`[x]\` done.

---

## 🎨 Design Backlog

---

## 🛠 Cocos Engineer Backlog

---

## 💻 TypeScript Backlog

---

## ✅ QA Backlog

---

## In Progress

---

## Done

---

## QA-Filed Bugs
HEREDOC
    echo -e "${C_YELLOW}-${C_RESET} task-board.default.md missing; wrote minimal fallback"
  fi
fi

# ── 7. Playable spec (always reset — old spec is archived) ────────────────────
SPEC_TEMPLATE="${TEAM_DIR}/configs/spec-template.md"
if [[ -f "$SPEC_TEMPLATE" ]]; then
  cp "$SPEC_TEMPLATE" "${TEAM_DIR}/configs/playable-spec.md"
  rm -f "${TEAM_DIR}/configs/playable-spec.json"
  echo -e "${C_GREEN}✓${C_RESET} reset configs/playable-spec.md from template"
  echo -e "${C_YELLOW}  → Edit configs/playable-spec.md before launching${C_RESET}"
else
  echo -e "${C_YELLOW}-${C_RESET} spec-template.md missing; skipping spec reset"
fi

# ── 8. Project context ────────────────────────────────────────────────────────
CTX_TEMPLATE="${TEAM_DIR}/configs/project-context-template.md"
CTX_OUT="${TEAM_DIR}/configs/project-context.md"
if [[ -f "$CTX_TEMPLATE" ]]; then
  sed "s/{{slug}}/${NEW_SLUG}/g
       s/{{title}}/${NEW_SLUG}/g
       s/{{platform}}/TODO/g
       s/{{orientation}}/portrait/g
       s/{{bundle_mb}}/5/g
       s/{{fps_avg}}/30/g
       s/{{fps_min}}/24/g" "$CTX_TEMPLATE" > "$CTX_OUT"
  echo -e "${C_GREEN}✓${C_RESET} wrote configs/project-context.md from template"
  echo -e "${C_YELLOW}  → Fill in platform, brand, perf budget, CTA URL${C_RESET}"
else
  cat > "$CTX_OUT" <<HEREDOC
# Project Context — ${NEW_SLUG}

- **Project slug:** \`${NEW_SLUG}\`
- **Cocos Creator version:** 3.8.x
- **TODO:** fill in primary platform, orientation, bundle budget, brand colors, app store URL
HEREDOC
  echo -e "${C_GREEN}✓${C_RESET} wrote minimal configs/project-context.md (fill in TODO fields)"
fi

# ── 9. Clear docs/ ────────────────────────────────────────────────────────────
rm -rf "${TEAM_DIR}/docs/design" "${TEAM_DIR}/docs/qa"
mkdir -p "${TEAM_DIR}/docs/design" "${TEAM_DIR}/docs/qa"
echo -e "${C_GREEN}✓${C_RESET} cleared docs/design/ and docs/qa/"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${C_GREEN}${C_BOLD}Ready for '${NEW_SLUG}'.${C_RESET}"
if (( NO_ARCHIVE == 0 )) && (( HAS_PRIOR == 1 )); then
  echo -e "${C_DIM}  Prior run archived → archive/${PRIOR_SLUG}/$(basename "$ARCHIVE_DIR")/${C_RESET}"
fi
echo ""
echo "Next:"
echo "  1. Edit configs/project-context.md  (platform, brand, perf budget, CTA URL)"
echo "  2. Edit configs/playable-spec.md    (storyboard, acceptance criteria)"
echo "  3. Drop raw assets → \$PROJECT_DIR/assets/raw/"
echo "  4. ./scripts/bootstrap-mcp.sh      (if MCP needs re-wiring)"
echo "  5. Run /cocos-agent-team            (launches the pipeline)"
