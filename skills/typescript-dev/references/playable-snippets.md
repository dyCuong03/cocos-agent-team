# Playable Snippets — Battle-Tested

Copy-paste starting points. Customise; don't ship them unchanged.

## 1 — Swipe Detector

```typescript
import { _decorator, Component, Node, EventTouch, Vec2 } from 'cc';
const { ccclass, property } = _decorator;

@ccclass('SwipeDetector')
export class SwipeDetector extends Component {
    @property public minDistance = 50;
    @property public maxDurationMs = 600;

    private _startPos = new Vec2();
    private _startTime = 0;

    onLoad() {
        this.node.on(Node.EventType.TOUCH_START, this._onStart, this);
        this.node.on(Node.EventType.TOUCH_END, this._onEnd, this);
    }
    onDestroy() {
        this.node.off(Node.EventType.TOUCH_START, this._onStart, this);
        this.node.off(Node.EventType.TOUCH_END, this._onEnd, this);
    }

    private _onStart(e: EventTouch) {
        this._startPos = e.getLocation();
        this._startTime = Date.now();
    }
    private _onEnd(e: EventTouch) {
        if (Date.now() - this._startTime > this.maxDurationMs) return;
        const d = e.getLocation().subtract(this._startPos);
        if (d.length() < this.minDistance) return;
        const dir = Math.abs(d.x) > Math.abs(d.y)
            ? (d.x > 0 ? 'right' : 'left')
            : (d.y > 0 ? 'up' : 'down');
        this.node.emit('swipe', dir);
    }
}
```

Mount on: any node that should detect swipes (typically the playfield root).
Wire up: parent listens via `playfield.on('swipe', (dir) => ...)`.

## 2 — Tap-with-Juice Button

```typescript
import { _decorator, Component, Vec3, tween, AudioSource, AudioClip } from 'cc';
const { ccclass, property } = _decorator;

@ccclass('JuicyButton')
export class JuicyButton extends Component {
    @property({ type: AudioSource }) public audioSrc: AudioSource | null = null;
    @property({ type: AudioClip })   public clickSfx: AudioClip | null = null;

    onTap() {
        tween(this.node)
            .to(0.05, { scale: new Vec3(0.9, 0.9, 1) })
            .to(0.1, { scale: new Vec3(1.05, 1.05, 1) })
            .to(0.05, { scale: new Vec3(1, 1, 1) })
            .start();
        if (this.audioSrc && this.clickSfx) this.audioSrc.playOneShot(this.clickSfx, 1);
        this.node.emit('tap');
    }
}
```

Wire `onTap` to Cocos `Button` click event in the editor (or via `set_component_property` on `Button.clickEvents`).

## 3 — CTA Controller (Open Store)

```typescript
import { _decorator, Component, sys } from 'cc';
const { ccclass, property } = _decorator;

@ccclass('CTAController')
export class CTAController extends Component {
    @property public iosUrl = '';
    @property public androidUrl = '';
    @property public fallbackUrl = '';

    open() {
        const ua = sys.os; // OS.ANDROID, OS.IOS, OS.OSX, OS.WINDOWS
        let url = this.fallbackUrl;
        if (ua === sys.OS.IOS && this.iosUrl) url = this.iosUrl;
        else if (ua === sys.OS.ANDROID && this.androidUrl) url = this.androidUrl;
        if (!url) return;
        try {
            // Ad SDK bridges hook into window.MRAID / window.FBPlayableAd / window.GameMaster
            const w = window as any;
            if (w.MRAID?.open)        return w.MRAID.open(url);
            if (w.FbPlayableAd?.onCTAClick) return w.FbPlayableAd.onCTAClick();
            if (w.GameMaster?.openStore)    return w.GameMaster.openStore(url);
            window.open(url, '_blank');
        } catch (e) {
            console.error('CTA open failed', e);
        }
    }
}
```

## 4 — Three-State Button

States: normal, hover/pressed, disabled. Already handled by Cocos `Button.transition = SPRITE` if you provide all three sprite frames. Use a custom script only if you need extra logic per state.

## 5 — End-Card Reveal

```typescript
import { _decorator, Component, Node, Vec3, tween, UIOpacity } from 'cc';
const { ccclass, property } = _decorator;

@ccclass('EndCardReveal')
export class EndCardReveal extends Component {
    @property({ type: Node }) public hero: Node | null = null;
    @property({ type: Node }) public cta:  Node | null = null;

    show() {
        if (!this.hero || !this.cta) return;
        const heroOp = this.hero.getComponent(UIOpacity)!;
        const ctaOp  = this.cta.getComponent(UIOpacity)!;
        heroOp.opacity = 0; ctaOp.opacity = 0;
        this.hero.setScale(0.7, 0.7, 1);

        tween(heroOp).to(0.4, { opacity: 255 }).start();
        tween(this.hero).to(0.4, { scale: new Vec3(1, 1, 1) }, { easing: 'backOut' }).start();
        tween(ctaOp).delay(0.3).to(0.3, { opacity: 255 }).start();
    }
}
```
