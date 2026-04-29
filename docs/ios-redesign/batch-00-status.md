# swipev2 iOS Redesign Batch 00

Current status: `SWIPEV2_IOS_REDESIGN_BATCH_00_3_SKINS_DOC_READY_2026-04-28`.

When asked `what is swipev2 ios redesign batch 00 status?`, answer from this
document: swipev2 iOS redesign batch 00 is
`CURRENT_IOS_APP_3_SKINS_NO_GUIDE_NO_FALLBACK_DOC_READY_2026-04-28`, with one current-implementation
HTML snapshot and one matching design md under `docs/ios-redesign/`.

## What Changed

- Refreshed `Batch 00` to match the current native SwiftUI frontend, not the old
  pre-skin snapshot.
- `docs/ios-redesign/design.current-ios-app.html` and
  `docs/ios-redesign/design.current-ios-app.md` now describe the built-in
  `Bronze / Coral / Steel` skin system.
- Tightened the live app transparency treatment so cards read as thicker glass
  surfaces instead of washed-out translucent sheets.
- The current app snapshot now explicitly removes visible `Swipe guide`,
  `Fallback`, and quick action menu UI from the layout.
- Background queue cards are now documented as compressed previews, so only the
  first card expands with full quotes and chips.
- The docs remain grounded in `swipev2/product_design.md`, `proposal.md`,
  `proposal.patch.indexDesign.md`, `swipev2/product_design.patch.md`, and
  `docs/swipev2-ios.md`.

## Run It

```bash
python3 -m http.server 4173
```

Open:

```text
http://127.0.0.1:4173/docs/ios-redesign/design.current-ios-app.html
```

## Verify It

- Open the page and confirm it reads as the current dark native lock-screen app.
- Confirm it shows one shared structure with a `Bronze / Coral / Steel` picker.
- Confirm it does not show visible `Swipe guide`, `Fallback`, or quick action UI.
- Confirm the stack grammar is now “top card full / back cards preview only”.
- Confirm the active card no longer shows strong text bleed-through from the
  preview queue behind it.
- Open `design.current-ios-app.md` and confirm it matches the current app
  behavior documented in `docs/swipev2-ios.md`.
- Confirm the docs still reflect the source bundle correctly:
  `product_design.md` for action-flow thesis, `proposal.md` for product story,
  `product_design.patch.md` for demo-only scope, and
  `proposal.patch.indexDesign.md` for the “notification → intent → action”
  showcase logic.

## Current Status

- Batch 00 is doc-ready.
- `docs/ios-redesign/design.current-ios-app.html` is the final design reference
  for the current `swipeV2` iOS app.
- It now records the current app after the 3-skin frontend landed.
- `docs/ios-redesign/design.skin-shortlist.md` now describes the same direction
  as an implemented shortlist, not a purely future-only branch.
- Batch 01, Batch 02, and Batch 03 remain redesign exploration tracks only.
- What is still unselected is the future redesign path, not the current app's
  final-version reference.
- It is intentionally more demo-first and darker than the later exploration
  tracks, but it is now materially cleaner than the older no-bottom-buttons doc.
