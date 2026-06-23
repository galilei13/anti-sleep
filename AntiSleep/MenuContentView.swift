import SwiftUI

/// The popover shown from the status bar item.
struct MenuContentView: View {
    @ObservedObject private var sleep = SleepManager.shared
    @ObservedObject private var windows = WindowManager.shared

    private var binding: Binding<Bool> {
        Binding(get: { sleep.isActive }, set: { _ in sleep.toggle() })
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: sleep.isActive ? "cup.and.saucer.fill" : "moon.zzz")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(sleep.isActive ? Theme.accent : Theme.textSecondary)
                Text("AntiSleep")
                    .font(Theme.serif(17))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
            }

            VStack(spacing: 12) {
                Toggle("Anti-Sleep", isOn: binding)
                    .toggleStyle(.lightSwitch)
                    .labelsHidden()

                Text(sleep.isActive ? "Your Mac will stay awake." : "Your Mac can sleep normally.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 20)
                    .animation(nil, value: sleep.isActive)
            }
            .frame(maxWidth: .infinity)
            .themeCard()

            HStack {
                Button {
                    windows.showSettings()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                Spacer()
                Button {
                    NSApp.terminate(nil)
                } label: {
                    Label("Quit", systemImage: "power")
                }
            }
            .buttonStyle(.borderless)
            .tint(Theme.accent)
        }
        .padding(18)
        .frame(width: 260, height: 250)
        .background(Theme.bgPrimary)
        .fixedSize()
    }
}
