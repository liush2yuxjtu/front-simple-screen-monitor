#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="ActivityMonitorButtonDemo"
EXT_NAME="ActivityMonitorLiveActivityExtension"
PROJECT_PATH="$ROOT_DIR/$APP_NAME.xcodeproj"
APP_DIR="$ROOT_DIR/$APP_NAME"
EXT_DIR="$ROOT_DIR/$EXT_NAME"
SHARED_DIR="$ROOT_DIR/Shared"
UITEST_NAME="ActivityMonitorButtonDemoUITests"
UITEST_DIR="$ROOT_DIR/$UITEST_NAME"
SIM_NAME="${SIM_NAME:-iPhone 16}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-/tmp/activity-monitor-button-demo-derived}"
MOVIES_DIR="${MOVIES_DIR:-$HOME/Movies}"
TIMESTAMP="$(date +%Y-%m-%dT%H-%M-%S)"
RECORDING_PATH="${RECORDING_PATH:-$MOVIES_DIR/activity-monitor-ios-v2-button-simulator-$TIMESTAMP.mp4}"
SCREENSHOT_PATH="${SCREENSHOT_PATH:-$MOVIES_DIR/activity-monitor-ios-v2-button-simulator-$TIMESTAMP.png}"
RUN_SELF_VERIFY=0
RUN_RECORD=0
TAILDROP_REQUESTED=0
TAILDROP_TARGET="${TAILDROP_TARGET:-}"

usage() {
  cat <<USAGE
Usage: $0 [--self-verify] [--record] [--taildrop [target]]

Default behavior generates the standalone iOS app and Xcode project.

Options:
  --self-verify       Generate, lint, build, install, launch, and inspect output.
  --record            Run self-verify, record simulator video, and inspect video.
  --taildrop [target] Run record flow and send the video with tailscale file cp.
  --help              Show this help.

Environment:
  SIM_NAME            Simulator name. Default: iPhone 16.
  DERIVED_DATA_PATH   xcodebuild derived data path.
  RECORDING_PATH      Output .mp4 path.
  TAILDROP_TARGET     Tailscale file cp target.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --self-verify)
      RUN_SELF_VERIFY=1
      shift
      ;;
    --record)
      RUN_SELF_VERIFY=1
      RUN_RECORD=1
      shift
      ;;
    --taildrop)
      RUN_SELF_VERIFY=1
      RUN_RECORD=1
      TAILDROP_REQUESTED=1
      if [[ $# -gt 1 && "$2" != --* ]]; then
        TAILDROP_TARGET="$2"
        shift 2
      else
        shift
      fi
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

mkdir -p "$PROJECT_PATH/project.xcworkspace" \
  "$PROJECT_PATH/xcshareddata/xcschemes" \
  "$APP_DIR" "$EXT_DIR" "$SHARED_DIR" "$UITEST_DIR"

cat > "$PROJECT_PATH/project.xcworkspace/contents.xcworkspacedata" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
XML

cat > "$PROJECT_PATH/xcshareddata/xcschemes/ActivityMonitorButtonDemo.xcscheme" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion = "1640" version = "1.7">
   <BuildAction parallelizeBuildables = "YES" buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting = "YES" buildForRunning = "YES" buildForProfiling = "YES" buildForArchiving = "YES" buildForAnalyzing = "YES">
            <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "010000000000000000000501" BuildableName = "ActivityMonitorButtonDemo.app" BlueprintName = "ActivityMonitorButtonDemo" ReferencedContainer = "container:ActivityMonitorButtonDemo.xcodeproj"></BuildableReference>
         </BuildActionEntry>
         <BuildActionEntry buildForTesting = "YES" buildForRunning = "NO" buildForProfiling = "NO" buildForArchiving = "NO" buildForAnalyzing = "YES">
            <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "010000000000000000000503" BuildableName = "ActivityMonitorButtonDemoUITests.xctest" BlueprintName = "ActivityMonitorButtonDemoUITests" ReferencedContainer = "container:ActivityMonitorButtonDemo.xcodeproj"></BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction buildConfiguration = "Debug" selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
         <TestableReference skipped = "NO">
            <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "010000000000000000000503" BuildableName = "ActivityMonitorButtonDemoUITests.xctest" BlueprintName = "ActivityMonitorButtonDemoUITests" ReferencedContainer = "container:ActivityMonitorButtonDemo.xcodeproj"></BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction buildConfiguration = "Debug" selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle = "0" useCustomWorkingDirectory = "NO" ignoresPersistentStateOnLaunch = "NO" debugDocumentVersioning = "YES" debugServiceExtension = "internal" allowLocationSimulation = "YES">
      <BuildableProductRunnable runnableDebuggingMode = "0">
         <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "010000000000000000000501" BuildableName = "ActivityMonitorButtonDemo.app" BlueprintName = "ActivityMonitorButtonDemo" ReferencedContainer = "container:ActivityMonitorButtonDemo.xcodeproj"></BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction buildConfiguration = "Release" shouldUseLaunchSchemeArgsEnv = "YES" savedToolIdentifier = "" useCustomWorkingDirectory = "NO" debugDocumentVersioning = "YES">
      <BuildableProductRunnable runnableDebuggingMode = "0">
         <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "010000000000000000000501" BuildableName = "ActivityMonitorButtonDemo.app" BlueprintName = "ActivityMonitorButtonDemo" ReferencedContainer = "container:ActivityMonitorButtonDemo.xcodeproj"></BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction buildConfiguration = "Debug"></AnalyzeAction>
   <ArchiveAction buildConfiguration = "Release" revealArchiveInOrganizer = "YES"></ArchiveAction>
</Scheme>
XML

cat > "$SHARED_DIR/ActivityMonitorAttributes.swift" <<'SWIFT'
import ActivityKit
import Foundation
import SwiftUI

struct ActivityMonitorAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var requester: String
        var actionSummary: String
        var riskLevel: String
        var decision: Decision
        var updatedAt: Date
    }

    enum Decision: String, Codable, Hashable {
        case pending = "PENDING"
        case allowed = "ALLOWED"
        case blocked = "BLOCKED"

        var tint: Color {
            switch self {
            case .pending: return .orange
            case .allowed: return .green
            case .blocked: return .red
            }
        }
    }

    var requestID: String
}
SWIFT

