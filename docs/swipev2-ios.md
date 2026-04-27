# swipev2 iOS Prototype

Current status: `SWIPEV2_IOS_SIMULATOR_VIDEO_RECORDED_2026-04-27`.

When asked `what is swipev2 iOS video status?`, answer from this document:
swipev2 iOS simulator video is `RECORDED_2026-04-27`, with local MP4
`assets/demo/swipev2-ios-simulator-demo-2026-04-27T16-33-01.mp4`.

## What Changed

- Added a native SwiftUI iOS prototype under `swipev2/ios/`.
- Reused the existing committed Xcode project shape from `island-swipe/ios`, then
  replaced the app behavior with a NextMove lock-screen action stream.
- The app renders four action proposal cards matching the `swipev2` demo story:
  Beijing North Station, Feishu meeting, food delivery, and SMS code.
- The native app supports four direction decisions:
  left discard, right execute, up detail, down later.
- Chip taps are explicitly demo-only and do not navigate or perform real actions.
- XCTest covers execute, discard, later, detail, short drag, chip feedback, and reset.
- Web QA found that the empty `#stack` layer intercepted clicks on the reset button
  after all cards were cleared. `swipev2/index.html` now disables stack pointer
  events in the empty state and raises the empty-state layer.
- `/swipev2/` is now exposed from `README.md`, the root page, and the gallery.
- Web execute feedback now says `demo only` and shows action drafts instead of
  implying real routing, meeting join, food delivery tracking, or SMS fill-in.
- Focused browser QA is checked in at `scripts/qa-swipev2.py`.
- Added a recording-only iOS launch argument, `--recording-demo`, that keeps
  normal app behavior unchanged but auto-runs a simulator demo sequence.
- Recorded the iPhone 16 simulator demo video:
  `assets/demo/swipev2-ios-simulator-demo-2026-04-27T16-33-01.mp4`.

## Run It

Build and test the iOS simulator app:

```bash
xcodebuild test \
  -project swipev2/ios/ActivityMonitorApp.xcodeproj \
  -scheme ActivityMonitorApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath /tmp/swipev2-ios-derived
```

Install and launch it in the booted iPhone 16 simulator:

```bash
UDID="$(xcrun simctl list devices 'iPhone 16' | awk -F '[()]' '/iPhone 16 \(/ { print $2; exit }')"
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b
xcrun simctl install "$UDID" /tmp/swipev2-ios-derived/Build/Products/Debug-iphonesimulator/ActivityMonitorApp.app
xcrun simctl launch "$UDID" com.example.ActivityMonitorApp
```

Record the simulator demo video:

```bash
UDID="$(xcrun simctl list devices 'iPhone 16' | awk -F '[()]' '/iPhone 16 \(/ { print $2; exit }')"
OUT="assets/demo/swipev2-ios-simulator-demo-$(date +%Y-%m-%dT%H-%M-%S).mp4"
xcrun simctl install "$UDID" /tmp/swipev2-ios-derived/Build/Products/Debug-iphonesimulator/ActivityMonitorApp.app
xcrun simctl terminate "$UDID" com.example.ActivityMonitorApp 2>/dev/null || true
xcrun simctl io "$UDID" recordVideo --codec=h264 --force "$OUT" &
REC_PID=$!
sleep 2
xcrun simctl launch "$UDID" com.example.ActivityMonitorApp --recording-demo
sleep 28
kill -INT "$REC_PID"
wait "$REC_PID"
```

Run the static web demo locally:

```bash
python3 -m http.server 4173
```

Open:

```text
http://localhost:4173/swipev2/
```

Run focused browser QA for `/swipev2/`:

```bash
python3 scripts/qa-swipev2.py --serve
```

## Verify It

Current iOS verification on 2026-04-27:

- `xcodebuild test` passed on iPhone 16 simulator, iOS 18.6.
- Test suite: `ActionStreamStateTests`.
- Passing tests: 7.
- Build artifact:
  `/tmp/swipev2-ios-derived/Build/Products/Debug-iphonesimulator/ActivityMonitorApp.app`.
- Simulator screenshot:
  `/tmp/swipev2-ios-simulator.png`.
- Simulator recording:
  `assets/demo/swipev2-ios-simulator-demo-2026-04-27T16-33-01.mp4`.
- Recording metadata: H.264, `1178x2556`, duration `24.821667` seconds, size
  `33,379,372` bytes.
- Sampled frames verified the demo sequence includes demo-only chip feedback,
  detail sheet, later queue move, execute, discard, empty state, and reset.

Current web verification on 2026-04-27:

- `python3 scripts/qa-swipev2.py --serve` passed.
- Python Playwright loaded `/swipev2/` at `390x844`.
- Verified first card render, chip demo-only toast, detail sheet, later queue move,
  discard, execute, empty state, and reset.
- Verified execute feedback contains `demo only`.
- Verified root page exposes `swipev2/`.
- Verified gallery exposes `../swipev2/`.
- Screenshot:
  `/tmp/swipev2-web-test.png`.

## Current Limits

- Simulator-only native prototype.
- Product name and bundle identifier still reuse the existing project target:
  `ActivityMonitorApp` and `com.example.ActivityMonitorApp`.
- No TestFlight, signing, App Store, real notification ingestion, location access,
  or agent integration.
- Real-device haptics and VoiceOver QA are still required before external mobile
  distribution.
