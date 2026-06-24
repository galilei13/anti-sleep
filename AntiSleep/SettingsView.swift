import SwiftUI

/// Settings window: shows permission status and offers re-authorization.
struct SettingsView: View {
    @ObservedObject private var permissions = PermissionsManager.shared
    @ObservedObject private var sleep = SleepManager.shared
    @ObservedObject private var launch = LaunchAtLoginManager.shared
    @ObservedObject private var timer = TimerManager.shared
    @ObservedObject private var appTrigger = AppTriggerManager.shared
    @ObservedObject private var battery = BatteryMonitor.shared

    @State private var newAppName: String = ""

    private var launchBinding: Binding<Bool> {
        Binding(get: { launch.isEnabled }, set: { launch.setEnabled($0) })
    }
    private var batteryEnabledBinding: Binding<Bool> {
        Binding(
            get: { UserDefaults.standard.bool(forKey: "batteryAwareModeEnabled") },
            set: { UserDefaults.standard.set($0, forKey: "batteryAwareModeEnabled")
                   battery.refreshSettings() }
        )
    }
    private var batteryThresholdBinding: Binding<Int> {
        Binding(
            get: { UserDefaults.standard.integer(forKey: "batteryThreshold") == 0
                   ? 20
                   : UserDefaults.standard.integer(forKey: "batteryThreshold") },
            set: { UserDefaults.standard.set($0, forKey: "batteryThreshold")
                   battery.refreshSettings() }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Settings")
                    .font(Theme.serif(26, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                card(title: "Status") {
                    row(label: "Anti-Sleep",
                        value: sleep.isActive ? "Active" : "Inactive",
                        color: sleep.isActive ? Theme.success : Theme.textSecondary)
                    if timer.isActive {
                        row(label: "Timer", value: timer.formattedRemaining, color: Theme.accent)
                    }
                    if let app = appTrigger.triggeredByApp {
                        row(label: "Triggered by", value: app, color: Theme.warning)
                    }
                    if battery.pausedByBattery {
                        row(label: "Battery", value: "Paused (\(battery.batteryLevel)%)", color: Theme.error)
                    }
                }

                card(title: "General") {
                    Toggle("Launch at Login", isOn: launchBinding)
                        .toggleStyle(.switch)
                        .tint(Theme.accent)
                        .foregroundStyle(Theme.textPrimary)
                }

                card(title: "App Triggers") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Auto-enable when these apps are running:")
                            .font(.caption)
                            .foregroundStyle(Theme.textMuted)

                        if appTrigger.watchedApps.isEmpty {
                            Text("No apps configured.")
                                .font(.callout)
                                .foregroundStyle(Theme.textMuted)
                        } else {
                            ForEach(appTrigger.watchedApps, id: \.self) { app in
                                HStack {
                                    Text(app).foregroundStyle(Theme.textPrimary)
                                    Spacer()
                                    Button {
                                        appTrigger.removeApp(app)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(Theme.textMuted)
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        }

                        HStack {
                            TextField("App name (e.g. Zoom)", text: $newAppName)
                                .textFieldStyle(.roundedBorder)
                            Button("Add") {
                                let name = newAppName.trimmingCharacters(in: .whitespaces)
                                guard !name.isEmpty else { return }
                                appTrigger.addApp(name)
                                newAppName = ""
                            }
                            .buttonStyle(.themePrimary)
                            .disabled(newAppName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .padding(.top, 4)
                    }
                }

                card(title: "Battery") {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Pause when on battery below threshold",
                               isOn: batteryEnabledBinding)
                            .toggleStyle(.switch)
                            .tint(Theme.accent)
                            .foregroundStyle(Theme.textPrimary)

                        if batteryEnabledBinding.wrappedValue {
                            HStack {
                                Text("Threshold: \(batteryThresholdBinding.wrappedValue)%")
                                    .foregroundStyle(Theme.textPrimary)
                                Stepper("", value: batteryThresholdBinding, in: 5...50, step: 5)
                                    .labelsHidden()
                            }
                        }

                        HStack(spacing: 4) {
                            Image(systemName: battery.isPluggedIn ? "bolt.fill" : "battery.75")
                                .foregroundStyle(battery.isPluggedIn ? Theme.success : Theme.textSecondary)
                            Text(battery.isPluggedIn
                                 ? "Charging — \(battery.batteryLevel)%"
                                 : "On battery — \(battery.batteryLevel)%")
                                .font(.callout)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .padding(.top, 2)
                    }
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

                Text("AntiSleep \(appVersion)")
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
            .padding(24)
        }
        .frame(width: 460, height: 560)
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
