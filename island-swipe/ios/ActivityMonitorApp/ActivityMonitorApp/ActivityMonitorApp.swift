import SwiftUI

@main
struct ActivityMonitorApp: App {
    var body: some Scene {
        WindowGroup {
            MonitorDashboardView()
                .preferredColorScheme(.dark)
        }
    }
}

