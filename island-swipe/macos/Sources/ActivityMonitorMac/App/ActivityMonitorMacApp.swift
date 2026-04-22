import AppKit
import SwiftUI

@main
struct ActivityMonitorMacApp: App {
    @NSApplicationDelegateAdaptor(ActivityMonitorAppDelegate.self) private var appDelegate
    @StateObject private var store = MonitorStore()

    var body: some Scene {
        WindowGroup("灵动岛 · Activity Monitor") {
            MonitorWindowView(store: store)
                .preferredColorScheme(.dark)
                .frame(minWidth: 920, minHeight: 720)
        }
        .defaultSize(width: 980, height: 760)
        .windowResizability(.contentMinSize)
    }
}

final class ActivityMonitorAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
