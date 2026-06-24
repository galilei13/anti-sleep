import Foundation
import AppKit

@MainActor
final class AppTriggerManager: ObservableObject {
    static let shared = AppTriggerManager()

    @Published private(set) var watchedApps: [String] = []
    @Published private(set) var triggeredByApp: String? = nil

    private let defaultsKey = "watchedAppNames"

    private init() {
        watchedApps = UserDefaults.standard.stringArray(forKey: defaultsKey) ?? []
        registerObservers()
    }

    func addApp(_ name: String) {
        guard !watchedApps.contains(name) else { return }
        watchedApps.append(name)
        save()
        // If the app is already running, activate immediately.
        if isAppRunning(name) {
            activate(by: name)
        }
    }

    func removeApp(_ name: String) {
        watchedApps.removeAll { $0 == name }
        save()
        if triggeredByApp == name {
            deactivateIfNeeded()
        }
    }

    private func save() {
        UserDefaults.standard.set(watchedApps, forKey: defaultsKey)
    }

    private func registerObservers() {
        let nc = NSWorkspace.shared.notificationCenter
        nc.addObserver(
            self,
            selector: #selector(appLaunched(_:)),
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil
        )
        nc.addObserver(
            self,
            selector: #selector(appTerminated(_:)),
            name: NSWorkspace.didTerminateApplicationNotification,
            object: nil
        )
    }

    @objc private func appLaunched(_ note: Notification) {
        guard let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let name = app.localizedName,
              watchedApps.contains(name) else { return }
        Task { @MainActor in self.activate(by: name) }
    }

    @objc private func appTerminated(_ note: Notification) {
        guard let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let name = app.localizedName,
              watchedApps.contains(name) else { return }
        Task { @MainActor in self.deactivateIfNeeded() }
    }

    private func activate(by name: String) {
        triggeredByApp = name
        SleepManager.shared.start()
    }

    private func deactivateIfNeeded() {
        // Only stop if no other watched apps are still running.
        let stillRunning = watchedApps.contains { isAppRunning($0) }
        if !stillRunning {
            triggeredByApp = nil
            // Only stop if the timer isn't also active.
            if !TimerManager.shared.isActive {
                SleepManager.shared.stop()
            }
        } else {
            // Update triggeredByApp to a still-running app.
            triggeredByApp = watchedApps.first { isAppRunning($0) }
        }
    }

    private func isAppRunning(_ name: String) -> Bool {
        NSWorkspace.shared.runningApplications.contains {
            $0.localizedName == name
        }
    }
}