cat > "$SHARED_DIR/ActivityMonitorDecisionStore.swift" <<'SWIFT'
import Foundation

enum ActivityMonitorDecisionStore {
    private static let lastDecisionKey = "activity-monitor.last-decision"

    static func record(_ decision: ActivityMonitorAttributes.Decision, requestID: String) {
        let payload = "\(requestID):\(decision.rawValue):\(Date().timeIntervalSince1970)"
        UserDefaults.standard.set(payload, forKey: lastDecisionKey)
    }

    static func lastDecisionSummary() -> String {
        UserDefaults.standard.string(forKey: lastDecisionKey) ?? "No decision recorded yet"
    }
}
SWIFT

cat > "$SHARED_DIR/ActivityMonitorIntents.swift" <<'SWIFT'
import ActivityKit
import AppIntents
import Foundation

struct AllowRequestIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "ALLOW"
    static var description = IntentDescription("Allow the pending Activity Monitor request.")
    static var openAppWhenRun = false

    @Parameter(title: "Request ID")
    var requestID: String

    init() {
        self.requestID = ""
    }

    init(requestID: String) {
        self.requestID = requestID
    }

    func perform() async throws -> some IntentResult {
        await ActivityMonitorIntentActions.decide(requestID: requestID, decision: .allowed)
        return .result()
    }
}

struct BlockRequestIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "BLOCK"
    static var description = IntentDescription("Block the pending Activity Monitor request.")
    static var openAppWhenRun = false

    @Parameter(title: "Request ID")
    var requestID: String

    init() {
        self.requestID = ""
    }

    init(requestID: String) {
        self.requestID = requestID
    }

    func perform() async throws -> some IntentResult {
        await ActivityMonitorIntentActions.decide(requestID: requestID, decision: .blocked)
        return .result()
    }
}

enum ActivityMonitorIntentActions {
    static func decide(
        requestID: String,
        decision: ActivityMonitorAttributes.Decision
    ) async {
        guard let activity = Activity<ActivityMonitorAttributes>.activities.first(where: {
            $0.attributes.requestID == requestID
        }) else {
            ActivityMonitorDecisionStore.record(decision, requestID: requestID)
            return
        }

        var state = activity.content.state
        state.decision = decision
        state.updatedAt = Date()

        await activity.update(ActivityContent(state: state, staleDate: nil))
        ActivityMonitorDecisionStore.record(decision, requestID: requestID)
    }
}
SWIFT

cat > "$APP_DIR/ActivityMonitorButtonDemoApp.swift" <<'SWIFT'
import SwiftUI

@main
struct ActivityMonitorButtonDemoApp: App {
    var body: some Scene {
        WindowGroup {
            MonitorDashboardView()
        }
    }
}
SWIFT

cat > "$APP_DIR/MonitorDashboardBackend.swift" <<'SWIFT'
import ActivityKit
import Foundation
import SwiftUI

@MainActor
final class MonitorDashboardBackend: ObservableObject {
    @Published var currentState = ActivityMonitorAttributes.ContentState(
        requester: "Screen Agent",
        actionSummary: "Read active browser tab title and prepare summary",
        riskLevel: "MED",
        decision: .pending,
        updatedAt: Date()
    )
    @Published var liveActivityID: String?
    @Published var statusLine = "Ready to start a Live Activity"
    @Published var lastDecisionSummary = ActivityMonitorDecisionStore.lastDecisionSummary()

    private let requestID = UUID().uuidString

    var hasLiveActivity: Bool {
        liveActivityID != nil
    }

    func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            statusLine = "Live Activities are disabled in Settings"
            return
        }

        let attributes = ActivityMonitorAttributes(requestID: requestID)
        let content = ActivityContent(state: currentState, staleDate: nil)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            liveActivityID = activity.id
            statusLine = "Live Activity started. Expand Dynamic Island for ALLOW/BLOCK."
        } catch {
            statusLine = "Failed to start Live Activity: \(error.localizedDescription)"
        }
    }

    func decide(_ decision: ActivityMonitorAttributes.Decision) {
        currentState.decision = decision
        currentState.updatedAt = Date()
        ActivityMonitorDecisionStore.record(decision, requestID: requestID)
        lastDecisionSummary = ActivityMonitorDecisionStore.lastDecisionSummary()
        statusLine = "In-app decision recorded: \(decision.rawValue)"

        guard let liveActivityID,
              let activity = Activity<ActivityMonitorAttributes>.activities.first(where: {
                  $0.id == liveActivityID
              }) else {
            return
        }

        Task {
            await activity.update(ActivityContent(state: currentState, staleDate: nil))
        }
    }

    func runRecordingDemoIfNeeded() async {
        guard ProcessInfo.processInfo.arguments.contains("--recording-demo") else {
            return
        }

        statusLine = "Recording demo will start automatically"
        try? await Task.sleep(for: .seconds(1))
        startLiveActivity()
        try? await Task.sleep(for: .seconds(2))
        decide(.allowed)
        try? await Task.sleep(for: .seconds(2))
        decide(.blocked)
    }
}
SWIFT

cat > "$APP_DIR/MonitorDashboardFrontend.swift" <<'SWIFT'
import SwiftUI

