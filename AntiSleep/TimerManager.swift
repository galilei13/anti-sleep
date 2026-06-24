import Foundation
import UserNotifications
import Combine

@MainActor
final class TimerManager: ObservableObject {
    static let shared = TimerManager()

    @Published private(set) var remainingSeconds: Int? = nil

    private var timer: Timer?

    private init() {}

    var isActive: Bool { remainingSeconds != nil }

    func start(seconds: Int) {
        cancel()
        SleepManager.shared.start()
        remainingSeconds = seconds
        UserDefaults.standard.set(seconds, forKey: "lastTimerDurationSeconds")
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        remainingSeconds = nil
        SleepManager.shared.stop()
    }

    private func tick() {
        guard var remaining = remainingSeconds else { return }
        remaining -= 1
        if remaining <= 0 {
            cancel()
            notify()
        } else {
            remainingSeconds = remaining
        }
    }

    private func notify() {
        let content = UNMutableNotificationContent()
        content.title = "AntiSleep"
        content.body = "Timer finished — your Mac can sleep normally again."
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "antisleep.timer.done",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    var formattedRemaining: String {
        guard let s = remainingSeconds else { return "" }
        let m = s / 60
        let sec = s % 60
        return String(format: "%d:%02d", m, sec)
    }
}
