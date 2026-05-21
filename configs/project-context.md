# Project Context — Cocos Playable Configuration

Fill this in **before launching the team**. Every agent reads this once per session
and caches it via agentmemory. Leaving placeholders here means the agents will
keep asking — or worse, guessing.

## Playable Identity

- **Project slug:** `playable-name`  *(short, lower-kebab — used as agentmemory key prefix)*
- **Display name:** Playable Display Name
- **Game / Brand:** What game does this playable advertise / showcase
- **Cocos Creator version:** 3.8.x  *(pin the exact patch in `.cocos-version`)*
- **Primary platform:** Google Web Ads | Meta Audience Network | AppLovin | IronSource | Unity Ads | Standalone
- **Aspect / orientation:** portrait (9:16) | landscape (16:9) | both

## Playable Concept

- **Genre / mechanic family:** match-3 | runner | puzzle | shooter | hyper-casual | sim
- **Hook (first 5s):** what action does the user take in the opening
- **Core loop (5–20s):** the repeating action
- **Win state:** what "winning" looks like
- **CTA copy:** primary install/download text
- **CTA placement:** on-win | timeout | both

## Brand & Visual

- **Primary color:** `#XXXXXX`
- **Accent color:** `#XXXXXX`
- **Typography:** font family + weights
- **Logo path:** `assets/brand/logo.png`
- **Min tap target:** 44 × 44 px
- **Safe area:** define top/bottom/left/right insets

## Build Targets

| Platform     | Output Path           | Minify | Asset Splitting | WebGL |
|--------------|-----------------------|--------|-----------------|-------|
| Web-mobile   | `build/web-mobile/`   | yes    | yes             | 2.0   |
| Web-desktop  | `build/web-desktop/`  | yes    | yes             | 2.0   |

## Perf Budget (qa-tester enforces)

- **FPS target (mid-range Android):** ≥ 30 avg, ≥ 24 min
- **Bundle (initial load):** ≤ 5 MB
- **Per-bundle cap:** ≤ 1 MB
- **Cold load on 4G:** ≤ 5 s
- **Peak memory:** ≤ 200 MB

## Tracking / Deep-link (if applicable)

- **App store URL (iOS):**
- **App store URL (Android):**
- **AppsFlyer / Adjust / Branch:** (optional — fill if tracking is in scope)

## Acceptance — Definition of Done

A playable is "done" when:

1. Every screen named in `configs/playable-spec.{md|json}` has a matching wireframe in `docs/design/` and built scene/prefab in `assets/scenes/`
2. Every interaction-contract row passes qa-tester's behaviour pass
3. Perf budget above is met on the qa-tester's test device matrix
4. `validation_scene` + `validation_asset` are clean
5. qa-tester has issued an explicit PASS verdict in `docs/qa/`

## Reference Playables (optional)

- URL: …
- What works: …

---

## TODO before launch

- [ ] Set the project slug
- [ ] Fill brand colors + logo
- [ ] Decide platform + orientation
- [ ] Confirm perf budget with stakeholders
- [ ] Drop the playable spec into `configs/playable-spec.md` or `configs/playable-spec.json`
- [ ] Drop reference / brand assets into `${PROJECT_DIR}/assets/`
