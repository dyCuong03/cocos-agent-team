# Build & Bundle Cheatsheet — Cocos Engineer

## Targets & Sizes

| Platform        | Output           | Initial-load budget | Total budget |
|-----------------|------------------|---------------------|--------------|
| Google Web Ads  | `build/web-mobile/` | 2 MB (HTML inline)   | 5 MB         |
| Meta Playable   | `build/web-mobile/` | 2 MB                 | 2 MB total   |
| AppLovin        | `build/web-mobile/` | 5 MB                 | 5 MB         |
| IronSource      | `build/web-mobile/` | 5 MB                 | 5 MB         |
| Unity Ads       | `build/web-mobile/` | 5 MB                 | 5 MB         |

Meta is the strictest — design for 2 MB total or you'll get rejections.

## cocos build CLI

The MCP `project_build_system` and `project_manage` tools execute these
behind the scenes. For ad-hoc builds:

```bash
"${PROJECT_DIR}/CocosCreator" --project "${PROJECT_DIR}" \
  --build "platform=web-mobile;buildPath=build/web-mobile;minify=true"
```

## Bundle-Size Triage Checklist

When you're over budget, in this order:

1. **Textures** — are atlases packed? Are PNGs `etc1` compressed? Are any 2K+ when 1K would do?
2. **Audio** — are clips `ogg` or `mp3`, not `wav`? Loop SFX should be ≤200KB; one-shots ≤50KB.
3. **Fonts** — is the font subsetted to only the characters you use? A full TTF can be 1MB+.
4. **Scripts** — is there dead code? Are unused `cc.*` imports treeshaken?
5. **Scenes** — split into bundles via `bundle` flag in `cc.assetBundleManager`.
6. **Prefabs** — duplicated prefabs across bundles count multiple times.
7. **Animations** — long `.anim` files; can they be compressed by reducing keyframe count?

## WebGL Version

- Default to **WebGL 2.0**; fallback to 1.0 set in build options
- Particle systems with `material renderMode = additive` need WebGL 2.0 for blending to work cleanly
- 16-bit textures (RGB565) are WebGL-2-only

## Build Verification

After every build:

1. `debug_console` — read for warnings
2. Open the output `index.html` in a real browser; confirm it runs
3. Record cold-load time, FPS sample (30s), peak memory → save to agentmemory for qa-tester's baseline
