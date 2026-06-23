import SwiftUI

/// A toggle styled like a physical wall light switch: a recessed plate with a
/// rocker that snaps between the top (ON) and bottom (OFF) positions.
struct LightSwitchToggleStyle: ToggleStyle {
    var onColor: Color = Theme.accent
    var offColor: Color = Theme.bgSecondary

    func makeBody(configuration: Configuration) -> some View {
        let isOn = configuration.isOn
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.62)) {
                configuration.isOn.toggle()
            }
        } label: {
            ZStack(alignment: isOn ? .top : .bottom) {
                RoundedRectangle(cornerRadius: Theme.radiusMd, style: .continuous)
                    .fill(isOn ? onColor.opacity(0.22) : offColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusMd, style: .continuous)
                            .strokeBorder(isOn ? onColor.opacity(0.5) : Theme.border, lineWidth: 1)
                    )
                    .frame(width: 54, height: 92)

                RoundedRectangle(cornerRadius: Theme.radiusSm, style: .continuous)
                    .fill(Theme.bgElevated)
                    .frame(width: 46, height: 52)
                    .overlay(
                        Text(isOn ? "ON" : "OFF")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(isOn ? onColor : Theme.textMuted)
                            .padding(isOn ? .top : .bottom, 6),
                        alignment: isOn ? .top : .bottom
                    )
                    .shadow(color: Theme.shadow, radius: 2, x: 0, y: isOn ? 2 : -2)
                    .padding(.vertical, 4)
            }
            .accessibilityLabel("Anti-Sleep")
            .accessibilityValue(isOn ? "On" : "Off")
        }
        .buttonStyle(.plain)
    }
}

extension ToggleStyle where Self == LightSwitchToggleStyle {
    static var lightSwitch: LightSwitchToggleStyle { LightSwitchToggleStyle() }
}
