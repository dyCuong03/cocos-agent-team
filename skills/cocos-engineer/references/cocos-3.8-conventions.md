# Cocos Creator 3.8.x — Conventions Cheatsheet

For the `cocos-engineer` agent. Use this when in doubt about scene
structure, anchors, or naming.

## Scene File Format

- `.scene` files are JSON. Don't hand-edit unless you absolutely must — the MCP `node_*` and `component_*` tools serialize correctly; manual edits often corrupt the `__type__` / `__id__` graph.
- Each scene has a root `Canvas` node hosting a `Camera`, a `UITransform`, and the UI tree.

## Standard Project Layout

```
${PROJECT_DIR}/assets/
├── scenes/
│   ├── Hook.scene
│   ├── Core.scene
│   └── EndCard.scene
├── prefabs/
│   ├── ui/CTAButton.prefab
│   ├── fx/RewardBurst.prefab
│   └── characters/Player.prefab
├── scripts/
│   ├── hook/SwipeHook.ts
│   ├── core/CoreController.ts
│   ├── ui/CTAController.ts
│   └── audio/AudioManager.ts
├── textures/         ← imported PNGs/JPGs
├── atlases/          ← packed sprite atlases
├── audio/            ← .mp3/.wav/.ogg
├── animations/       ← .anim files
├── particles/        ← .pset / .ParticleAsset
├── fonts/            ← .ttf with subsetting
└── raw/              ← intake folder for unsorted assets from design
```

## Anchor / Widget Mapping

Wireframes use words → cocos-engineer maps them to Widget alignment:

| Wireframe word    | Widget align flags     |
|-------------------|------------------------|
| `top-left`        | top + left             |
| `top-right`       | top + right            |
| `top-center`      | top + horizCenter      |
| `bottom-center`   | bottom + horizCenter   |
| `center`          | horizCenter + vertCenter |
| `full`            | top + bottom + left + right |
| `bottom`          | bottom + horizCenter (full-width) |

Always set `UITransform.anchorPoint` together with `Widget.target`.

## Common Component Property Names

When calling `set_component_property`, these are the names to use:

| Component       | Common props                                                        |
|-----------------|---------------------------------------------------------------------|
| `Sprite`        | `spriteFrame`, `color`, `sizeMode`, `type`                          |
| `Label`         | `string`, `fontSize`, `color`, `lineHeight`, `horizontalAlign`     |
| `Button`        | `transition`, `target`, `normalSprite`, `pressedSprite`, `clickEvents` |
| `UITransform`   | `contentSize`, `anchorPoint`                                        |
| `Widget`        | `target`, `isAlignTop`, `isAlignBottom`, `top`, `bottom`, etc.     |
| `Animation`     | `clips`, `defaultClip`, `playOnLoad`                                |
| `ParticleSystem2D` | `playOnLoad`, `duration`, `totalParticles`, `emissionRate`       |
| `AudioSource`   | `clip`, `volume`, `loop`, `playOnAwake`                             |

## Prefab Conventions

- One prefab per **reusable** node subtree (button states, particle bursts, characters).
- Don't prefab a one-off — the indirection cost isn't worth it.
- After `prefab_lifecycle` (create), update every instance to inherit via `prefab_instance` (link).
- Saving the prefab does not save the scene. Both must be saved separately via `scene_management` + the prefab's save call.

## Build Settings (cocos build)

Default for the team's web-mobile target:

- Platform: `web-mobile`
- Build path: `build/web-mobile`
- Compress textures: yes (etc1 for opaque, etc1+alpha for transparent)
- Inline SpriteFrame: yes if total atlas <500KB
- Minify: yes
- Source maps: dev only
- WebGL version: 2.0 with 1.0 fallback
