import Foundation

struct MonitorActivity: Identifiable, Equatable {
    enum RiskLevel: String, CaseIterable, Codable {
        case low
        case medium
        case high

        var badgeText: String {
            switch self {
            case .low:
                return "LOW"
            case .medium:
                return "MED"
            case .high:
                return "HIGH"
            }
        }
    }

    enum SceneKind: String, CaseIterable, Codable {
        case browser
        case terminal
        case mail
        case code
        case chat
        case social
    }

    let id: UUID
    let appName: String
    let appSymbol: String
    let intent: String
    let reasonShort: String
    let reason: String
    let risk: RiskLevel
    let scene: SceneKind

    init(
        id: UUID = UUID(),
        appName: String,
        appSymbol: String,
        intent: String,
        reasonShort: String,
        reason: String,
        risk: RiskLevel,
        scene: SceneKind
    ) {
        self.id = id
        self.appName = appName
        self.appSymbol = appSymbol
        self.intent = intent
        self.reasonShort = reasonShort
        self.reason = reason
        self.risk = risk
        self.scene = scene
    }
}

enum MonitorDecision: String, Equatable {
    case allow = "ALLOWED"
    case block = "BLOCKED"

    var symbolName: String {
        switch self {
        case .allow:
            return "checkmark"
        case .block:
            return "xmark"
        }
    }

    var directionSign: Double {
        switch self {
        case .allow:
            return 1
        case .block:
            return -1
        }
    }
}

struct MonitorHistoryEntry: Identifiable, Equatable {
    let id = UUID()
    let activity: MonitorActivity
    let decision: MonitorDecision
    let date: Date
}

