# Playable UX Patterns — Cheatsheet for the `design` agent

A condensed library of proven UX patterns. Reach for these when the spec is
under-specified or when you're choosing between two reasonable layouts.

## The First 5 Seconds — Hook Patterns

| Pattern | When to use | Risk |
|---------|-------------|------|
| **Auto-play teaser → tap to take over** | Player needs context (genre, goal) before doing anything | Lower control = lower conversion if it runs too long |
| **Immediate input ("tap to start")** | Mechanic is self-evident (whack-a-mole, swipe-to-cut) | Confusion if mechanic is unfamiliar |
| **Animated finger / hand prompt** | Mechanic is unfamiliar but still tap-based | Looks dated if overused |
| **Forced fail then retry** | Showing escalating challenge | Frustrating if too hard |
| **"You vs. AI" reveal** | Competitive games (chess, MOBA) | Burns frames if AI move is slow |

Rule of thumb: the first input the player makes should be the **same input** the core loop uses. Don't teach tap-to-start and then require a swipe.

## Core Loop Pacing

- One **action** per 1–2 seconds.
- One **escalation** every 3–5 seconds (difficulty bump, new visual, new sound).
- One **win moment** every 5–10 seconds — dopamine refresh.
- A clear **fail state** that feels fair, with instant retry.

## CTA Placement

| Placement | Conversion | Risk |
|-----------|-----------|------|
| **On win moment** | Highest | Player feels rewarded → tap to download |
| **After timeout (15–30s)** | Reliable | Player may have lost interest |
| **Both** | Best practice | Don't overlap — sequence them |
| **Inline (visible always)** | Lower | Trains players to ignore |

CTA copy: pick **one** verb (Play, Install, Try, Continue). Avoid "Click here". Pair with one social/urgency cue ("10M players", "Limited time") only if it's real.

## End Card Anatomy

1. Headline (hero text, 4–8 words)
2. Hero visual (gameplay screenshot or character)
3. Star rating + install count (if available, real numbers only)
4. **Primary CTA button** (44×44 min tap target, brand-color, animated)
5. App store badges (Apple / Google) — only on platforms that allow them
6. Optional: tertiary "Continue" link for users not ready to install

## Anti-Patterns (Refuse These)

- Tutorial text that the player must read to win — playables are pre-literate
- Multi-language text (the spec is set at upload time, not by user)
- Dark patterns (fake X buttons, disguised CTAs) — Google AWV will reject
- Audio that auto-plays loud — many ad platforms mute by default; design must work silent
- Network calls (loading external assets) — bundle everything

## Safe-Area Quick Reference

| Platform | Top inset | Bottom inset | Notes |
|----------|-----------|--------------|-------|
| Google Web Ad portrait | 80px | 120px (CTA bar) | Keep tap targets inside |
| Meta Playable | 60px | 120px | Allow for status bar |
| AppLovin / IronSource | 60px | 100px | MRAID overlay top-right |
| Unity Ads | 80px | 80px | Allow for "X close" button |

Always design at 1080×1920 (portrait) or 1920×1080 (landscape) with 10% safety margins.
