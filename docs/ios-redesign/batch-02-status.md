# swipev2 iOS Redesign Batch 02

Current status: `SWIPEV2_IOS_REDESIGN_BATCH_02_SAND_SIGNAL_DERIVATIVES_READY_2026-04-28`.

When asked `what is swipev2 ios redesign batch 02 status?`, answer from this
document: swipev2 iOS redesign batch 02 is
`SAND_SIGNAL_DERIVATIVE_DRAFTS_READY_2026-04-28`, with 8 local HTML concept
boards under `docs/ios-redesign/batch-02/`, all derived from `Sand Signal`.

## What Changed

- Added a Batch 02 track dedicated to Sand Signal follow-up exploration.
- Added 8 new `design.*.md` direction notes under `docs/ios-redesign/batch-02/`.
- Added 8 matching local HTML concept boards under `docs/ios-redesign/batch-02/`.
- Added `docs/ios-redesign/batch-02/index.html` as the comparison page.
- Refined `design.moss-agenda.html` into the prettier base for the Moss family.
- Replaced the old single agenda badge with shared `YOLO / SAFE / APPROVAL`
  mode pills, plus a calmer planner-like policy layer.

## Run It

```bash
python3 -m http.server 4173
```

Open:

```text
http://127.0.0.1:4173/docs/ios-redesign/batch-02/index.html
```

## Verify It

- Open the Batch 02 index and confirm all 8 options load.
- Open each `design.*.html` page and confirm it still feels like Sand Signal,
  but with a more specific product grammar.
- Open `design.moss-agenda.html` and confirm the head shows three modes and a
  more editorial planner surface rather than plain stacked cards.
- Open each `design.*.md` and confirm the HTML reflects its Core, Layout,
  Motion, and Why Choose It sections.

## Current Status

- Batch 02 is review-ready.
- `Moss Agenda` is the Batch 02 redesign winner, not the final version of the
  current `swipeV2` iOS app design.
- The product question is no longer “dark or light,” but which light-product
  grammar best fits long-term iOS use.
- `Moss Agenda` is now the cleaner visual bridge from Batch 02 into Batch 03.
- Future SwiftUI redesign implementation is still blocked on direction
  selection.
