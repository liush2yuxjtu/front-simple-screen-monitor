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
