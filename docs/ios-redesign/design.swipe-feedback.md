# Design · Swipe Feedback Lab

Version name: `swipe-feedback`
Status: `WEB_INTERACTION_READY_2026-04-28`

## Core

- Goal: make four-way swipe feedback obvious before the user releases the card.
- Mood: lock-screen control surface, stronger directional affordance, no visible
  fallback buttons.
- Scope: web interaction design for the next native SwiftUI pass.

## Behavior

- Four target zones stay visible: left discard, right execute, up detail, down
  later.
- Dragging derives one active direction from the dominant axis.
- The card halo, target zone, HUD verb, and progress meter all update from the
  same direction state.
- Passing the threshold changes copy from selection feedback to release-to-commit
  feedback.
- Short drags snap back and keep the queue unchanged.

## Native Mapping

- Derive `direction`, `progress`, and `isCommitted` from `dragOffset`.
- Map direction to tint, label, accessibility value, and optional haptic prewarm.
- Keep the real four actions unchanged: discard, execute, detail, later.
- Do not reintroduce visible fallback buttons; keep fallback access through
  accessibility actions.
- Do not add a bottom four-button legend; it reads as fallback UI.

## Run It

```bash
python3 -m http.server 4173
```

Open:

```text
http://127.0.0.1:4173/docs/ios-redesign/design.swipe-feedback.html
```

## Verify It

- Drag the card left, right, up, and down.
- Confirm the active target and HUD switch direction immediately.
- Confirm the progress bar fills toward the release threshold.
- Confirm the copy says release/commit only after the threshold.
- Confirm short drags snap back and report no queue change.
- Confirm there are no bottom four fallback buttons.

## Current Status

- Web prototype is ready for review.
- Bottom four-button legend was removed.
- `design.swipe-feedback-16.html` adds 16 no-bottom-button directions.
- Native SwiftUI implementation is not changed by this design page yet.
