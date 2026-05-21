# State Machine Template

For mechanics with 3+ distinct states. Below 3, just use boolean flags.

## Pattern — Simple FSM in One File

```typescript
import { _decorator, Component } from 'cc';
const { ccclass, property } = _decorator;

type State = 'idle' | 'aiming' | 'firing' | 'reloading' | 'cooldown';

@ccclass('CoreLoopFSM')
export class CoreLoopFSM extends Component {
    @property public reloadSeconds = 1.5;

    private _state: State = 'idle';
    private _stateEnteredAt = 0;

    start() { this._enter('idle'); }

    update(dt: number) {
        const elapsed = (Date.now() - this._stateEnteredAt) / 1000;
        switch (this._state) {
            case 'reloading':
                if (elapsed >= this.reloadSeconds) this._enter('idle');
                break;
            case 'cooldown':
                if (elapsed >= 0.4) this._enter('idle');
                break;
        }
    }

    public input(action: 'aim' | 'release' | 'reload') {
        if (this._state === 'idle' && action === 'aim')    this._enter('aiming');
        if (this._state === 'aiming' && action === 'release') this._enter('firing');
        if (this._state === 'idle' && action === 'reload') this._enter('reloading');
    }

    private _enter(s: State) {
        this._state = s;
        this._stateEnteredAt = Date.now();
        this.node.emit('state', s);
        if (s === 'firing') this._fire();
    }

    private _fire() {
        // … do the firing, then transition automatically
        setTimeout(() => this._enter('cooldown'), 200);
    }

    public get state(): State { return this._state; }
}
```

## Conventions

- States are **string literals**, not enum, for readability and serialization
- Always emit a `state` event on transition so other components can react without coupling
- Track `_stateEnteredAt` to handle timed transitions in `update`
- Inputs are an explicit method (`input(action)`), not random `if` branches throughout the class
- Save the full state diagram to agentmemory keyed `playable:{slug}:typescript:fsm:{name}` so qa-tester can verify each transition

## When to Use a Library

For >8 states or nested states (hierarchical FSM), reach for [XState](https://github.com/statelyai/xstate) — but the bundle cost is ~50KB which is meaningful for a 5MB budget. Only worth it if the gameplay genuinely warrants it.
