import Foundation

struct MonitorSessionSnapshot: Codable, Equatable {
    let allowedCount: Int
    let blockedCount: Int
    let history: [MonitorHistoryEntry]

    init(
        allowedCount: Int,
        blockedCount: Int,
        history: [MonitorHistoryEntry]
    ) {
        self.allowedCount = max(0, allowedCount)
        self.blockedCount = max(0, blockedCount)
        self.history = Array(history.prefix(MonitorSessionState.historyLimit))
    }

    init(session: MonitorSessionState) {
        self.init(
            allowedCount: session.allowedCount,
            blockedCount: session.blockedCount,
            history: session.history
        )
    }

    func restoredSession() -> MonitorSessionState {
        var session = MonitorSessionState()
        session.allowedCount = allowedCount
        session.blockedCount = blockedCount
        session.history = Array(history.prefix(MonitorSessionState.historyLimit))
        return session
    }
}

struct MonitorSessionStore {
    static let defaultKey = "activityMonitor.session.v1"

    private let defaults: UserDefaults
    private let key: String

    init(
        defaults: UserDefaults = .standard,
        key: String = Self.defaultKey
    ) {
        self.defaults = defaults
        self.key = key
    }

    func load() -> MonitorSessionSnapshot? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }

        return try? JSONDecoder().decode(MonitorSessionSnapshot.self, from: data)
    }

    func save(_ session: MonitorSessionState) {
        save(MonitorSessionSnapshot(session: session))
    }

    func save(_ snapshot: MonitorSessionSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }

        defaults.set(data, forKey: key)
    }

    func reset() {
        defaults.removeObject(forKey: key)
    }
}
