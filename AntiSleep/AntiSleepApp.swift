import SwiftUI

@main
struct AntiSleepApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var sleep = SleepManager.shared

    var body: some Scene {
        MenuBarExtra {
            MenuContentView()
        } label: {
            // Template SF Symbols are automatically light/dark-mode adaptive.
            Image(systemName: sleep.isActive ? "cup.and.saucer.fill" : "moon.zzz")
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Pure menu bar app: no Dock icon, no main window.
        NSApp.setActivationPolicy(.accessory)
        PermissionsManager.shared.refresh()
        WindowManager.shared.showOnboardingIfNeeded()
    }
}