struct MonitorDashboardView: View {
    @StateObject private var backend = MonitorDashboardBackend()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            ZStack {
                MonitorBackdrop(reduceMotion: reduceMotion)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        commandHeader
                        requestPanel
                        decisionDock
                        statusStrip
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 26)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .task {
                await backend.runRecordingDemoIfNeeded()
            }
        }
    }

    private var commandHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Activity Monitor")
                        .font(.system(.largeTitle, design: .rounded, weight: .black))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text("Dynamic Island permission desk")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.64))
                }

                Spacer(minLength: 12)

                DecisionBadge(decision: backend.currentState.decision)
            }

            HStack(spacing: 10) {
                MetricTile(title: "REQUEST", value: backend.currentState.riskLevel, tint: .orange)
                MetricTile(title: "SURFACE", value: backend.hasLiveActivity ? "LIVE" : "READY", tint: .cyan)
                MetricTile(title: "STATE", value: backend.currentState.decision.rawValue, tint: backend.currentState.decision.tint)
            }
        }
        .padding(18)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var requestPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.10), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: 0.68)
                        .stroke(.orange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-92))
                    VStack(spacing: 1) {
                        Text(backend.currentState.riskLevel)
                            .font(.caption.weight(.black))
                        Text("RISK")
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    .foregroundStyle(.white)
                }
                .frame(width: 74, height: 74)

                VStack(alignment: .leading, spacing: 6) {
                    Label(backend.currentState.requester, systemImage: "lock.shield.fill")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Permission request")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.orange)
                        .textCase(.uppercase)
                }
            }

            Text(backend.currentState.actionSummary)
                .font(.system(.title2, design: .rounded, weight: .black))
                .foregroundStyle(.white)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Image(systemName: "sparkles.rectangle.stack.fill")
                Text("Expanded Dynamic Island exposes the final ALLOW/BLOCK controls.")
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(.white.opacity(0.60))
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(red: 0.07, green: 0.083, blue: 0.095))
        }
        .overlay(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(backend.currentState.decision.tint.opacity(0.28), lineWidth: 1)
        }
    }

    private var decisionDock: some View {
        VStack(spacing: 12) {
            Button {
                backend.startLiveActivity()
            } label: {
                Label("Start Live Activity", systemImage: "dot.radiowaves.left.and.right")
                    .font(.headline.weight(.black))
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)
            .accessibilityLabel("Start Live Activity")

            HStack(spacing: 12) {
                DecisionButton(title: "BLOCK", systemImage: "xmark.shield.fill", tint: .red) {
                    backend.decide(.blocked)
                }
                DecisionButton(title: "ALLOW", systemImage: "checkmark.shield.fill", tint: .green) {
                    backend.decide(.allowed)
                }
            }
        }
    }

    private var statusStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Status", systemImage: "waveform.path.ecg")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                Text(backend.currentState.updatedAt, style: .time)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.54))
            }
            Text(backend.statusLine)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.76))
                .fixedSize(horizontal: false, vertical: true)
            Text("Last stored decision: \(backend.lastDecisionSummary)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.48))
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct MonitorBackdrop: View {
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            Color(red: 0.018, green: 0.022, blue: 0.027)
            LinearGradient(
                colors: [
                    Color(red: 0.11, green: 0.08, blue: 0.045),
                    Color(red: 0.018, green: 0.022, blue: 0.027),
                    Color(red: 0.02, green: 0.07, blue: 0.075)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            TimelineView(.animation(minimumInterval: 2.5, paused: reduceMotion)) { timeline in
                let pulse = reduceMotion ? 0 : sin(timeline.date.timeIntervalSince1970) * 0.04
                Circle()
                    .fill(.cyan.opacity(0.10 + pulse))
                    .blur(radius: 52)
                    .frame(width: 210, height: 210)
                    .offset(x: 130, y: -230)
            }
        }
    }
}

private struct MetricTile: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(.white.opacity(0.42))
            Text(value)
                .font(.caption.weight(.black))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct DecisionBadge: View {
    let decision: ActivityMonitorAttributes.Decision

    var body: some View {
        Image(systemName: decision == .allowed ? "checkmark.shield.fill" : "lock.shield.fill")
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(.white, decision.tint)
            .frame(width: 52, height: 52)
            .background(decision.tint.opacity(0.18), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            .accessibilityLabel("Decision \(decision.rawValue)")
    }
}

private struct DecisionButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline.weight(.black))
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .foregroundStyle(.white)
        .background(tint.opacity(0.22), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(0.42), lineWidth: 1)
        }
        .scaleEffect(1)
        .accessibilityLabel(title)
    }
}
SWIFT

cat > "$APP_DIR/MonitorDashboardView.swift" <<'SWIFT'
import ActivityKit
import SwiftUI

@MainActor
final class MonitorDashboardModel: ObservableObject {
    @Published var currentState = ActivityMonitorAttributes.ContentState(
        requester: "Screen Agent",
        actionSummary: "Read active browser tab title and prepare summary",
        riskLevel: "MED",
        decision: .pending,
        updatedAt: Date()
    )
    @Published var liveActivityID: String?
    @Published var statusLine = "Ready to start a Live Activity"

    private let requestID = UUID().uuidString

    func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            statusLine = "Live Activities are disabled in Settings"
            return
        }

        let attributes = ActivityMonitorAttributes(requestID: requestID)
        let content = ActivityContent(state: currentState, staleDate: nil)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            liveActivityID = activity.id
            statusLine = "Live Activity started. Expand Dynamic Island for ALLOW/BLOCK."
        } catch {
            statusLine = "Failed to start Live Activity: \(error.localizedDescription)"
        }
    }

    func decide(_ decision: ActivityMonitorAttributes.Decision) {
        currentState.decision = decision
        currentState.updatedAt = Date()
        ActivityMonitorDecisionStore.record(decision, requestID: requestID)
        statusLine = "In-app decision recorded: \(decision.rawValue)"

        guard let liveActivityID,
              let activity = Activity<ActivityMonitorAttributes>.activities.first(where: {
                  $0.id == liveActivityID
              }) else {
            return
        }

        Task {
            await activity.update(ActivityContent(state: currentState, staleDate: nil))
        }
    }

    func runRecordingDemoIfNeeded() async {
        guard ProcessInfo.processInfo.arguments.contains("--recording-demo") else {
            return
        }

        statusLine = "Recording demo will start automatically"
        try? await Task.sleep(for: .seconds(1))
        startLiveActivity()
        try? await Task.sleep(for: .seconds(2))
        decide(.allowed)
        try? await Task.sleep(for: .seconds(2))
        decide(.blocked)
    }
}

struct MonitorDashboardView: View {
    @StateObject private var model = MonitorDashboardModel()

    var body: some View {
        NavigationStack {
            ZStack {
                dashboardBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        heroCard
                        requestCard
                        actionButtons
                        statusCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 22)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .task {
                await model.runRecordingDemoIfNeeded()
            }
        }
    }

