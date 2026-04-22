import Foundation

func require(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() {
        fputs("SELF CHECK FAILED: \(message)\n", stderr)
        exit(1)
    }
}

func checkStateThresholds() {
    var allowState = MonitorSessionState()
    allowState.present(ActivityCatalog.samples[0])
    allowState.expandIfNeeded()

    let allowDecision = allowState.commitDecision(
        for: 90,
        threshold: 90,
        now: Date(timeIntervalSince1970: 1)
    )

    require(allowDecision == .allow, "90pt 右滑应该触发 ALLOW")
    require(allowState.allowedCount == 1, "ALLOW 计数应为 1")
    require(allowState.totalCount == 1, "TOTAL 计数应为 1")

    var blockState = MonitorSessionState()
    blockState.present(ActivityCatalog.samples[1])
    blockState.expandIfNeeded()

    let blockDecision = blockState.commitDecision(
        for: -90,
        threshold: 90,
        now: Date(timeIntervalSince1970: 2)
    )

    require(blockDecision == .block, "-90pt 左滑应该触发 BLOCK")
    require(blockState.blockedCount == 1, "BLOCK 计数应为 1")

    var neutralState = MonitorSessionState()
    neutralState.present(ActivityCatalog.samples[2])
    neutralState.expandIfNeeded()
    neutralState.updateDrag(translation: 42)

    let neutralDecision = neutralState.commitDecision(
        for: 42,
        threshold: 90,
        now: Date(timeIntervalSince1970: 3)
    )

    require(neutralDecision == nil, "低于阈值的滑动不应提交决策")
    require(neutralState.phase == .expanded, "低于阈值后应回到 expanded")
    require(neutralState.dragOffset == 0, "低于阈值后 dragOffset 应归零")
}

@MainActor
func checkAutoExpandAndNextCycle() async throws {
    let store = MonitorStore(
        activities: [ActivityCatalog.samples[0], ActivityCatalog.samples[1]],
        timing: MonitorTiming(
            initialPresentation: 0.01,
            autoExpand: 0.02,
            decisionHold: 0.01,
            postDecisionPause: 0.01
        ),
        haptics: .noop
    )

    store.bootstrap()

    try await Task.sleep(nanoseconds: 20_000_000)
    require(store.session.phase == .notification, "首个样本应先进入 notification")
    require(store.session.currentActivity?.intent == "Open YouTube", "首个样本活动不正确")

    try await Task.sleep(nanoseconds: 30_000_000)
    require(store.session.phase == .expanded, "1.2s 映射延时后应自动展开")

    store.endDrag(140)
    require(store.session.phase == .accepted, "超过阈值的右滑应立即进入 accepted")
    require(store.session.allowedCount == 1, "右滑后 ALLOWED 应递增")

    try await Task.sleep(nanoseconds: 40_000_000)
    require(store.session.phase == .notification, "决策完成后应进入下一条 notification")
    require(store.session.currentActivity?.intent == "rm -rf node_modules", "下一条样本活动不正确")
}

@main
struct SelfCheckMain {
    static func main() async throws {
        checkStateThresholds()
        try await checkAutoExpandAndNextCycle()
        print("SELF CHECK PASSED")
    }
}
