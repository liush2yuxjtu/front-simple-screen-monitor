import Foundation
import SwiftUI

@MainActor
final class MonitorViewModel: ObservableObject {
    let decisionThreshold = CGFloat(MonitorSessionState.decisionThreshold)

    @Published private(set) var session = MonitorSessionState()

    private let activities = ActivityCatalog.samples
    private let haptics = HapticsClient()

    private nonisolated(unsafe) var autoExpandTask: Task<Void, Never>?
    private nonisolated(unsafe) var resetTask: Task<Void, Never>?
    private nonisolated(unsafe) var presentTask: Task<Void, Never>?
    private var cursor = 0
    private var hasStarted = false
    private var lastThresholdSide: Int = 0

    deinit {
        autoExpandTask?.cancel()
        resetTask?.cancel()
        presentTask?.cancel()
    }

    func bootstrap() {
        guard !hasStarted else {
            return
        }
        hasStarted = true
        schedulePresent(after: Timings.bootstrapDelay)
    }

    func expandNow() {
        autoExpandTask?.cancel()
        session.expandIfNeeded()
    }

    func updateDrag(_ translation: CGFloat) {
        autoExpandTask?.cancel()
        session.updateDrag(translation: Double(translation))

        let side: Int
        if translation >= decisionThreshold {
            side = 1
        } else if translation <= -decisionThreshold {
            side = -1
        } else {
            side = 0
        }

        if side != lastThresholdSide {
            if side != 0 {
                haptics.tick()
            }
            lastThresholdSide = side
        }
    }

    func endDrag(_ translation: CGFloat) {
        autoExpandTask?.cancel()
        let priorSide = lastThresholdSide
        lastThresholdSide = 0

        let resolvedDecision = session.commitDecision(
            for: Double(translation),
            threshold: Double(decisionThreshold)
        )

        guard let decision = resolvedDecision else {
            if priorSide == 0 && abs(translation) > 12 {
                haptics.cancel()
            }
            return
        }

        haptics.play(decision)
        scheduleResetAfterDecision()
    }

    func requestDecision(_ decision: MonitorDecision) {
        autoExpandTask?.cancel()
        session.expandIfNeeded()

        let translation = CGFloat(decision.directionSign) * (decisionThreshold + 1)
        let resolvedDecision = session.commitDecision(
            for: Double(translation),
            threshold: Double(decisionThreshold)
        )

        guard let resolvedDecision else {
            return
        }

        haptics.play(resolvedDecision)
        scheduleResetAfterDecision()
    }

    private func schedulePresent(after seconds: TimeInterval) {
        presentTask?.cancel()
        presentTask = Task { [weak self] in
            guard let self else {
                return
            }

            try? await Task.sleep(nanoseconds: Timings.nanos(seconds))
            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                self.presentNextActivity()
            }
        }
    }

    private func presentNextActivity() {
        guard !activities.isEmpty else {
            return
        }

        let activity = activities[cursor % activities.count]
        cursor += 1

        session.present(activity)

        scheduleAutoExpand()
    }

    private func scheduleAutoExpand() {
        autoExpandTask?.cancel()
        autoExpandTask = Task { [weak self] in
            guard let self else {
                return
            }

            try? await Task.sleep(nanoseconds: Timings.autoExpandNanos)
            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                self.session.expandIfNeeded()
            }
        }
    }

    private func scheduleResetAfterDecision() {
        resetTask?.cancel()
        resetTask = Task { [weak self] in
            guard let self else {
                return
            }

            try? await Task.sleep(nanoseconds: Timings.resetClearNanos)
            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                self.session.clearCurrent()
                self.schedulePresent(after: Timings.nextActivityDelay)
            }
        }
    }
}