    private var dashboardBackground: some View {
        ZStack {
            Color(red: 0.018, green: 0.021, blue: 0.028)
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.08, blue: 0.10),
                    Color(red: 0.018, green: 0.021, blue: 0.028),
                    Color(red: 0.04, green: 0.035, blue: 0.025)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var heroCard: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(0.10))
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white, model.currentState.decision.tint)
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 4) {
                Text("Activity Monitor")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text("Dynamic Island permission gate")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.62))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: 8)

            Text(model.currentState.decision.rawValue)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(model.currentState.decision.tint)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(model.currentState.decision.tint.opacity(0.16), in: Capsule())
                .overlay {
                    Capsule().stroke(model.currentState.decision.tint.opacity(0.34), lineWidth: 1)
                }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        }
    }

    private var requestCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 5) {
                    Label(model.currentState.requester, systemImage: "sparkles.rectangle.stack.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.76))
                    Text("Pending AI action")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.orange)
                        .textCase(.uppercase)
                }

                Spacer(minLength: 10)

                riskDial
            }

            Text(model.currentState.actionSummary)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                infoChip("Risk \(model.currentState.riskLevel)", color: .orange)
                infoChip(model.currentState.decision.rawValue, color: model.currentState.decision.tint)
                Spacer(minLength: 0)
                Text(model.currentState.updatedAt, style: .time)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.46))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.11, green: 0.13, blue: 0.15),
                            Color(red: 0.045, green: 0.052, blue: 0.063)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        }
    }

    private var riskDial: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.10), lineWidth: 9)
            Circle()
                .trim(from: 0, to: 0.68)
                .stroke(.orange, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                .rotationEffect(.degrees(-92))
            VStack(spacing: 0) {
                Text(model.currentState.riskLevel)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.white)
                Text("RISK")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.white.opacity(0.42))
            }
        }
        .frame(width: 68, height: 68)
    }

    private func infoChip(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.caption2.weight(.heavy))
            .foregroundStyle(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(color.opacity(0.14), in: Capsule())
            .overlay {
                Capsule().stroke(color.opacity(0.25), lineWidth: 1)
            }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                model.startLiveActivity()
            } label: {
                Label("Start Live Activity", systemImage: "dot.radiowaves.left.and.right")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)
            .controlSize(.large)

            HStack(spacing: 12) {
                DecisionButton(
                    title: "BLOCK",
                    systemImage: "xmark.shield.fill",
                    tint: .red
                ) {
                    model.decide(.blocked)
                }

                DecisionButton(
                    title: "ALLOW",
                    systemImage: "checkmark.shield.fill",
                    tint: .green
                ) {
                    model.decide(.allowed)
                }
            }
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Status", systemImage: "waveform.path.ecg")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                Circle()
                    .fill(model.currentState.decision.tint)
                    .frame(width: 8, height: 8)
            }
            Text(model.statusLine)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.74))
                .fixedSize(horizontal: false, vertical: true)
            Text("Last stored decision: \(ActivityMonitorDecisionStore.lastDecisionSummary())")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.46))
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }
}

private struct DecisionButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline.weight(.heavy))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .foregroundStyle(.white)
        .background(tint.opacity(0.22), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(0.44), lineWidth: 1)
        }
    }
}
SWIFT
rm -f "$APP_DIR/MonitorDashboardView.swift"

cat > "$EXT_DIR/ActivityMonitorLiveActivity.swift" <<'SWIFT'
import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

struct ActivityMonitorLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ActivityMonitorAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(Color.black)
                .activitySystemActionForegroundColor(Color.white)
                .widgetURL(deepLinkURL(for: context))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 5) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(context.state.decision.tint)
                        Text(context.state.requester)
                            .lineLimit(1)
                    }
                    .font(.caption.weight(.bold))
                }

                DynamicIslandExpandedRegion(.trailing) {
                    WidgetPill("Risk \(context.state.riskLevel)", tint: .orange)
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text("AI ACTION REQUEST")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.secondary)
                        Text(context.state.actionSummary)
                            .font(.subheadline.weight(.bold))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                        Text(context.state.decision.rawValue)
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(context.state.decision.tint)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 10) {
                        Button(intent: BlockRequestIntent(requestID: context.attributes.requestID)) {
                            Label("BLOCK", systemImage: "xmark.shield.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .tint(.red)

                        Button(intent: AllowRequestIntent(requestID: context.attributes.requestID)) {
                            Label("ALLOW", systemImage: "checkmark.shield.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .tint(.green)
                    }
                    .font(.caption.weight(.heavy))
                    .buttonStyle(.borderedProminent)
                }
            } compactLeading: {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(context.state.decision.tint)
            } compactTrailing: {
                Text(context.state.decision == .pending ? context.state.riskLevel : context.state.decision.rawValue.prefix(2).uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(context.state.decision.tint)
            } minimal: {
                Image(systemName: context.state.decision == .allowed ? "checkmark.shield.fill" : "shield.fill")
                    .foregroundStyle(context.state.decision.tint)
            }
            .widgetURL(deepLinkURL(for: context))
            .keylineTint(context.state.decision.tint)
        }
    }
}

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<ActivityMonitorAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Label(context.state.requester, systemImage: "lock.shield.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                WidgetPill(context.state.decision.rawValue, tint: context.state.decision.tint)
            }

            Text(context.state.actionSummary)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))
                .lineLimit(2)

            HStack {
                WidgetPill("Risk \(context.state.riskLevel)", tint: .orange)
                Spacer()
                Text(context.state.updatedAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
        .padding(16)
        .background {
            LinearGradient(
                colors: [
                    Color(red: 0.09, green: 0.10, blue: 0.12),
                    Color(red: 0.01, green: 0.012, blue: 0.018)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

private struct WidgetPill: View {
    let title: String
    let tint: Color

    init(_ title: String, tint: Color) {
        self.title = title
        self.tint = tint
    }

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .heavy))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.18), in: Capsule())
    }
}

private func deepLinkURL(for context: ActivityViewContext<ActivityMonitorAttributes>) -> URL? {
    URL(string: "activitymonitor://request/\(context.attributes.requestID)")
}

