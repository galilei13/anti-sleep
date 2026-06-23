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
                .font(.title2.bold())

            card(title: "Status") {
                row(label: "Anti-Sleep",
                    value: sleep.isActive ? "Active" : "Inactive",
                    color: sleep.isActive ? .green : .secondary)
            }

            card(title: "General") {
                Toggle("Launch at Login", isOn: launchBinding)
                    .toggleStyle(.switch)
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
                        if permissions.notificationStatus == .denied {
                            Button("Open System Settings") {
                                openNotificationSettings()
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 4)
                }
            }

            Spacer()

            Text("AntiSleep \(appVersion)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(24)
        .frame(width: 460, height: 420)
        .onAppear {
            permissions.refresh()
            launch.refresh()
        }
    }

    /// A titled glass section card.
    private func card<Content: View>(title: String,
                                     @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private var statusColor: Color {
        switch permissions.notificationStatus {
        case .authorized: return .green
        case .denied: return .red
        case .provisional: return .orange
        case .notDetermined: return .secondary
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.2"
        return "v\(v)"
    }

    private func row(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
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
