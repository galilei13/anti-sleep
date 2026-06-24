import SwiftUI

/// Settings window: shows permission status and offers re-authorization.
struct SettingsView: View {
    @ObservedObject private var permissions = PermissionsManager.shared
    @ObservedObject private var sleep = SleepManager.shared
    @ObservedObject private var launch = LaunchAtLoginManager.shared

    private var launchBinding: Binding<Bool> {
        Binding(get: { launch.isEnabled }, set: { launch.setEnabled($0) })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(Theme.serif(26, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            card(title: "Status") {
                row(label: "Anti-Sleep",
                    value: sleep.isActive ? "Active" : "Inactive",
                    color: sleep.isActive ? Theme.success : Theme.textSecondary)
            }

            card(title: "General") {
                Toggle("Launch at Login", isOn: launchBinding)
                    .toggleStyle(.switch)
                    .tint(Theme.accent)
                    .foregroundStyle(Theme.textPrimary)
            }

            card(title: "Permissions") {
                VStack(alignment: .leading, spacing: 10) {
                    row(label: "Notifications",
                        value: permissions.notificationStatus.rawValue,
                        color: statusColor)

                    HStack {
                        Button("Check / Re-authorize Permissions") {
                            permissions.request()
                            permissions.refresh()
                        }
                        .buttonStyle(.themePrimary)
                        if permissions.notificationStatus == .denied {
                            Button("Open System Settings") {
                                openNotificationSettings()
                            }
                            .buttonStyle(.bordered)
                            .tint(Theme.accent)
                        }
                    }
                    .padding(.top, 4)
                }
            }

            Spacer()

            Text("AntiSleep \(appVersion)")
                .font(.caption)
                .foregroundStyle(Theme.textMuted)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(24)
        .frame(width: 460, height: 420)
        .background(Theme.bgPrimary)
        .onAppear {
            permissions.refresh()
            launch.refresh()
        }
    }

    /// A titled warm section card.
    private func card<Content: View>(title: String,
                                     @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(Theme.textMuted)
                .textCase(.uppercase)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .themeCard()
    }

    private var statusColor: Color {
        switch permissions.notificationStatus {
        case .authorized: return Theme.success
        case .denied: return Theme.error
        case .provisional: return Theme.warning
        case .notDetermined: return Theme.textMuted
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return "v\(v)"
    }

    private func row(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            Text(value)
                .font(.callout.bold())
                .foregroundStyle(color)
        }
    }

    private func openNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }
}