@main
struct ActivityMonitorWidgetBundle: WidgetBundle {
    var body: some Widget {
        ActivityMonitorLiveActivity()
    }
}
SWIFT

cat > "$UITEST_DIR/DynamicIslandExpandedUITests.swift" <<'SWIFT'
import XCTest

final class DynamicIslandExpandedUITests: XCTestCase {
    func testExpandedDynamicIslandShowsDecisionButtons() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--recording-demo"]
        app.launch()
        sleep(2)

        XCUIDevice.shared.press(.home)
        sleep(1)

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let island = springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.045))
        island.press(forDuration: 1.5)
        sleep(2)

        let allowExists = springboard.buttons["ALLOW"].exists || springboard.staticTexts["ALLOW"].exists
        let blockExists = springboard.buttons["BLOCK"].exists || springboard.staticTexts["BLOCK"].exists
        XCTAssertTrue(allowExists, "Expanded Dynamic Island should expose ALLOW")
        XCTAssertTrue(blockExists, "Expanded Dynamic Island should expose BLOCK")
    }
}
SWIFT

cat > "$APP_DIR/Info.plist" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key>
  <string>Activity Monitor</string>
  <key>CFBundleExecutable</key>
  <string>$(EXECUTABLE_NAME)</string>
  <key>CFBundleIdentifier</key>
  <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$(PRODUCT_NAME)</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$(MARKETING_VERSION)</string>
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLName</key>
      <string>ActivityMonitorDeepLink</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>activitymonitor</string>
      </array>
    </dict>
  </array>
  <key>CFBundleVersion</key>
  <string>$(CURRENT_PROJECT_VERSION)</string>
  <key>LSRequiresIPhoneOS</key>
  <true/>
  <key>NSSupportsLiveActivities</key>
  <true/>
  <key>UIApplicationSceneManifest</key>
  <dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
  </dict>
  <key>UILaunchScreen</key>
  <dict/>
  <key>UISupportedInterfaceOrientations</key>
  <array>
    <string>UIInterfaceOrientationPortrait</string>
  </array>
</dict>
</plist>
XML

cat > "$EXT_DIR/Info.plist" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key>
  <string>Activity Monitor Live Activity</string>
  <key>CFBundleExecutable</key>
  <string>$(EXECUTABLE_NAME)</string>
  <key>CFBundleIdentifier</key>
  <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$(PRODUCT_NAME)</string>
  <key>CFBundlePackageType</key>
  <string>XPC!</string>
  <key>CFBundleShortVersionString</key>
  <string>$(MARKETING_VERSION)</string>
  <key>CFBundleVersion</key>
  <string>$(CURRENT_PROJECT_VERSION)</string>
  <key>NSExtension</key>
  <dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.widgetkit-extension</string>
  </dict>
</dict>
</plist>
XML

cat > "$PROJECT_PATH/project.pbxproj" <<'PBX'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		010000000000000000000001 /* ActivityMonitorButtonDemoApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = 010000000000000000000101 /* ActivityMonitorButtonDemoApp.swift */; };
		010000000000000000000002 /* MonitorDashboardBackend.swift in Sources */ = {isa = PBXBuildFile; fileRef = 010000000000000000000102 /* MonitorDashboardBackend.swift */; };
		01000000000000000000000B /* MonitorDashboardFrontend.swift in Sources */ = {isa = PBXBuildFile; fileRef = 010000000000000000000110 /* MonitorDashboardFrontend.swift */; };
		010000000000000000000003 /* ActivityMonitorAttributes.swift in Sources */ = {isa = PBXBuildFile; fileRef = 010000000000000000000103 /* ActivityMonitorAttributes.swift */; };
		010000000000000000000004 /* ActivityMonitorDecisionStore.swift in Sources */ = {isa = PBXBuildFile; fileRef = 010000000000000000000104 /* ActivityMonitorDecisionStore.swift */; };
		010000000000000000000005 /* ActivityMonitorAttributes.swift in Sources */ = {isa = PBXBuildFile; fileRef = 010000000000000000000103 /* ActivityMonitorAttributes.swift */; };
		010000000000000000000006 /* ActivityMonitorDecisionStore.swift in Sources */ = {isa = PBXBuildFile; fileRef = 010000000000000000000104 /* ActivityMonitorDecisionStore.swift */; };
		010000000000000000000007 /* ActivityMonitorIntents.swift in Sources */ = {isa = PBXBuildFile; fileRef = 010000000000000000000105 /* ActivityMonitorIntents.swift */; };
		010000000000000000000008 /* ActivityMonitorLiveActivity.swift in Sources */ = {isa = PBXBuildFile; fileRef = 010000000000000000000106 /* ActivityMonitorLiveActivity.swift */; };
		010000000000000000000009 /* ActivityMonitorLiveActivityExtension.appex in Embed App Extensions */ = {isa = PBXBuildFile; fileRef = 010000000000000000000202 /* ActivityMonitorLiveActivityExtension.appex */; settings = {ATTRIBUTES = (RemoveHeadersOnCopy, ); }; };
		01000000000000000000000A /* DynamicIslandExpandedUITests.swift in Sources */ = {isa = PBXBuildFile; fileRef = 010000000000000000000109 /* DynamicIslandExpandedUITests.swift */; };
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */
		010000000000000000000301 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = 010000000000000000000401 /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = 010000000000000000000502;
			remoteInfo = ActivityMonitorLiveActivityExtension;
		};
		010000000000000000000303 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = 010000000000000000000401 /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = 010000000000000000000501;
			remoteInfo = ActivityMonitorButtonDemo;
		};
/* End PBXContainerItemProxy section */

