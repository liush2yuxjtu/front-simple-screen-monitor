import Foundation
import OSLog
import SwiftUI

public struct MonitorTiming: Sendable {
    public var initialPresentation: TimeInterval = 0.45
    public var autoExpand: TimeInterval = 1.2
    public var decisionHold: TimeInterval = 0.9
    public var postDecisionPause: TimeInterval = 0.5

    public init(
        initialPresentation: TimeInterval = 0.45,
        autoExpand: TimeInterval = 1.2,
        decisionHold: TimeInterval = 0.9,
        postDecisionPause: TimeInterval = 0.5
    ) {
        self.initialPresentation = initialPresentation
        self.autoExpand = autoExpand
        self.decisionHold = decisionHold
        self.postDecisionPause = postDecisionPause
    }
}

@MainActor
public final class MonitorStore: ObservableObject {
    public let decisionThreshold: CGFloat = 90

    @Published public private(set) var session = MonitorSessionState()

    private let activities: [MonitorActivity]
    private let timing: MonitorTiming
    private let haptics: HapticsClient
    private let logger = Logger(subsystem: AppConstants.bundleID, category: "monitor")

    private var autoExpandTask: Task<Void, Never>?
    private var cycleTask: Task<Void, Never>?
    private var cursor = 0
    private var hasStarted = false

    public init(
        activities: [MonitorActivity] = ActivityCatalog.samples,
        timing: MonitorTiming = MonitorTiming(),
        haptics: HapticsClient = .live
    ) {
        self.activities = activities
        self.timing = timing
        self.haptics = haptics
    }

    deinit {
        autoExpandTask?.cancel()
        cycleTask?.cancel()
    }

    public func bootstrap() {
        guard !hasStarted else {
            return
        }

        hasStarted = true
        scheduleNextCycle(after: timing.initialPresentation)
    }

    public func expandNow() {
        autoExpandTask?.cancel()

        withAnimation(.spring(response: 0.46, dampingFraction: 0.86)) {
            session.expandIfNeeded()
        }

        logger.debug("Expanded island manually for activity.")
    }

    public func updateDrag(_ translation: CGFloat) {
        autoExpandTask?.cancel()

        withAnimation(.interactiveSpring(response: 0.22, dampingFraction: 0.86, blendDuration: 0.15)) {
            session.updateDrag(translation: Double(translation))
        }
    }

    public func endDrag(_ translation: CGFloat) {
        autoExpandTask?.cancel()
        var resolvedDecision: MonitorDecision?

        withAnimation(.spring(response: 0.25, dampingFraction: 0.84)) {
            resolvedDecision = session.commitDecision(
                for: Double(translation),
                threshold: Double(decisionThreshold)
            )
        }

        guard let decision = resolvedDecision else {
            logger.debug("Swipe ended below threshold. Returning to expanded state.")
            return
        }

        logger.info("Decision committed: \(decision.rawValue, privacy: .public)")
        haptics.play(decision)
        scheduleResetAfterDecision()
    }

    private func scheduleNextCycle(after seconds: TimeInterval) {
        cycleTask?.cancel()
        cycleTask = schedule(after: seconds) { [weak self] in
            self?.presentNextActivity()
        }
    }

    private func presentNextActivity() {
        guard !activities.isEmpty else {
            logger.error("No sample activities configured.")
            return
        }

        let activity = activities[cursor % activities.count]
        cursor += 1

        withAnimation(.spring(response: 0.46, dampingFraction: 0.88)) {
            session.present(activity)
        }

        logger.info("Presenting activity: \(activity.intent, privacy: .public)")
        scheduleAutoExpand()
    }

    private func scheduleAutoExpand() {
        autoExpandTask?.cancel()
        autoExpandTask = schedule(after: timing.autoExpand) { [weak self] in
            guard let self else {
                return
            }

            withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                self.session.expandIfNeeded()
            }

            self.logger.debug("Auto-expanded island after delay.")
        }
    }

    private func scheduleResetAfterDecision() {
        cycleTask?.cancel()
        cycleTask = schedule(after: timing.decisionHold) { [weak self] in
            guard let self else {
                return
            }

            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                self.session.clearCurrent()
            }

            self.logger.debug("Cleared activity after decision feedback.")
            self.scheduleNextCycle(after: self.timing.postDecisionPause)
        }
    }

    private func schedule(
        after seconds: TimeInterval,
        operation: @escaping @MainActor () -> Void
    ) -> Task<Void, Never> {
        Task {
            let delay = max(seconds, 0)

            if delay > 0 {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }

            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                operation()
            }
        }
    }
}
