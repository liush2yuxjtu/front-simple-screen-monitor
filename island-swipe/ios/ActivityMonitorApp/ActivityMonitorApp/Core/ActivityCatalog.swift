import Foundation

enum ActivityCatalog {
    static let samples: [MonitorActivity] = [
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