/* Begin PBXCopyFilesBuildPhase section */
		010000000000000000000601 /* Embed App Extensions */ = {
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 13;
			files = (
				010000000000000000000009 /* ActivityMonitorLiveActivityExtension.appex in Embed App Extensions */,
			);
			name = "Embed App Extensions";
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXCopyFilesBuildPhase section */

/* Begin PBXFileReference section */
		010000000000000000000101 /* ActivityMonitorButtonDemoApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ActivityMonitorButtonDemoApp.swift; sourceTree = "<group>"; };
		010000000000000000000102 /* MonitorDashboardBackend.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MonitorDashboardBackend.swift; sourceTree = "<group>"; };
		010000000000000000000103 /* ActivityMonitorAttributes.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ActivityMonitorAttributes.swift; sourceTree = "<group>"; };
		010000000000000000000104 /* ActivityMonitorDecisionStore.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ActivityMonitorDecisionStore.swift; sourceTree = "<group>"; };
		010000000000000000000105 /* ActivityMonitorIntents.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ActivityMonitorIntents.swift; sourceTree = "<group>"; };
		010000000000000000000106 /* ActivityMonitorLiveActivity.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ActivityMonitorLiveActivity.swift; sourceTree = "<group>"; };
		010000000000000000000107 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
		010000000000000000000108 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
		010000000000000000000109 /* DynamicIslandExpandedUITests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DynamicIslandExpandedUITests.swift; sourceTree = "<group>"; };
		010000000000000000000110 /* MonitorDashboardFrontend.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MonitorDashboardFrontend.swift; sourceTree = "<group>"; };
		010000000000000000000201 /* ActivityMonitorButtonDemo.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = ActivityMonitorButtonDemo.app; sourceTree = BUILT_PRODUCTS_DIR; };
		010000000000000000000202 /* ActivityMonitorLiveActivityExtension.appex */ = {isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = ActivityMonitorLiveActivityExtension.appex; sourceTree = BUILT_PRODUCTS_DIR; };
		010000000000000000000203 /* ActivityMonitorButtonDemoUITests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = ActivityMonitorButtonDemoUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		010000000000000000000701 /* Frameworks */ = {isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; };
		010000000000000000000702 /* Frameworks */ = {isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; };
		010000000000000000000703 /* Frameworks */ = {isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; };
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		010000000000000000000801 = {
			isa = PBXGroup;
			children = (
				010000000000000000000802 /* ActivityMonitorButtonDemo */,
				010000000000000000000803 /* Shared */,
				010000000000000000000804 /* ActivityMonitorLiveActivityExtension */,
				010000000000000000000806 /* ActivityMonitorButtonDemoUITests */,
				010000000000000000000805 /* Products */,
			);
			sourceTree = "<group>";
		};
		010000000000000000000802 /* ActivityMonitorButtonDemo */ = {
			isa = PBXGroup;
			children = (
				010000000000000000000101 /* ActivityMonitorButtonDemoApp.swift */,
				010000000000000000000102 /* MonitorDashboardBackend.swift */,
				010000000000000000000110 /* MonitorDashboardFrontend.swift */,
				010000000000000000000107 /* Info.plist */,
			);
			path = ActivityMonitorButtonDemo;
			sourceTree = "<group>";
		};
		010000000000000000000803 /* Shared */ = {
			isa = PBXGroup;
			children = (
				010000000000000000000103 /* ActivityMonitorAttributes.swift */,
				010000000000000000000104 /* ActivityMonitorDecisionStore.swift */,
				010000000000000000000105 /* ActivityMonitorIntents.swift */,
			);
			path = Shared;
			sourceTree = "<group>";
		};
		010000000000000000000804 /* ActivityMonitorLiveActivityExtension */ = {
			isa = PBXGroup;
			children = (
				010000000000000000000106 /* ActivityMonitorLiveActivity.swift */,
				010000000000000000000108 /* Info.plist */,
			);
			path = ActivityMonitorLiveActivityExtension;
			sourceTree = "<group>";
		};
		010000000000000000000805 /* Products */ = {
			isa = PBXGroup;
			children = (
				010000000000000000000201 /* ActivityMonitorButtonDemo.app */,
				010000000000000000000202 /* ActivityMonitorLiveActivityExtension.appex */,
				010000000000000000000203 /* ActivityMonitorButtonDemoUITests.xctest */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		010000000000000000000806 /* ActivityMonitorButtonDemoUITests */ = {
			isa = PBXGroup;
			children = (
				010000000000000000000109 /* DynamicIslandExpandedUITests.swift */,
			);
			path = ActivityMonitorButtonDemoUITests;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		010000000000000000000501 /* ActivityMonitorButtonDemo */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 010000000000000000000901 /* Build configuration list for PBXNativeTarget "ActivityMonitorButtonDemo" */;
			buildPhases = (
				010000000000000000000A01 /* Sources */,
				010000000000000000000701 /* Frameworks */,
				010000000000000000000B01 /* Resources */,
				010000000000000000000601 /* Embed App Extensions */,
			);
			buildRules = ();
			dependencies = (
				010000000000000000000302 /* PBXTargetDependency */,
			);
			name = ActivityMonitorButtonDemo;
			productName = ActivityMonitorButtonDemo;
			productReference = 010000000000000000000201 /* ActivityMonitorButtonDemo.app */;
			productType = "com.apple.product-type.application";
		};
		010000000000000000000502 /* ActivityMonitorLiveActivityExtension */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 010000000000000000000902 /* Build configuration list for PBXNativeTarget "ActivityMonitorLiveActivityExtension" */;
			buildPhases = (
				010000000000000000000A02 /* Sources */,
				010000000000000000000702 /* Frameworks */,
				010000000000000000000B02 /* Resources */,
			);
			buildRules = ();
			dependencies = ();
			name = ActivityMonitorLiveActivityExtension;
			productName = ActivityMonitorLiveActivityExtension;
			productReference = 010000000000000000000202 /* ActivityMonitorLiveActivityExtension.appex */;
			productType = "com.apple.product-type.app-extension";
		};
		010000000000000000000503 /* ActivityMonitorButtonDemoUITests */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 010000000000000000000903 /* Build configuration list for PBXNativeTarget "ActivityMonitorButtonDemoUITests" */;
			buildPhases = (
				010000000000000000000A03 /* Sources */,
				010000000000000000000703 /* Frameworks */,
				010000000000000000000B03 /* Resources */,
			);
			buildRules = ();
			dependencies = (
				010000000000000000000304 /* PBXTargetDependency */,
			);
			name = ActivityMonitorButtonDemoUITests;
			productName = ActivityMonitorButtonDemoUITests;
			productReference = 010000000000000000000203 /* ActivityMonitorButtonDemoUITests.xctest */;
			productType = "com.apple.product-type.bundle.ui-testing";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		010000000000000000000401 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1640;
				LastUpgradeCheck = 1640;
				TargetAttributes = {
					010000000000000000000501 = {CreatedOnToolsVersion = 16.4; };
					010000000000000000000502 = {CreatedOnToolsVersion = 16.4; };
					010000000000000000000503 = {CreatedOnToolsVersion = 16.4; TestTargetID = 010000000000000000000501; };
				};
			};
			buildConfigurationList = 010000000000000000000900 /* Build configuration list for PBXProject "ActivityMonitorButtonDemo" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (en, Base, );
			mainGroup = 010000000000000000000801;
			productRefGroup = 010000000000000000000805 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				010000000000000000000501 /* ActivityMonitorButtonDemo */,
				010000000000000000000502 /* ActivityMonitorLiveActivityExtension */,
				010000000000000000000503 /* ActivityMonitorButtonDemoUITests */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		010000000000000000000B01 /* Resources */ = {isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; };
		010000000000000000000B02 /* Resources */ = {isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; };
		010000000000000000000B03 /* Resources */ = {isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; };
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		010000000000000000000A01 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				010000000000000000000001 /* ActivityMonitorButtonDemoApp.swift in Sources */,
				010000000000000000000002 /* MonitorDashboardBackend.swift in Sources */,
				01000000000000000000000B /* MonitorDashboardFrontend.swift in Sources */,
				010000000000000000000003 /* ActivityMonitorAttributes.swift in Sources */,
				010000000000000000000004 /* ActivityMonitorDecisionStore.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		010000000000000000000A02 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				010000000000000000000005 /* ActivityMonitorAttributes.swift in Sources */,
				010000000000000000000006 /* ActivityMonitorDecisionStore.swift in Sources */,
				010000000000000000000007 /* ActivityMonitorIntents.swift in Sources */,
				010000000000000000000008 /* ActivityMonitorLiveActivity.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
		010000000000000000000A03 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				01000000000000000000000A /* DynamicIslandExpandedUITests.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
		010000000000000000000302 /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			target = 010000000000000000000502 /* ActivityMonitorLiveActivityExtension */;
			targetProxy = 010000000000000000000301 /* PBXContainerItemProxy */;
		};
		010000000000000000000304 /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			target = 010000000000000000000501 /* ActivityMonitorButtonDemo */;
			targetProxy = 010000000000000000000303 /* PBXContainerItemProxy */;
		};
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
		010000000000000000000C01 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = ("DEBUG=1", "$(inherited)", );
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		010000000000000000000C02 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		010000000000000000000C03 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = "";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = ActivityMonitorButtonDemo/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks", );
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.ActivityMonitorButtonDemo;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = 1;
			};
			name = Debug;
		};
		010000000000000000000C04 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = "";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = ActivityMonitorButtonDemo/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks", );
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.ActivityMonitorButtonDemo;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = 1;
			};
			name = Release;
		};
		010000000000000000000C05 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				APPLICATION_EXTENSION_API_ONLY = YES;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = ActivityMonitorLiveActivityExtension/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks", );
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.ActivityMonitorButtonDemo.LiveActivityExtension;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SKIP_INSTALL = YES;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = 1;
			};
			name = Debug;
		};
		010000000000000000000C06 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				APPLICATION_EXTENSION_API_ONLY = YES;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = ActivityMonitorLiveActivityExtension/Info.plist;
				LD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks", );
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.ActivityMonitorButtonDemo.LiveActivityExtension;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SKIP_INSTALL = YES;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = 1;
			};
			name = Release;
		};
		010000000000000000000C07 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks", "@loader_path/Frameworks", );
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.ActivityMonitorButtonDemoUITests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = 1;
				TEST_TARGET_NAME = ActivityMonitorButtonDemo;
			};
			name = Debug;
		};
		010000000000000000000C08 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks", "@loader_path/Frameworks", );
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.ActivityMonitorButtonDemoUITests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = 1;
				TEST_TARGET_NAME = ActivityMonitorButtonDemo;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		010000000000000000000900 /* Build configuration list for PBXProject "ActivityMonitorButtonDemo" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				010000000000000000000C01 /* Debug */,
				010000000000000000000C02 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		010000000000000000000901 /* Build configuration list for PBXNativeTarget "ActivityMonitorButtonDemo" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				010000000000000000000C03 /* Debug */,
				010000000000000000000C04 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		010000000000000000000902 /* Build configuration list for PBXNativeTarget "ActivityMonitorLiveActivityExtension" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				010000000000000000000C05 /* Debug */,
				010000000000000000000C06 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		010000000000000000000903 /* Build configuration list for PBXNativeTarget "ActivityMonitorButtonDemoUITests" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				010000000000000000000C07 /* Debug */,
				010000000000000000000C08 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 010000000000000000000401 /* Project object */;
}
PBX

