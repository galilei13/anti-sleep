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
                    .foregroundStyle(sleep.isActive ? .green : .secondary)
                Text("AntiSleep")
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 12) {
                Toggle("Anti-Sleep", isOn: binding)
                    .toggleStyle(.lightSwitch)
                    .labelsHidden()

                Text(sleep.isActive ? "Your Mac will stay awake." : "Your Mac can sleep normally.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 20)
                    .animation(nil, value: sleep.isActive)
            }
            .frame(maxWidth: .infinity)
            .glassCard()

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
        }
        .padding(18)
        .frame(width: 260, height: 250)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Glass.cardRadius, style: .continuous))
        .fixedSize()
    }
}
