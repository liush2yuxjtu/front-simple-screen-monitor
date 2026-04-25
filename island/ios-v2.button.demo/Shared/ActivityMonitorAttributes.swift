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
