import SwiftUI

/// The popover shown from the status bar item.
struct MenuContentView: View {
    @ObservedObject private var sleep = SleepManager.shared
    @ObservedObject private var timer = TimerManager.shared
    @ObservedObject private var windows = WindowManager.shared

    private var binding: Binding<Bool> {
        Binding(
            get: { sleep.isActive },
            set: { _ in
                if timer.isActive { timer.cancel() } else { sleep.toggle() }
            }
        )
    }

    private let presets: [(label: String, seconds: Int)] = [
        ("30m", 30 * 60),
        ("1h",  60 * 60),
        ("2h", 120 * 60),
        ("4h", 240 * 60),
    ]

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
                if timer.isActive {
                    Text(timer.formattedRemaining)
                        .font(.system(size: 13, weight: .medium).monospacedDigit())
                        .foregroundStyle(Theme.accent)
                }
            }

            VStack(spacing: 12) {
                Toggle("Anti-Sleep", isOn: binding)
                    .toggleStyle(.lightSwitch)
                    .labelsHidden()

                Text(statusText)
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

            // Timer presets
            VStack(alignment: .leading, spacing: 8) {
                Text("Sleep timer")
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
                HStack(spacing: 6) {
                    ForEach(presets, id: \.seconds) { preset in
                        Button(preset.label) {
                            timer.start(seconds: preset.seconds)
                        }
                        .buttonStyle(TimerPresetButtonStyle(
                            isActive: timer.isActive &&
                                      timer.remainingSeconds.map { $0 <= preset.seconds + 1 } ?? false
                        ))
                    }
                    Spacer()
                    if timer.isActive {
                        Button("Cancel") { timer.cancel() }
                            .buttonStyle(.borderless)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
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
        .frame(width: 260)
        .background(Theme.bgPrimary)
        .fixedSize()
    }

    private var statusText: String {
        if timer.isActive { return "Staying awake for \(timer.formattedRemaining)." }
        return sleep.isActive ? "Your Mac will stay awake." : "Your Mac can sleep normally."
    }
}

private struct TimerPresetButtonStyle: ButtonStyle {
    let isActive: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isActive ? Theme.accent : Theme.accentSoft)
            .foregroundStyle(isActive ? Color.white : Theme.accent)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSm))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
