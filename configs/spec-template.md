# Playable Spec — Markdown Template

Copy this to `configs/playable-spec.md` and fill it in. The `design` agent reads
this on the first cycle and decomposes it into per-screen wireframes.

Both `playable-spec.md` (this format) and `playable-spec.json` (see
`spec-schema.json`) are valid inputs. If both are present, JSON wins.

---

## Meta

- **Project slug:** `playable-name`
- **Working title:**
- **Pitch (1 sentence):**
- **Reference playable(s):** URL or path
- **Duration target:** 15–30s

## Audience

- **Primary platform:** Google Web Ads | Meta | AppLovin | IronSource | Unity
- **Target device class:** mid-range Android (Snapdragon 6-series equivalent)
- **Orientation:** portrait | landscape
- **Aspect ratios to support:** 9:16, 16:9, etc.

## Storyboard — Scene-by-Scene

For **each** screen / scene below, include:

- **Screen ID:** `S01_hook`, `S02_core`, `S03_win`, `S04_end_card`, …
- **Goal:** one sentence
- **Duration target:** seconds
- **Visual:** what the user sees
- **Audio:** music + sfx triggers
- **Inputs:** what the user can do (tap, swipe, drag, hold, …)
- **Outputs / Feedback:** what happens when each input fires
- **Transitions:** which screen each outcome routes to
- **Acceptance criteria:** how qa-tester confirms this screen works

### S01_hook — Hook (0–5s)

- **Goal:** grab attention within 5 seconds without text
- **Duration:** 3–5 s
- **Visual:** …
- **Audio:** …
- **Inputs:** …
- **Outputs:** …
- **Transitions:** on-input → S02_core; on-timeout (5s) → S02_core with tutorial overlay
- **Acceptance:** …

### S02_core — Core Loop (5–20s)

…

### S03_win — Win State

…

### S04_end_card — End Card / CTA

…

## Assets — Provided

List everything that already exists in `${PROJECT_DIR}/assets/`. The `design`
agent will diff this against per-screen requirements to produce the asset request.

- `assets/brand/logo.png` — 256×256 transparent
- `assets/sfx/tap.wav`
- …

## Assets — Required (placeholders OK)

- HOOK background — 9:16, brand-neutral
- Player sprite — animated 4-frame idle + 4-frame action
- …

## Non-goals

What this playable **will not** include (helps the team say no to scope creep):

- No multi-language text
- No third-party SDK integration
- …
