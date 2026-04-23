# ActivityMonitorApp iOS

Native SwiftUI prototype for the Terminal Noir swipe island concept in
[`../DESIGN.md`](../DESIGN.md).

## Requirements

- Xcode 16 or newer.
- iOS Simulator runtime with iOS 17 or newer.
- A modern iPhone simulator. Local verification used iPhone 16 on iOS 18.6.

## Build

From the repository root:

```bash
xcodebuild build \
  -project island-swipe/ios/ActivityMonitorApp.xcodeproj \
  -scheme ActivityMonitorApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Test

```bash
xcodebuild test \
  -project island-swipe/ios/ActivityMonitorApp.xcodeproj \
  -scheme ActivityMonitorApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

The XCTest suite covers swipe threshold decisions, history capping, non-swipe
decision action availability, and session snapshot persistence.

## Run In Simulator

```bash
UDID="$(xcrun simctl list devices 'iPhone 16' | awk -F '[()]' '/iPhone 16 \\(/ { print $2; exit }')"
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b
xcodebuild build \
  -project island-swipe/ios/ActivityMonitorApp.xcodeproj \
  -scheme ActivityMonitorApp \
  -destination "id=$UDID" \
  -derivedDataPath /tmp/activity-monitor-derived
xcrun simctl install "$UDID" /tmp/activity-monitor-derived/Build/Products/Debug-iphonesimulator/ActivityMonitorApp.app
xcrun simctl launch "$UDID" com.example.ActivityMonitorApp
open -a Simulator
```

## Current Limits

- Simulator-only prototype. TestFlight, signing, and real-device haptic
  validation still need Apple Developer account setup.
- Baseline VoiceOver and Dynamic Type support exist, but real-device VoiceOver
  QA is still required before public distribution.
- `project.yml` is kept as project metadata, but `ActivityMonitorApp.xcodeproj`
  is the committed build artifact used by the commands above.
