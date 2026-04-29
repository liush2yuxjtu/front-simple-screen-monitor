# swipev2 iOS Prototype

Current status: `SWIPEV2_IOS_SIMULATOR_VIDEO_RECORDED_AND_TAILDROPPED_2026-04-28`.

When asked `what is swipev2 iOS video status?`, answer from this document:
swipev2 iOS simulator video is `RECORDED_AND_TAILDROPPED_2026-04-28`, with
local MP4 `assets/demo/swipev2-ios-simulator-demo-2026-04-28T17-20-47.mp4`,
Taildrop sent to `m1macbook-air`, and the MP4 popped open there.

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
- Landed the native iOS frontend update around 3 built-in skins:
  `Bronze Cinema`, `Coral Receipt`, and `Steel Orchid`.
- Removed visible `Swipe guide`, `Fallback`, and quick-action fallback UI from
  the native app frontend.
- Compressed the back queue into preview cards so only the front card shows full
  quotes, title, and chips.
- Added an in-app skin picker and persisted the selected skin with `AppStorage`.
- Added a lightweight `--skin=` simulator launch override so each built-in skin
  can be snapshotted directly.
- Kept all four directional gestures, while moving the non-gesture fallback path
  to accessibility actions instead of visible UI chrome.
- Rebuilt the card, pill, quote, and secondary-chip surfaces as denser layered
  glass so the UI stays transparent but no longer feels washed out.
- Updated the recording-only demo flow so the simulator MP4 first cycles
  `Bronze`, `Coral`, and `Steel`, then runs chip feedback, detail, later,
  execute, discard, empty state, and reset.
- Verified the transparency tuning with 3 simulator snapshots:
  `/tmp/swipev2-bronze.png`, `/tmp/swipev2-coral.png`, and
  `/tmp/swipev2-steel.png`.
- Recorded a refreshed iPhone 16 simulator demo video for the transparency-tuned
  3-skin frontend: `assets/demo/swipev2-ios-simulator-demo-2026-04-28T17-20-47.mp4`.
- Sent the refreshed simulator video to Taildrop target `m1macbook-air` and
  popped it open there.

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
sleep 33
kill -INT "$REC_PID"
wait "$REC_PID"
```

Taildrop the latest simulator recording:

```bash
tailscale file cp assets/demo/swipev2-ios-simulator-demo-2026-04-28T17-20-47.mp4 m1macbook-air:
ssh m1@m1macbook-air "open ~/Downloads/swipev2-ios-simulator-demo-2026-04-28T17-20-47.mp4"
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

Capture fixed-skin simulator snapshots:

```bash
UDID="$(xcrun simctl list devices 'iPhone 16' | awk -F '[()]' '/iPhone 16 \(/ { print $2; exit }')"
for SKIN in bronze coral steel; do
  xcrun simctl terminate "$UDID" com.example.ActivityMonitorApp 2>/dev/null || true
  xcrun simctl launch "$UDID" com.example.ActivityMonitorApp --skin="$SKIN"
  sleep 2
  xcrun simctl io "$UDID" screenshot "/tmp/swipev2-$SKIN.png"
done
```

## Verify It

Current iOS verification on 2026-04-28:

- `xcodebuild test` passed on iPhone 16 simulator, iOS 18.6.
- Test suite: `ActionStreamStateTests`.
- Passing tests: 7.
- Build artifact:
  `/tmp/swipev2-ios-derived/Build/Products/Debug-iphonesimulator/ActivityMonitorApp.app`.
- Simulator screenshot:
  `/tmp/swipev2-bronze.png`, `/tmp/swipev2-coral.png`, `/tmp/swipev2-steel.png`.
- Simulator recording:
  `assets/demo/swipev2-ios-simulator-demo-2026-04-28T17-20-47.mp4`.
- Recording metadata: H.264, `1178x2556`, duration `29.710000` seconds, size
  `38,473,327` bytes.
- Sampled frames verified the demo sequence includes the `Bronze / Coral / Steel`
  skin cycle, demo-only chip feedback, detail sheet, later queue move, execute,
  discard, empty state, and reset.
- Snapshot verification confirmed the denser glass treatment removed the worst
  text bleed-through behind the active card across all 3 skins.
- The native app now shows a top skin picker with 3 built-in skins.
- The native app no longer shows 4 bottom action buttons, visible swipe-guide UI,
  or visible quick-action fallback UI.
- Background queue cards now render as compressed previews behind the active card.
- `tailscale file cp` exited successfully for Taildrop target `m1macbook-air`.
- SSH verification on `m1macbook-air` confirmed the new MP4 exists at
  `~/Downloads/swipev2-ios-simulator-demo-2026-04-28T17-20-47.mp4`.
- SSH `open` verification returned `OPENED` on `m1macbook-air`.

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

## Final Design Reference

- 当前 `swipeV2` iOS app 的最终设计参考页是
  `docs/ios-redesign/design.current-ios-app.html`。
- 对应说明稿是 `docs/ios-redesign/design.current-ios-app.md`。
- 下一步 `macApp skins` 收敛说明稿是
  `docs/ios-redesign/design.skin-shortlist.md`。
- 这份 shortlist 只保留 `Bronze Cinema`、`Coral Receipt`、
  `Steel Orchid` 三套皮肤，并明确去掉 `Swipe guide`、`Fallback` 与
  quick-action 菜单。
- `Batch 00` 就是当前 final iOS app 的 redesign 基线，它的状态文档是
  `docs/ios-redesign/batch-00-status.md`，当前状态是
  `CURRENT_IOS_APP_3_SKINS_NO_GUIDE_NO_FALLBACK_DOC_READY_2026-04-28`。
- `docs/ios-redesign/` 里的 Batch 01、Batch 02、Batch 03 都属于 redesign
  探索与候选方向，不代表当前 iOS app 已采用的最终版本，除非后续原生实现文档
  被明确更新。
- 还没有选定的是“未来如果重做 iOS app，要采用哪条 redesign 路线”，不是
  “当前 iOS app 有没有 final version”。
