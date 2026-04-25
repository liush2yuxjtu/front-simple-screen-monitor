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
