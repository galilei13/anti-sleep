import Foundation
import ServiceManagement
import Combine

/// Manages the app's "Launch at Login" state via `SMAppService` (macOS 13+).
@MainActor
final class LaunchAtLoginManager: ObservableObject {
    static let shared = LaunchAtLoginManager()

    @Published private(set) var isEnabled = false

    private var service: SMAppService { .mainApp }

    private init() { refresh() }

    func refresh() {
        isEnabled = service.status == .enabled
    }

    /// Registers or unregisters the main app as a login item. Reverts on failure.
    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                if service.status != .enabled { try service.register() }
            } else {
                if service.status == .enabled { try service.unregister() }
            }
        } catch {
            NSLog("LaunchAtLogin: failed to set enabled=\(enabled): \(error.localizedDescription)")
        }
        refresh()
    }

    func toggle() { setEnabled(!isEnabled) }
}
