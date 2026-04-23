import Foundation

enum IslandPhase: Equatable {
    case idle
    case notification
    case expanded
    case dragging
    case accepted
    case denied

    var allowsDrag: Bool {
        switch self {
        case .expanded, .dragging:
            return true
        default:
            return false
        }
    }
}

struct MonitorSessionState: Equatable {
    static let dragClamp: Double = 148
    static let decisionOvershoot: Double = 132

    var currentActivity: MonitorActivity?
    var phase: IslandPhase = .idle
    var dragOffset: Double = 0
    var lastDecision: MonitorDecision?
    var allowedCount: Int = 0
    var blockedCount: Int = 0
    var history: [MonitorHistoryEntry] = []

    var totalCount: Int {
        allowedCount + blockedCount
    }

    var dragProgress: Double {
        min(abs(dragOffset) / 90.0, 1.0)
    }

    mutating func present(_ activity: MonitorActivity) {
        currentActivity = activity
        phase = .notification
        dragOffset = 0
        lastDecision = nil
    }

    mutating func expandIfNeeded() {
        guard currentActivity != nil, phase == .notification else {
            return
        }
        phase = .expanded
    }

    mutating func updateDrag(translation: Double) {
        guard currentActivity != nil, phase == .expanded || phase == .dragging else {
            return
        }
        dragOffset = max(-Self.dragClamp, min(Self.dragClamp, translation))
        phase = .dragging
    }

    mutating func resetDrag() {
        guard currentActivity != nil else {
            return
        }
        dragOffset = 0
        phase = .expanded
    }

    mutating func commitDecision(
        for translation: Double,
        threshold: Double,
        now: Date = .init()
    ) -> MonitorDecision? {
        guard let activity = currentActivity, phase == .expanded || phase == .dragging else {
            return nil
        }

        let clamped = max(-Self.dragClamp, min(Self.dragClamp, translation))
        dragOffset = clamped

        if clamped >= threshold {
            return apply(.allow, activity: activity, now: now)
        }

        if clamped <= -threshold {
            return apply(.block, activity: activity, now: now)
        }

        resetDrag()
        return nil
    }

    mutating func clearCurrent() {
        currentActivity = nil
        dragOffset = 0
        phase = .idle
    }

    private mutating func apply(
        _ decision: MonitorDecision,
        activity: MonitorActivity,
        now: Date
    ) -> MonitorDecision {
        lastDecision = decision
        dragOffset = decision.directionSign * Self.decisionOvershoot

        switch decision {
        case .allow:
            allowedCount += 1
            phase = .accepted
        case .block:
            blockedCount += 1
            phase = .denied
        }

        history.insert(
            MonitorHistoryEntry(activity: activity, decision: decision, date: now),
            at: 0
        )
        history = Array(history.prefix(6))
        return decision
    }
}

