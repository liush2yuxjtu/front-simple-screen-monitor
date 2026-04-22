import Foundation

public struct MonitorActivity: Identifiable, Equatable, Sendable {
    public enum RiskLevel: String, CaseIterable, Codable, Sendable {
        case low
        case medium
        case high

        public var badgeText: String {
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

    public enum SceneKind: String, CaseIterable, Codable, Sendable {
        case browser
        case terminal
        case mail
        case code
        case chat
        case social
    }

    public let id: UUID
    public let appName: String
    public let appSymbol: String
    public let intent: String
    public let reasonShort: String
    public let reason: String
    public let risk: RiskLevel
    public let scene: SceneKind

    public init(
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

public enum MonitorDecision: String, Equatable, Sendable {
    case allow = "ALLOWED"
    case block = "BLOCKED"

    public var symbolName: String {
        switch self {
        case .allow:
            return "checkmark"
        case .block:
            return "xmark"
        }
    }

    public var directionSign: Double {
        switch self {
        case .allow:
            return 1
        case .block:
            return -1
        }
    }
}

public struct MonitorHistoryEntry: Identifiable, Equatable, Sendable {
    public let id = UUID()
    public let activity: MonitorActivity
    public let decision: MonitorDecision
    public let date: Date

    public init(activity: MonitorActivity, decision: MonitorDecision, date: Date) {
        self.activity = activity
        self.decision = decision
        self.date = date
    }
}

public enum ActivityCatalog {
    public static let samples: [MonitorActivity] = [
        MonitorActivity(
            appName: "Chrome",
            appSymbol: "globe",
            intent: "Open YouTube",
            reasonShort: "Dock hover + afternoon timing",
            reason: "Mouse settled near the Chrome icon. Context suggests passive video playback. Low risk.",
            risk: .low,
            scene: .browser
        ),
        MonitorActivity(
            appName: "iTerm2",
            appSymbol: "terminal.fill",
            intent: "rm -rf node_modules",
            reasonShort: "Delete command typed, not executed",
            reason: "Terminal cursor is parked at project root. Command is staged but not confirmed. High risk.",
            risk: .high,
            scene: .terminal
        ),
        MonitorActivity(
            appName: "Mail",
            appSymbol: "envelope.fill",
            intent: "Compose mail to Anthropic",
            reasonShort: "Draft rewritten several times",
            reason: "Recipient field is filled and the body keeps changing. User appears to be searching for the right tone.",
            risk: .medium,
            scene: .mail
        ),
        MonitorActivity(
            appName: "VS Code",
            appSymbol: "chevron.left.forwardslash.chevron.right",
            intent: "Edit auth.ts",
            reasonShort: "Token check paused mid-flow",
            reason: "Cursor stopped on a partially implemented token verification path. Resuming now is likely useful.",
            risk: .low,
            scene: .code
        ),
        MonitorActivity(
            appName: "Slack",
            appSymbol: "message.fill",
            intent: "Slack DM to colleague",
            reasonShort: "Message paused before send",
            reason: "Draft reads like a half-finished after-work invite. Hesitation detected after multiple edits.",
            risk: .medium,
            scene: .chat
        ),
        MonitorActivity(
            appName: "Twitter",
            appSymbol: "bubble.left.and.exclamationmark.bubble.right.fill",
            intent: "Post about unreleased strategy",
            reasonShort: "Public draft mentions internal plan",
            reason: "Compose box contains future strategy details. Posting would create an immediate leak risk.",
            risk: .high,
            scene: .social
        )
    ]
}
