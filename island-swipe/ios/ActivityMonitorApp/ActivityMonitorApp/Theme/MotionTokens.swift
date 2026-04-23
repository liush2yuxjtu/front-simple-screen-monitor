import SwiftUI

enum Timings {
    static let bootstrapDelay: TimeInterval = 0.45
    static let autoExpand: TimeInterval = 1.2
    static let resetClear: TimeInterval = 0.9
    static let nextActivityDelay: TimeInterval = 0.5

    static var autoExpandNanos: UInt64 { nanos(autoExpand) }
    static var resetClearNanos: UInt64 { nanos(resetClear) }
    static var nextActivityDelayNanos: UInt64 { nanos(nextActivityDelay) }

    private static func nanos(_ seconds: TimeInterval) -> UInt64 {
        UInt64(seconds * 1_000_000_000)
    }
}

enum AnimationTokens {
    static let islandExpand = Animation.spring(response: 0.46, dampingFraction: 0.86)
    static let dragResponsive = Animation.interactiveSpring(
        response: 0.22, dampingFraction: 0.86, blendDuration: 0.15
    )
    static let decisionCommit = Animation.spring(response: 0.25, dampingFraction: 0.84)
    static let activityPresent = Animation.spring(response: 0.46, dampingFraction: 0.88)
    static let autoExpand = Animation.spring(response: 0.5, dampingFraction: 0.86)
    static let decisionReset = Animation.spring(response: 0.35, dampingFraction: 0.9)
    static let phaseTransition = Animation.spring(response: 0.45, dampingFraction: 0.85)
    static let dragFeedback = Animation.interactiveSpring(response: 0.22, dampingFraction: 0.84)
    static let thresholdArm = Animation.spring(response: 0.22, dampingFraction: 0.7)
    static let directionArm = Animation.spring(response: 0.24, dampingFraction: 0.7)
    static let confirmationPop = Animation.spring(response: 0.42, dampingFraction: 0.62)
}
