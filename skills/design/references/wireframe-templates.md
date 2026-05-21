# Wireframe Templates — Copy-Paste Scaffolds

Every wireframe in `docs/design/{NN}-{screen}.md` follows this shape. Copy
the relevant template, fill in the gaps, hand off.

## Template — Screen Wireframe

```markdown
# Wireframe — {NN} — {Screen Name}

**Screen ID:** S{NN}_{slug}
**Spec ref:** configs/playable-spec.md → screens[{NN}]
**Orientation:** portrait | landscape
**Goal:** {one sentence}
**Duration:** {seconds}

## Layout (ASCII or Mermaid)

```
+----------------------------------------+
|  [LogoBadge: top-left, 80x80]          |
|                                        |
|         {Hero / playfield area}        |
|                                        |
|                                        |
|  [Player @ center]                     |
|                                        |
|  [Target @ bottom-center]              |
|                                        |
|  ----[Safe area 120 bottom]----------- |
|  [   CTA button: anchor bottom    ]    |
+----------------------------------------+
```

## Node Hierarchy

| # | Node path                       | Type           | Anchor        | Approx size | Notes |
|---|---------------------------------|----------------|---------------|-------------|-------|
| 1 | Canvas/Background               | Sprite         | full          | 1080×1920   | brand bg |
| 2 | Canvas/LogoBadge                | Sprite         | top-left      | 80×80       |  |
| 3 | Canvas/Player                   | Sprite + Anim  | center        | 200×200     | needs SwipeHook.ts |
| 4 | Canvas/Target                   | Sprite         | bottom-center | 160×160     |  |
| 5 | Canvas/CTA                      | Button + Label | bottom        | 600×120     | needs CTAController.ts |

## Interaction Contract

| Input          | Target node       | Feedback (visual)     | Feedback (sfx) | State change          |
|----------------|-------------------|-----------------------|----------------|-----------------------|
| swipe-right    | Canvas/Player     | tween scale 1.0→1.3   | sfx/swipe.wav  | gameState=`movingRight` |
| swipe-left     | Canvas/Player     | tween scale 1.0→1.3   | sfx/swipe.wav  | gameState=`movingLeft`  |
| tap CTA        | Canvas/CTA        | scale 1.0→0.95→1.0    | sfx/click.wav  | open store URL          |
| timeout 5s     | (none)            | finger-prompt animates | —              | show tutorial overlay   |

## Animations & Particles

- HOOK reveal: Player slides in from bottom (0.4s ease-out)
- Win burst: ParticleSystem2D `burst` on Player position, 30 particles, 0.5s

## Acceptance Criteria (qa-tester will verify)

- [ ] All 5 nodes exist at the paths above
- [ ] Swipe right/left visibly moves the Player with juice
- [ ] CTA button registers tap and opens the store URL
- [ ] Tutorial finger appears after 5s of inactivity
- [ ] No console errors on scene load
```

## Template — Asset Request

`docs/design/{NN}-{screen}-assets.md`:

```markdown
# Asset Request — {NN} — {Screen Name}

For `@cocos-engineer` to import via `asset_manage`.

| Filename                        | Type    | Size    | Notes |
|---------------------------------|---------|---------|-------|
| assets/raw/background_hook.png  | image   | 1080×1920 | brand bg, no alpha needed |
| assets/raw/player_idle.png      | image   | 200×200 | needs alpha |
| assets/raw/sfx_swipe.wav        | audio   | <50KB   | ≤0.3s |

**Already in project:** assets/brand/logo.png, assets/sfx/click.wav (verified via asset_query).

**Missing — needs the user to provide:**
- player_idle.png (placeholder OK for first pass)
```
