# Safe Area & Aspect — Cheatsheet

## Design Canvas Sizes

| Orientation | Design Resolution | Ratio |
|-------------|-------------------|-------|
| Portrait    | 1080 × 1920       | 9:16  |
| Landscape   | 1920 × 1080       | 16:9  |

Both supported via Cocos Creator's `Widget` + `UITransform` anchoring. Always anchor critical UI (CTA button, score) to the safe-area edges, not the canvas edges.

## Per-Platform Safe Area (interior usable region)

| Platform           | Top | Bottom | Sides | CTA-zone |
|--------------------|-----|--------|-------|----------|
| Google Web Ads     | 80  | 200    | 20    | Bottom 200px |
| Meta Audience Net  | 60  | 120    | 16    | Bottom 120px |
| AppLovin MAX       | 60  | 100    | 16    | Bottom 100px or right gutter |
| IronSource         | 60  | 100    | 16    | Bottom 100px |
| Unity Ads          | 80  | 80     | 20    | Top-right close button respected |

All measurements are in design pixels at 1080×1920. Multiply by `designScale = realResolution / 1080` for runtime.

## Rules

- Never put a tap target within 16px of any canvas edge
- The platform may overlay a "close" or "skip" widget — leave the top-right 80×80 free
- A CTA button **must** be readable + tappable at 320px display width (smallest phone)
- Portrait playables must still degrade gracefully if shown in landscape — anchor UI to short edge

## Cocos Creator Anchor Conventions

When you spec a node's anchor in the wireframe, write it as `top-left`, `top-right`, `bottom-center`, `center`, etc. The cocos-engineer maps these to the `Widget` component's alignment flags.
