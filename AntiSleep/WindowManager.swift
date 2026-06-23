import SwiftUI
import AppKit

/// Manages the auxiliary (non-menu-bar) windows: onboarding and settings.
@MainActor
final class WindowManager: NSObject, ObservableObject {
    static let shared = WindowManager()

    private static let onboardingKey = "hasCompletedOnboarding"

    private var onboardingWindow: NSWindow?
    private var settingsWindow: NSWindow?

    func showOnboardingIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Self.onboardingKey) else { return }
        showOnboarding()
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: Self.onboardingKey)
        onboardingWindow?.close()
        onboardingWindow = nil
    }

    func showOnboarding() {
        present(&onboardingWindow,
                title: "Welcome to AntiSleep",
                size: NSSize(width: 460, height: 420),
                content: OnboardingView())
    }

    func showSettings() {
        present(&settingsWindow,
                title: "AntiSleep Settings",
                size: NSSize(width: 460, height: 360),
                content: SettingsView())
    }

    private func present<Content: View>(_ slot: inout NSWindow?,
                                        title: String,
                                        size: NSSize,
                                        content: Content) {
        if let existing = slot {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.isReleasedWhenClosed = false
        window.center()
        window.contentView = NSHostingView(rootView: content)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        slot = window
    }
}
