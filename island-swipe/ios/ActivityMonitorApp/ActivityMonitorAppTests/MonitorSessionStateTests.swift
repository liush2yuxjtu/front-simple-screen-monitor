import XCTest
@testable import ActivityMonitorApp

final class MonitorSessionStateTests: XCTestCase {
    private let activity = MonitorActivity(
        appName: "Chrome",
        appSymbol: "globe",
        intent: "Open YouTube",
        reasonShort: "Passive playback",
        reason: "Mouse settled near the Chrome icon.",
        risk: .low,
        scene: .browser
    )

    func testRightSwipePastThresholdAllowsActivity() {
        var session = MonitorSessionState()
        session.present(activity)
        session.expandIfNeeded()

        let decision = session.commitDecision(
            for: MonitorSessionState.decisionThreshold,
            threshold: MonitorSessionState.decisionThreshold
        )

        XCTAssertEqual(decision, .allow)
        XCTAssertEqual(session.allowedCount, 1)
        XCTAssertEqual(session.blockedCount, 0)
        XCTAssertEqual(session.totalCount, 1)
        XCTAssertEqual(session.phase, .accepted)
        XCTAssertEqual(session.dragOffset, MonitorSessionState.decisionOvershoot)
    }

    func testLeftSwipePastThresholdBlocksActivity() {
        var session = MonitorSessionState()
        session.present(activity)
        session.expandIfNeeded()

        let decision = session.commitDecision(
            for: -MonitorSessionState.decisionThreshold,
            threshold: MonitorSessionState.decisionThreshold
        )

        XCTAssertEqual(decision, .block)
        XCTAssertEqual(session.allowedCount, 0)
        XCTAssertEqual(session.blockedCount, 1)
        XCTAssertEqual(session.totalCount, 1)
        XCTAssertEqual(session.phase, .denied)
        XCTAssertEqual(session.dragOffset, -MonitorSessionState.decisionOvershoot)
    }

    func testSwipeBelowThresholdResetsDragWithoutCounting() {
        var session = MonitorSessionState()
        session.present(activity)
        session.expandIfNeeded()
        session.updateDrag(translation: MonitorSessionState.decisionThreshold - 1)

        let decision = session.commitDecision(
            for: MonitorSessionState.decisionThreshold - 1,
            threshold: MonitorSessionState.decisionThreshold
        )

        XCTAssertNil(decision)
        XCTAssertEqual(session.allowedCount, 0)
        XCTAssertEqual(session.blockedCount, 0)
        XCTAssertEqual(session.totalCount, 0)
        XCTAssertEqual(session.phase, .expanded)
        XCTAssertEqual(session.dragOffset, 0)
    }

    func testHistoryIsCappedAtLimit() {
        var session = MonitorSessionState()

        for index in 0..<(MonitorSessionState.historyLimit + 2) {
            session.present(activity)
            session.expandIfNeeded()
            _ = session.commitDecision(
                for: MonitorSessionState.decisionThreshold + Double(index),
                threshold: MonitorSessionState.decisionThreshold,
                now: Date(timeIntervalSince1970: Double(index))
            )
            session.clearCurrent()
        }

        XCTAssertEqual(session.allowedCount, MonitorSessionState.historyLimit + 2)
        XCTAssertEqual(session.totalCount, MonitorSessionState.historyLimit + 2)
        XCTAssertEqual(session.history.count, MonitorSessionState.historyLimit)
        XCTAssertEqual(session.history.first?.date, Date(timeIntervalSince1970: Double(MonitorSessionState.historyLimit + 1)))
        XCTAssertEqual(session.history.last?.date, Date(timeIntervalSince1970: 2))
    }
}
