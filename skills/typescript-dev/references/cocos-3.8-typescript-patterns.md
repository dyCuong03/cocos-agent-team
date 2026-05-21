# Cocos Creator 3.8.x — TypeScript Patterns

The patterns the `typescript-dev` agent uses every day.

## Component Skeleton

```typescript
import { _decorator, Component, Node, EventTouch, UITransform, Vec3, tween } from 'cc';
const { ccclass, property } = _decorator;

@ccclass('ExampleController')
export class ExampleController extends Component {
    @property({ type: Node, tooltip: 'Required node to act on' })
    public target: Node | null = null;

    @property({ tooltip: 'Tuneable threshold for input detection' })
    public threshold = 50;

    onLoad()    { /* register listeners, init state */ }
    start()     { /* one-shot setup that requires the scene to be ready */ }
    update(dt: number) { /* per-frame; remove if not needed */ }
    onDestroy() { /* deregister every listener you added in onLoad */ }
}
```

## Input Handling (3.x event system, not 2.x `systemEvent`)

```typescript
import { Node, EventTouch, UITransform } from 'cc';

// Tap on a node
this.node.on(Node.EventType.TOUCH_END, this._onTap, this);

// Cleanup
onDestroy() {
    this.node.off(Node.EventType.TOUCH_END, this._onTap, this);
}

private _onTap(e: EventTouch) {
    // e.getLocation() returns Vec2 in screen coords
}
```

## `@property` Type Coverage

| TS type                | `@property` form                              |
|------------------------|-----------------------------------------------|
| `number`               | `@property number`                            |
| `boolean`              | `@property boolean`                           |
| `string`               | `@property string`                            |
| `Node \| null`         | `@property({ type: Node }) public x: Node \| null = null` |
| `Sprite \| null`       | `@property({ type: Sprite }) public x: ... = null` |
| `SpriteFrame \| null`  | `@property({ type: SpriteFrame })`            |
| `Prefab \| null`       | `@property({ type: Prefab })`                 |
| `AudioClip \| null`    | `@property({ type: AudioClip })`              |
| array of nodes         | `@property({ type: [Node] }) public xs: Node[] = []` |
| enum                   | `@property({ type: Enum(MyEnum) }) public e = MyEnum.A` |

Defaults are **required** in TypeScript — Cocos uses them as the initial editor value.

## Tween (DOTween-like)

```typescript
tween(node)
  .to(0.15, { scale: new Vec3(1.2, 1.2, 1) })
  .to(0.15, { scale: new Vec3(1.0, 1.0, 1) })
  .call(() => this._onTweenDone())
  .start();
```

For repeated effects, cache the tween in a property to allow stopping.

## Audio Pooling

```typescript
import { AudioSource, AudioClip } from 'cc';

@property({ type: AudioSource }) public src: AudioSource | null = null;
@property({ type: AudioClip })   public sfx: AudioClip | null = null;

playOneShot() {
    if (this.src && this.sfx) this.src.playOneShot(this.sfx, 1);
}
```

For more than 4 simultaneous SFX, use a pool of `AudioSource` components on a dedicated `AudioManager` node — see `playable-snippets.md`.

## Lifecycle Order — Important Gotcha

`onLoad` runs before any sibling component's `start()`. If component A's `start()` reads a state computed by component B's `onLoad`, you're fine. But if A's `onLoad` reads B's `start`-computed state, you'll get `undefined`. **Always do setup in `onLoad`, time-sensitive init in `start`.**

## Cleanup Discipline

Memory leaks are the #1 reason qa-tester rejects a build. Every listener added in `onLoad` **must** be removed in `onDestroy`. Every tween started must be cancellable. Every interval/timeout must be cleared.

```typescript
private _intervalId = 0;

onLoad() {
    this._intervalId = setInterval(() => this._tick(), 1000) as unknown as number;
}

onDestroy() {
    if (this._intervalId) clearInterval(this._intervalId);
}
```
