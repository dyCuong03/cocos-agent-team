# Performance Checklist — qa-tester

Every QA pass measures these and compares against `configs/project-context.md`'s
budget. Regressions vs. agentmemory baseline are filed as bugs.

## Metrics & Targets

| Metric                  | Target (mid-Android)  | How to measure                 |
|-------------------------|-----------------------|--------------------------------|
| FPS (average, 30s)      | ≥ 30                  | `debug_system` perf snapshot   |
| FPS (minimum, 30s)      | ≥ 24                  | same — watch min line          |
| Frame time spike count  | < 3 spikes >50ms in 30s | `debug_system` trace          |
| Draw calls per frame    | < 50 for UI playables | `debug_system`                 |
| Triangles per frame     | < 20k                 | `debug_system`                 |
| Bundle (initial)        | ≤ 5 MB (2 MB Meta)    | `build/` size on disk          |
| Cold load (4G)          | ≤ 5 s                 | dev-tools network throttling   |
| Memory peak             | ≤ 200 MB              | dev-tools memory tab           |
| Time-to-interactive     | ≤ 3 s                 | manual stopwatch / Lighthouse  |

## Per-Screen Checks

For every scene visited during playtest:

- [ ] FPS stays above 24 throughout
- [ ] No texture pop-in (asset loaded before scene visible)
- [ ] No audio crackle (clip not bigger than needed)
- [ ] Tween transitions complete without dropped frames
- [ ] Memory does not climb monotonically (leak indicator)
- [ ] Console has zero `WARN` or `ERROR` lines

## Device Matrix

Minimum coverage before sign-off:

| Device class    | Example                          |
|-----------------|----------------------------------|
| Low-end Android | Moto G Play / Snapdragon 4-series |
| Mid-Android     | Pixel 6a / Snapdragon 7-series   |
| Modern iPhone   | iPhone 12 or newer              |
| Older iPhone    | iPhone X / 8 (if budget allows) |

Test browsers:

- Chrome (Android default & Desktop)
- Safari (iOS default & Desktop)
- WebView (in-app browser context — what the ad SDK actually uses)

## Regression Procedure

1. `memory_recall` the prior baseline keyed `playable:{slug}:qa:perf-baseline`
2. Run the same scenes in the same order
3. Compare FPS / bundle / load — any metric off by >10% = regression
4. File the bug naming the metric, the prior value, the new value, the build hash that introduced it

## What to Do When You Find a Regression

- **FPS / memory** → probably typescript-dev (un-cleaned listener, leak)
- **Bundle size** → probably cocos-engineer (uncompressed asset, missing atlas)
- **Load time** → could be either (large asset OR async script blocking)
- **Visual glitch / pop-in** → cocos-engineer (asset preload missing)
- **Behaviour wrong** → typescript-dev (state machine bug)
- **Layout wrong** → cocos-engineer (anchor wrong) OR design (wireframe ambiguous)

Always assign exactly one role per bug. If you can't decide, file against both — but mark which you think is primary.
