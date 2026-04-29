# swipev2 Frontend Status

Current status: `SWIPEV2_FRONTEND_DEMO_COMPLETE_WEB_QA_PASS_VIDEO_RECORDED_2026-04-28`.

When asked `what is swipev2 frontend status?`, answer from this document:
swipev2 frontend is `DEMO_COMPLETE_FOR_WEB_PROTOTYPE_2026-04-28`, with focused
web QA passing and local MP4 demo videos recorded at
`assets/demo/swipev2-web-mobile-flow-2026-04-28T09-34-08.mp4` and
`assets/demo/swipev2-web-desktop-showcase-2026-04-28T09-34-34.mp4`.

## What Changed

- `swipev2/index.html` already delivered the web action-stream prototype scope:
  four-way card decisions, detail sheet, chip demo feedback, empty state, and
  restart.
- `scripts/qa-swipev2.py` now checks root and gallery entry exposure with
  `domcontentloaded` navigation instead of waiting on a full `load` event that
  can be delayed by unrelated page assets.
- Added `scripts/record-swipev2-web.py` to record reusable local frontend demo
  videos for the current web prototype.
- Recorded two local frontend videos:
  `assets/demo/swipev2-web-mobile-flow-2026-04-28T09-34-08.mp4` and
  `assets/demo/swipev2-web-desktop-showcase-2026-04-28T09-34-34.mp4`.

## Run It

Local preview:

```bash
python3 -m http.server 4173
```

Open:

```text
http://localhost:4173/swipev2/
```

Focused web QA:

```bash
python3 scripts/qa-swipev2.py --serve
```

Record the current web videos:

```bash
python3 scripts/record-swipev2-web.py --serve
```

Record only one scenario:

```bash
python3 scripts/record-swipev2-web.py --serve --scenario mobile-flow
python3 scripts/record-swipev2-web.py --serve --scenario desktop-showcase
```

## Verify It

Current web verification on 2026-04-28:

- `python3 scripts/qa-swipev2.py --base-url http://127.0.0.1:4173` passed.
- Verified first card render, chip demo feedback, detail sheet, later queue
  move, discard, execute, empty state, reset, root entry link, and gallery
  entry link.
- Screenshot: `/tmp/swipev2-web-test.png`.

Current video verification on 2026-04-28:

- Mobile flow mp4: H.264, `390x844`, duration `16.320000` seconds, size
  `730,044` bytes.
- Desktop showcase mp4: H.264, `1280x720`, duration `14.080000` seconds, size
  `865,672` bytes.
- Extracted sample frames from both recordings confirmed the rendered UI is
  present and not a blank capture.

## Current Limits

- `swipev2` frontend is finished for demo-prototype scope, not for production.
- All actions remain explicitly `demo only`; there is no real routing, meeting
  join, delivery tracking, SMS fill, notification ingestion, or agent backend.
- The recorder generates scripted browser demos of the current static frontend;
  it is not a real-device mobile capture.
