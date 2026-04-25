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
