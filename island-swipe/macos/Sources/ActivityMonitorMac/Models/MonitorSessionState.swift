import Foundation

public enum IslandPhase: Equatable, Sendable {
    case idle
    case notification
    case expanded
    case dragging
    case accepted
    case denied

    public var allowsDrag: Bool {
        switch self {
        case .expanded, .dragging:
            return true
        default:
            return false
        }
    }

    public var label: String {
        switch self {
        case .idle:
            return "IDLE"
        case .notification:
            return "MONITOR"
        case .expanded:
            return "READY"
        case .dragging:
            return "SWIPE"
        case .accepted:
            return "ALLOW"
        case .denied:
            return "BLOCK"
        }
    }
}

public struct MonitorSessionState: Equatable, Sendable {
    public static let dragClamp = 148.0

    public var currentActivity: MonitorActivity?
    public var phase: IslandPhase = .idle
    public var dragOffset: Double = 0
    public var lastDecision: MonitorDecision?
    public var allowedCount: Int = 0
    public var blockedCount: Int = 0
    public var history: [MonitorHistoryEntry] = []

    public init(
        currentActivity: MonitorActivity? = nil,
        phase: IslandPhase = .idle,
        dragOffset: Double = 0,
        lastDecision: MonitorDecision? = nil,
        allowedCount: Int = 0,
        blockedCount: Int = 0,
        history: [MonitorHistoryEntry] = []
    ) {
        self.currentActivity = currentActivity
        self.phase = phase
        self.dragOffset = dragOffset
        self.lastDecision = lastDecision
        self.allowedCount = allowedCount
        self.blockedCount = blockedCount
        self.history = history
    }

    public var totalCount: Int {
        allowedCount + blockedCount
    }

    public var dragProgress: Double {
        min(abs(dragOffset) / 90.0, 1.0)
    }

    public mutating func present(_ activity: MonitorActivity) {
        currentActivity = activity
        phase = .notification
        dragOffset = 0
        lastDecision = nil
    }

    public mutating func expandIfNeeded() {
        guard currentActivity != nil, phase == .notification else {
            return
        }

        phase = .expanded
    }

    public mutating func updateDrag(translation: Double) {
        guard currentActivity != nil, phase == .expanded || phase == .dragging else {
            return
        }

        dragOffset = max(-Self.dragClamp, min(Self.dragClamp, translation))
        phase = .dragging
    }

    public mutating func resetDrag() {
        guard currentActivity != nil else {
            return
        }

        dragOffset = 0
        phase = .expanded
    }

    public mutating func commitDecision(
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

    public mutating func clearCurrent() {
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
        dragOffset = decision.directionSign * 132

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
