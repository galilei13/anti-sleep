import SwiftUI

@main
struct AntiSleepApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var sleep = SleepManager.shared
    @StateObject private var timer = TimerManager.shared

    var body: some Scene {
        MenuBarExtra {
            MenuContentView()
        } label: {
            if timer.isActive {
                // Show compact countdown in the menu bar while timer is running.
                Label(timer.formattedRemaining, systemImage: "timer")
                    .labelStyle(.titleAndIcon)
                    .font(.system(size: 12, weight: .medium).monospacedDigit())
            } else {
                // Template SF Symbols are automatically light/dark-mode adaptive.
                Image(systemName: sleep.isActive ? "cup.and.saucer.fill" : "moon.zzz")
            }
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
        // Eagerly init managers so their observers are registered at launch.
        _ = AppTriggerManager.shared
        _ = BatteryMonitor.shared
    }
}
