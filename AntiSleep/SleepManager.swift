import Foundation
import IOKit.pwr_mgt
import Combine

/// Owns the power-management assertion that prevents the Mac from sleeping.
@MainActor
final class SleepManager: ObservableObject {
    static let shared = SleepManager()

    @Published private(set) var isActive = false

    private var assertionID: IOPMAssertionID = IOPMAssertionID(0)
    private let reason = "AntiSleep is keeping your Mac awake" as CFString

    private init() {}

    func toggle() { isActive ? stop() : start() }

    /// Creates a `PreventUserIdleSystemSleep` assertion via `IOPMAssertionCreateWithName`.
    func start() {
        guard !isActive else { return }
        var id = IOPMAssertionID(0)
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &id
        )
        guard result == kIOReturnSuccess else { return }
        assertionID = id
        isActive = true
    }

    func stop() {
        guard isActive else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = IOPMAssertionID(0)
        isActive = false
    }
}
