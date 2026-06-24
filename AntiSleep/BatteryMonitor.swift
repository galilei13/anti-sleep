import Foundation
import IOKit.ps

@MainActor
final class BatteryMonitor: ObservableObject {
    static let shared = BatteryMonitor()

    @Published private(set) var batteryLevel: Int = 100
    @Published private(set) var isPluggedIn: Bool = true
    @Published private(set) var pausedByBattery: Bool = false

    private var runLoopSource: CFRunLoopSource?

    private init() {
        refreshSettings()
        updatePowerState()
        startMonitoring()
    }

    func refreshSettings() {
        // Called after UserDefaults changes from SettingsView.
        evaluate()
    }

    private func startMonitoring() {
        let ctx = Unmanaged.passRetained(self).toOpaque()
        runLoopSource = IOPSNotificationCreateRunLoopSource({ ctx in
            guard let ctx else { return }
            let monitor = Unmanaged<BatteryMonitor>.fromOpaque(ctx).takeUnretainedValue()
            Task { @MainActor in
                monitor.updatePowerState()
                monitor.evaluate()
            }
        }, ctx)?.takeRetainedValue()

        if let src = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), src, .defaultMode)
        }
    }

    private func updatePowerState() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              let first = sources.first,
              let info = IOPSGetPowerSourceDescription(snapshot, first)?.takeUnretainedValue()
                as? [String: Any]
        else {
            // No battery (desktop Mac) — treat as always plugged in at 100%.
            batteryLevel = 100
            isPluggedIn = true
            return
        }

        let currentCapacity = info[kIOPSCurrentCapacityKey] as? Int ?? 100
        let maxCapacity = info[kIOPSMaxCapacityKey] as? Int ?? 100
        let powerSourceState = info[kIOPSPowerSourceStateKey] as? String ?? kIOPSACPowerValue

        batteryLevel = maxCapacity > 0 ? (currentCapacity * 100 / maxCapacity) : 100
        isPluggedIn = powerSourceState == kIOPSACPowerValue
    }

    private func evaluate() {
        guard UserDefaults.standard.bool(forKey: "batteryAwareModeEnabled") else {
            // Feature disabled — if we paused, resume.
            if pausedByBattery {
                pausedByBattery = false
                SleepManager.shared.start()
            }
            return
        }

        let threshold = UserDefaults.standard.integer(forKey: "batteryThreshold") == 0
            ? 20
            : UserDefaults.standard.integer(forKey: "batteryThreshold")

        if !isPluggedIn && batteryLevel < threshold && SleepManager.shared.isActive && !pausedByBattery {
            pausedByBattery = true
            SleepManager.shared.stop()
        } else if (isPluggedIn || batteryLevel >= threshold) && pausedByBattery {
            pausedByBattery = false
            SleepManager.shared.start()
        }
    }
}
