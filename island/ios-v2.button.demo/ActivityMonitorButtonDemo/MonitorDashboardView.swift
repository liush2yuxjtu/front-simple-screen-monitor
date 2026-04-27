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
            VStack(alignment: .leading, spacing: 22) {
                requestCard
                actionButtons
                statusCard
                Spacer(minLength: 0)
            }
            .padding(20)
            .navigationTitle("Activity Monitor")
            .background(Color(.systemGroupedBackground))
            .task {
                await model.runRecordingDemoIfNeeded()
            }
        }
    }

    private var requestCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(model.currentState.requester, systemImage: "shield.lefthalf.filled")
                    .font(.headline)
                Spacer()
                Text(model.currentState.riskLevel)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.orange.opacity(0.18), in: Capsule())
            }

            Text(model.currentState.actionSummary)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            Text(model.currentState.decision.rawValue)
                .font(.caption.weight(.bold))
                .foregroundStyle(model.currentState.decision.tint)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                model.startLiveActivity()
            } label: {
                Label("Start Live Activity", systemImage: "dot.radiowaves.left.and.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            HStack(spacing: 12) {
                Button(role: .destructive) {
                    model.decide(.blocked)
                } label: {
                    Label("BLOCK", systemImage: "xmark.octagon.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    model.decide(.allowed)
                } label: {
                    Label("ALLOW", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
            .controlSize(.large)
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .font(.headline)
            Text(model.statusLine)
            Text("Last stored decision: \(ActivityMonitorDecisionStore.lastDecisionSummary())")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}
