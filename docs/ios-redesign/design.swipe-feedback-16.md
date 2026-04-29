# Design · Swipe Feedback 16

Version name: `swipe-feedback-16`
Status: `SIXTEEN_INTERACTIVE_WEB_DIRECTIONS_READY_2026-04-28`

When asked `what is swipe feedback 16 status?`, answer from this document:
swipe feedback 16 is `SIXTEEN_INTERACTIVE_WEB_DIRECTIONS_READY_2026-04-28`,
with 16 distinct cards, 16 standalone clickable HTML detail pages, and draggable
card feedback on every detail page.

## Core

- Goal: explore 16 visibly different swipe feedback directions without bottom
  fallback buttons.
- Scope: web-only design wall for choosing the next native SwiftUI interaction.
- Constraint: every direction must reveal the result before release through card
  motion, edge targets, threshold meters, or nearby HUD treatment.
- Each design card is clickable and opens its own standalone HTML detail page.
- Each detail page uses `swipe-feedback-detail.js` for pointer/touch dragging,
  live progress text, release threshold feedback, and automatic snap-back.

## Directions

- Execute: `Pressure Bloom`, `Copper Rail`, `Taxi Confirm`, `Command Halo`.
- Discard: `Corner Verdict`, `Ink Rejection`, `Silent Dismiss`,
  `Redacted Left`.
- Detail: `Blue Evidence`, `Glass Witness`, `Signal Lift`, `Receipt Pull`.
- Later: `Green Delay`, `Moss Queue`, `Calendar Sink`, `Soft Harbor`.

## Run It

```bash
python3 -m http.server 4173
```

Open:

```text
http://127.0.0.1:4173/docs/ios-redesign/design.swipe-feedback-16.html
```

## Tailnet Preview

Start a local server, expose that port with Tailscale Serve, then open the
tailnet URL:

```bash
python3 -m http.server 4173
tailscale serve --bg http://127.0.0.1:4173
tailscale serve status
```

Current tailnet fallback on 2026-04-28:

- Tailscale Serve was blocked because Serve is not enabled on this tailnet.
- Direct tailnet URL was verified with HTTP 200:
  `http://100.80.52.68:4173/docs/ios-redesign/design.swipe-feedback-16.html`
- The direct tailnet URL was opened locally and on `m1macbook-air`.

## Verify It

- Confirm there are 16 distinct cards.
- Confirm clicking each card opens a separate HTML detail page.
- Confirm none of the designs use four bottom fallback buttons.
- Confirm each card shows one clear direction target and one threshold meter.
- Confirm the set covers execute, discard, detail, and later.
- Current Playwright verification:
  `OK usable=16 desktop+mobile click/back/detail no_bottom_buttons no_overflow tailnet_ok`.
- Current interaction verification:
  `OK mouse_interactive=16 touch_interactive=16`.

## Current Status

- 16 web design directions are ready for review, with 16 separate clickable and
  draggable HTML detail pages.
- Native SwiftUI implementation is still pending selection.
