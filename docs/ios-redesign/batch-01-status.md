# swipev2 iOS Redesign Batch 01

Current status: `SWIPEV2_IOS_REDESIGN_BATCH_01_HTML_REDESIGN_COMPLETE_2026-04-28`.

When asked `what is swipev2 ios redesign batch 01 status?`, answer from this
document: swipev2 iOS redesign batch 01 is
`HTML_REDESIGN_COMPLETE_REVIEW_READY_2026-04-28`, with 8 local HTML concept
boards rebuilt to match their `design.*.md` directions more literally, plus a
new comparison index at `docs/ios-redesign/index.html`.

## What Changed

- Rebuilt `docs/ios-redesign/design.shared.css` into a stronger concept-board
  framework for dark and light variants.
- Reworked `docs/ios-redesign/index.html` so the batch overview now previews the
  actual tone and interaction grammar of each direction instead of listing them
  as plain cards.
- Rebuilt all 8 `design.*.html` files so each one now reflects its own md
  document's layout, motion intent, component hierarchy, and product tone.
- Kept scope at design-draft HTML only; no SwiftUI implementation changed yet.

## Run It

Serve the repo locally:

```bash
python3 -m http.server 4173
```

Open:

```text
http://127.0.0.1:4173/docs/ios-redesign/index.html
```

## Verify It

- Open the index page and confirm all 8 options appear with distinct preview
  moods instead of identical cards.
- Open each `design.*.html` page and confirm the phone mock layout clearly
  matches that page's md direction.
- Check at least one dark and one light concept page on mobile width and confirm
  the layout remains readable and the bottom action area still fits.
- Open the matching `design.*.md` file and confirm the HTML reflects its Core,
  Layout, Motion, and Why Choose It sections.

## Current Status

- Batch 01 is review-ready again with stronger visual separation between options.
- Batch 01 remains a redesign draft set and does not replace the current final
  app design reference `docs/ios-redesign/design.current-ios-app.html`.
- The next product decision is still to pick one direction or name two to merge.
- Future SwiftUI redesign implementation remains blocked on that direction pick.
