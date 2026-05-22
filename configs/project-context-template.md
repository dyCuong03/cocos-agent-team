# Project Context — {{title}}

The `design` agent reads this once per session and caches it via agentmemory.
Fill every `TODO` field before running `/cocos-agent-team`.

## Playable Identity

- **Project slug:** `{{slug}}`
- **Display name:** {{title}}
- **Game / Brand:** TODO
- **Cocos Creator version:** 3.8.x
- **Primary platform:** {{platform}}
- **Aspect / orientation:** {{orientation}}

## Playable Concept

- **Genre / mechanic family:** TODO
- **Hook (first 5s):** TODO
- **Core loop (5–20s):** TODO
- **Win state:** TODO
- **CTA copy:** "Install Now"
- **CTA placement:** end card only

## Brand & Visual

- **Primary color:** TODO (hex)
- **Accent color:** TODO (hex)
- **Typography:** Cocos default
- **Logo path:** TODO (or "none — use text placeholder")
- **Min tap target:** 44 × 44 px
- **Safe area:** top 80 / bottom 200 / sides 16

## Build Targets

| Platform    | Output Path           | Minify | Asset Splitting | WebGL |
|-------------|-----------------------|--------|-----------------|-------|
| Web-mobile  | `build/web-mobile/`   | yes    | no              | 2.0   |

## Perf Budget

- FPS target: ≥ {{fps_avg}} avg, ≥ {{fps_min}} min
- Bundle (initial): ≤ {{bundle_mb}} MB
- Cold load (4G): ≤ 5 s
- Peak memory: ≤ 200 MB

## Tracking / Deep-link

- **App store URL:** TODO

## Acceptance — Definition of Done

The playable is "done" when:

1. All screens in the spec exist as scenes in `assets/scenes/`
2. All interaction contracts pass qa-tester's behaviour pass
3. Bundle size ≤ {{bundle_mb}} MB
4. `validation_scene` + `validation_asset` are clean
5. qa-tester issues a PASS verdict in `docs/qa/`

## TODO before launch (agents read this list)

- [ ] Project slug confirmed: `{{slug}}`
- [ ] Brand colors filled in
- [ ] Platform + orientation confirmed
- [ ] Perf budget confirmed
- [ ] App store URL filled in
- [ ] Playable spec dropped at `configs/playable-spec.md`
- [ ] QA PASS verdict issued