chmod +x "$ROOT_DIR/build-ios-v2-button-demo.sh"

echo "Generated $PROJECT_PATH"
echo "Build with:"
echo "xcodebuild build -project $PROJECT_PATH -scheme $APP_NAME -destination 'platform=iOS Simulator,name=iPhone 16'"

select_simulator_udid() {
  xcrun simctl list devices "$SIM_NAME" |
    awk -F '[()]' -v name="$SIM_NAME" '$0 ~ name " \\(" && $0 !~ /unavailable/ { print $2; exit }'
}

assert_file_contains() {
  local file="$1"
  local pattern="$2"
  if ! grep -q "$pattern" "$file"; then
    echo "verify failed: $file does not contain $pattern" >&2
    exit 1
  fi
}

self_verify() {
  echo "== self verify: generated source assertions"
  assert_file_contains "$APP_DIR/Info.plist" "NSSupportsLiveActivities"
  assert_file_contains "$APP_DIR/MonitorDashboardBackend.swift" "final class MonitorDashboardBackend"
  assert_file_contains "$APP_DIR/MonitorDashboardFrontend.swift" "struct MonitorDashboardView"
  if [[ -e "$APP_DIR/MonitorDashboardView.swift" ]]; then
    echo "verify failed: old single-file MonitorDashboardView.swift still exists" >&2
    exit 1
  fi
  assert_file_contains "$EXT_DIR/ActivityMonitorLiveActivity.swift" "DynamicIslandExpandedRegion(.bottom)"
  assert_file_contains "$EXT_DIR/ActivityMonitorLiveActivity.swift" "Button(intent: BlockRequestIntent"
  assert_file_contains "$EXT_DIR/ActivityMonitorLiveActivity.swift" "Button(intent: AllowRequestIntent"
  assert_file_contains "$SHARED_DIR/ActivityMonitorIntents.swift" "struct AllowRequestIntent"
  assert_file_contains "$SHARED_DIR/ActivityMonitorIntents.swift" "struct BlockRequestIntent"
  assert_file_contains "$UITEST_DIR/DynamicIslandExpandedUITests.swift" "testExpandedDynamicIslandShowsDecisionButtons"

  echo "== self verify: plist lint"
  plutil -lint "$APP_DIR/Info.plist" "$EXT_DIR/Info.plist"

  echo "== self verify: xcode project list"
  xcodebuild -list -project "$PROJECT_PATH" | tee /tmp/activity-monitor-button-demo-xcodebuild-list.txt
  assert_file_contains /tmp/activity-monitor-button-demo-xcodebuild-list.txt "$APP_NAME"
  assert_file_contains /tmp/activity-monitor-button-demo-xcodebuild-list.txt "$EXT_NAME"
  assert_file_contains /tmp/activity-monitor-button-demo-xcodebuild-list.txt "$UITEST_NAME"

  echo "== self verify: build"
  xcodebuild build \
    -project "$PROJECT_PATH" \
    -scheme "$APP_NAME" \
    -destination "platform=iOS Simulator,name=$SIM_NAME" \
    -derivedDataPath "$DERIVED_DATA_PATH"

  local udid
  udid="$(select_simulator_udid)"
  if [[ -z "$udid" ]]; then
    echo "verify failed: no simulator found for $SIM_NAME" >&2
    exit 1
  fi

  echo "== self verify: boot/install/launch on $SIM_NAME ($udid)"
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b
  xcrun simctl install "$udid" "$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/$APP_NAME.app"
  xcrun simctl launch --terminate-running-process "$udid" com.example.ActivityMonitorButtonDemo

  if [[ "$RUN_RECORD" != "1" ]]; then
    run_expanded_ui_test
  fi

  echo "self verify passed"
}

