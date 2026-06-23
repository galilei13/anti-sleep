import Foundation
import UserNotifications
import Combine

/// Tracks and requests the system permissions the app surfaces to the user.
///
/// Preventing sleep itself needs no entitlement, so the representative
/// user-facing permission is local notification authorization (used to
/// confirm toggles). This keeps onboarding and Settings honest and testable.
@MainActor
final class PermissionsManager: ObservableObject {
    static let shared = PermissionsManager()

    enum Status: String {
        case notDetermined = "Not Determined"
        case authorized = "Authorized"
        case denied = "Denied"
        case provisional = "Provisional"
    }

    @Published private(set) var notificationStatus: Status = .notDetermined

    private init() {}

    func refresh() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let mapped = Self.map(settings.authorizationStatus)
            Task { @MainActor in self.notificationStatus = mapped }
        }
    }

    func request() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
            Task { @MainActor in self.refresh() }
        }
    }

    private static func map(_ status: UNAuthorizationStatus) -> Status {
        switch status {
        case .authorized: return .authorized
        case .denied: return .denied
        case .provisional, .ephemeral: return .provisional
        default: return .notDetermined
        }
    }
}
