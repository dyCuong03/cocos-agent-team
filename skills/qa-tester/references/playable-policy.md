# Playable Policy Checklist — qa-tester

Each ad platform has creative policies that get builds rejected. Run this
list before sign-off.

## Google Web Ads (AWV)

- [ ] No misleading "X" close buttons
- [ ] No content that resembles system notifications
- [ ] Bundle ≤ 5 MB (HTML inline)
- [ ] Works without internet after initial load
- [ ] No autoplay audio at startup (must be user-initiated)
- [ ] CTA does not deceive (button copy matches landing page)
- [ ] Content matches advertised app (no bait-and-switch)
- [ ] Tap targets ≥ 44 × 44 px
- [ ] Color contrast ≥ 4.5:1 for any readable text

## Meta Audience Network

- [ ] Bundle ≤ 2 MB total (including all assets)
- [ ] Single HTML file with everything inline
- [ ] Implements `FbPlayableAd.onCTAClick()` for the CTA
- [ ] No external network requests
- [ ] Plays full screen without scrolling
- [ ] Works on portrait + landscape (orientation-adaptive)
- [ ] No persistent user data (no localStorage abuse)

## AppLovin / IronSource / Unity Ads

- [ ] MRAID 2.0+ compliant — uses `mraid.open()` not `window.open()`
- [ ] No persistent localStorage > 100KB
- [ ] No iframe injection
- [ ] Works in a sandboxed WebView
- [ ] CPU usage < 50% sustained

## Accessibility (all platforms)

- [ ] Color is not the only differentiator (e.g. red vs green pieces also have shape difference)
- [ ] Critical UI has at least 4.5:1 contrast against background
- [ ] Tap targets ≥ 44 × 44 px (Apple HIG) / 48 × 48 dp (Material)
- [ ] Animations can be skipped (player can tap CTA before animation completes)

## File a Policy Bug

Format:

```
- [ ] QA-BUG-{NN}: [policy:{platform}] {what fails} #qa-bug #policy @<role>
```

The owning role:

- **Bundle size** → `@cocos-engineer`
- **Tap target / contrast / safe area** → `@design` (re-spec) or `@cocos-engineer` (incorrect implementation of the spec)
- **CTA flow / `mraid.open` not wired** → `@typescript-dev`
- **Autoplay audio** → `@typescript-dev` (gate behind first user input)
- **External network call** → `@cocos-engineer` (find and remove)
