import SwiftUI

/// One-time first-launch screen that explains the app and requests permissions.
struct OnboardingView: View {
    @ObservedObject private var permissions = PermissionsManager.shared
    @ObservedObject private var launch = LaunchAtLoginManager.shared

    private var launchBinding: Binding<Bool> {
        Binding(get: { launch.isEnabled }, set: { launch.setEnabled($0) })
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 52))
                .foregroundStyle(Theme.accent)
                .padding(.top, 8)

            Text("Welcome to AntiSleep")
                .font(Theme.serif(28, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            Text("AntiSleep lives in your menu bar and keeps your Mac awake with a single switch — no main window, no clutter.")
                .font(.body)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            permissionRow(
                icon: "bell.badge",
                title: "Notifications",
                detail: "Allow notifications so AntiSleep can confirm when it changes state.",
                trailing: AnyView(
                    Text(permissions.notificationStatus.rawValue)
                        .font(.caption.bold())
                        .foregroundStyle(Theme.textSecondary)
                )
            )

            permissionRow(
                icon: "power",
                title: "Launch at Login",
                detail: "Start AntiSleep automatically when you log in.",
                trailing: AnyView(
                    Toggle("", isOn: launchBinding)
                        .toggleStyle(.switch)
                        .tint(Theme.accent)
                        .labelsHidden()
                )
            )

            HStack(spacing: 12) {
                Button("Grant Permissions") {
                    permissions.request()
                }
                .buttonStyle(.themePrimary)

                Button("Get Started") {
                    WindowManager.shared.completeOnboarding()
                }
                .buttonStyle(.bordered)
                .tint(Theme.accent)
            }
            .padding(.top, 4)
        }
        .padding(28)
        .frame(width: 460, height: 520)
        .background(Theme.bgPrimary)
        .onAppear {
            permissions.refresh()
            launch.refresh()
        }
    }

    private func permissionRow(icon: String, title: String,
                               detail: String, trailing: AnyView) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Theme.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            trailing
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .themeCard()
    }
}
