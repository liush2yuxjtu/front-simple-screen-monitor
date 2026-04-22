import Foundation

#if canImport(UIKit)
import UIKit
#endif

struct HapticsClient {
    func play(_ decision: MonitorDecision) {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        switch decision {
        case .allow:
            generator.notificationOccurred(.success)
        case .block:
            generator.notificationOccurred(.error)
        }
        #endif
    }
}

