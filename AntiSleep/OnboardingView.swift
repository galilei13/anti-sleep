import SwiftUI

/// One-time first-launch screen that explains the app and requests permissions.
struct OnboardingView: View {
    @ObservedObject private var permissions = PermissionsManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 52))
                .foregroundStyle(.tint)
                .padding(.top, 8)

            Text("Welcome to AntiSleep")
                .font(.title.bold())

            Text("AntiSleep lives in your menu bar and keeps your Mac awake with a single switch — no main window, no clutter.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            GroupBox {
                HStack(spacing: 12) {
                    Image(systemName: "bell.badge")
                        .font(.title2)
                        .foregroundStyle(.tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notifications")
                            .font(.headline)
                        Text("Allow notifications so AntiSleep can confirm when it changes state.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(permissions.notificationStatus.rawValue)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                .padding(6)
            }

            HStack(spacing: 12) {
                Button("Grant Permissions") {
                    permissions.request()
                }
                .buttonStyle(.borderedProminent)

                Button("Get Started") {
                    WindowManager.shared.completeOnboarding()
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 4)
        }
        .padding(28)
        .frame(width: 460, height: 420)
        .onAppear { permissions.refresh() }
    }
}