run_expanded_ui_test() {
  echo "== self verify: expanded Dynamic Island ALLOW/BLOCK UI test"
  xcodebuild test \
    -project "$PROJECT_PATH" \
    -scheme "$APP_NAME" \
    -destination "platform=iOS Simulator,name=$SIM_NAME" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -only-testing:ActivityMonitorButtonDemoUITests/DynamicIslandExpandedUITests/testExpandedDynamicIslandShowsDecisionButtons
}

record_demo() {
  mkdir -p "$MOVIES_DIR"
  local udid
  udid="$(select_simulator_udid)"
  if [[ -z "$udid" ]]; then
    echo "record failed: no simulator found for $SIM_NAME" >&2
    exit 1
  fi

  echo "== record: $RECORDING_PATH"
  rm -f "$RECORDING_PATH" "$SCREENSHOT_PATH"
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b
  xcrun simctl io "$udid" recordVideo --codec=h264 --force "$RECORDING_PATH" &
  local recorder_pid=$!
  sleep 1
  run_expanded_ui_test
  sleep 1
  kill -INT "$recorder_pid" 2>/dev/null || true
  wait "$recorder_pid" 2>/dev/null || true
  xcrun simctl io "$udid" screenshot "$SCREENSHOT_PATH" >/dev/null

  if [[ ! -s "$RECORDING_PATH" ]]; then
    echo "record failed: video was not created" >&2
    exit 1
  fi

  if command -v ffprobe >/dev/null 2>&1; then
    local duration width height codec
    duration="$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$RECORDING_PATH")"
    codec="$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nk=1:nw=1 "$RECORDING_PATH")"
    width="$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=nk=1:nw=1 "$RECORDING_PATH")"
    height="$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=nk=1:nw=1 "$RECORDING_PATH")"
    awk -v duration="$duration" 'BEGIN { if (duration < 5) exit 1 }' || {
      echo "record failed: video duration below 5 seconds ($duration)" >&2
      exit 1
    }
    echo "record verify passed: codec=$codec size=${width}x${height} duration=${duration}s"
  else
    echo "ffprobe not found; verified non-empty video only"
  fi

  echo "recording: $RECORDING_PATH"
  echo "screenshot: $SCREENSHOT_PATH"
}

choose_taildrop_target() {
  if [[ -n "$TAILDROP_TARGET" ]]; then
    echo "$TAILDROP_TARGET"
    return
  fi
  local active_target
  active_target="$(tailscale status 2>/dev/null | awk '$0 ~ /active/ { print $2; exit }')"
  if [[ -n "$active_target" ]]; then
    echo "$active_target"
    return
  fi
  tailscale file cp --targets |
    awk 'NF == 2 && $1 ~ /^[0-9.]+$/ { print $2; exit }'
}

taildrop_recording() {
  if ! command -v tailscale >/dev/null 2>&1; then
    echo "taildrop failed: tailscale command not found" >&2
    exit 1
  fi

  local target
  target="$(choose_taildrop_target)"
  if [[ -z "$target" ]]; then
    echo "taildrop failed: no online tailscale file target found" >&2
    echo "Run 'tailscale file cp --targets' and pass --taildrop <target>." >&2
    exit 1
  fi

  echo "== taildrop: $RECORDING_PATH -> $target:"
  tailscale file cp "$RECORDING_PATH" "$target:"
  echo "taildrop passed: $target"
}

if [[ "$RUN_SELF_VERIFY" == "1" ]]; then
  self_verify
fi

if [[ "$RUN_RECORD" == "1" ]]; then
  record_demo
fi

if [[ "$TAILDROP_REQUESTED" == "1" ]]; then
  taildrop_recording
fi
