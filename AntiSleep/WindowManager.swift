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
                size: NSSize(width: 460, height: 520),
                content: OnboardingView())
    }

    func showSettings() {
        present(&settingsWindow,
                title: "AntiSleep Settings",
                size: NSSize(width: 460, height: 420),
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
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.isReleasedWhenClosed = false
        // Warm, borderless look: transparent titlebar over a cream content fill.
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.backgroundColor = NSColor(name: nil) {
            $0.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
                ? NSColor(srgbRed: 0x21/255, green: 0x20/255, blue: 0x1B/255, alpha: 1)
                : NSColor(srgbRed: 0xF4/255, green: 0xF1/255, blue: 0xEA/255, alpha: 1)
        }
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.center()

        let host = NSHostingView(rootView: ZStack {
            ThemeWindowBackground()
            content
        })
        window.contentView = host
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        slot = window
    }
}
