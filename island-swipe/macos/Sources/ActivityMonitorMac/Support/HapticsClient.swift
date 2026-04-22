import Foundation

#if canImport(AppKit)
import AppKit
#endif

public struct HapticsClient: Sendable {
    private let playHandler: @Sendable (MonitorDecision) -> Void

    public init(playHandler: @escaping @Sendable (MonitorDecision) -> Void = { _ in }) {
        self.playHandler = playHandler
    }

    public func play(_ decision: MonitorDecision) {
        playHandler(decision)
    }

    public static let live = HapticsClient { decision in
        #if canImport(AppKit)
        let performer = NSHapticFeedbackManager.defaultPerformer

        switch decision {
        case .allow:
            performer.perform(.levelChange, performanceTime: .now)
        case .block:
            performer.perform(.alignment, performanceTime: .now)
        }
        #else
        _ = decision
        #endif
    }

    public static let noop = HapticsClient()
}
