import Foundation
import SwiftUI

@MainActor
final class MonitorViewModel: ObservableObject {
    let decisionThreshold: CGFloat = 90

    @Published private(set) var session = MonitorSessionState()

    private let activities = ActivityCatalog.samples
    private let haptics = HapticsClient()

    private var autoExpandTask: Task<Void, Never>?
    private var nextCycleTask: Task<Void, Never>?
    private var cursor = 0
    private var hasStarted = false

    deinit {
        autoExpandTask?.cancel()
        nextCycleTask?.cancel()
    }

    func bootstrap() {
        guard !hasStarted else {
            return
        }
        hasStarted = true
        scheduleNextCycle(after: 0.45)
    }

    func expandNow() {
        autoExpandTask?.cancel()
        withAnimation(.spring(response: 0.46, dampingFraction: 0.86)) {
            session.expandIfNeeded()
        }
    }

    func updateDrag(_ translation: CGFloat) {
        autoExpandTask?.cancel()
        withAnimation(.interactiveSpring(response: 0.22, dampingFraction: 0.86, blendDuration: 0.15)) {
            session.updateDrag(translation: Double(translation))
        }
    }

    func endDrag(_ translation: CGFloat) {
        autoExpandTask?.cancel()
        var resolvedDecision: MonitorDecision?

        withAnimation(.spring(response: 0.25, dampingFraction: 0.84)) {
            resolvedDecision = session.commitDecision(
                for: Double(translation),
                threshold: Double(decisionThreshold)
            )
        }

        guard let decision = resolvedDecision else {
            return
        }

        haptics.play(decision)
        scheduleResetAfterDecision()
    }

    private func scheduleNextCycle(after seconds: Double) {
        nextCycleTask?.cancel()
        nextCycleTask = Task { [weak self] in
            guard let self else {
                return
            }

            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
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

        withAnimation(.spring(response: 0.46, dampingFraction: 0.88)) {
            session.present(activity)
        }

        scheduleAutoExpand()
    }

    private func scheduleAutoExpand() {
        autoExpandTask?.cancel()
        autoExpandTask = Task { [weak self] in
            guard let self else {
                return
            }

            try? await Task.sleep(nanoseconds: 1_200_000_000)
            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                    self.session.expandIfNeeded()
                }
            }
        }
    }

    private func scheduleResetAfterDecision() {
        nextCycleTask?.cancel()
        nextCycleTask = Task { [weak self] in
            guard let self else {
                return
            }

            try? await Task.sleep(nanoseconds: 900_000_000)
            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    self.session.clearCurrent()
                }
            }

            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                self.presentNextActivity()
            }
        }
    }
}
