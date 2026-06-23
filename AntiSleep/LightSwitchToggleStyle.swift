import SwiftUI

/// A toggle styled like a physical wall light switch: a recessed plate with a
/// rocker that snaps between the top (ON) and bottom (OFF) positions.
struct LightSwitchToggleStyle: ToggleStyle {
    var onColor: Color = .green
    var offColor: Color = Color(nsColor: .quaternaryLabelColor)

    func makeBody(configuration: Configuration) -> some View {
        let isOn = configuration.isOn
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.62)) {
                configuration.isOn.toggle()
            }
        } label: {
            ZStack(alignment: isOn ? .top : .bottom) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isOn ? onColor.opacity(0.22) : offColor.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.black.opacity(0.18), lineWidth: 1)
                    )
                    .frame(width: 54, height: 92)

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isOn
                                ? [Color.white, onColor.opacity(0.9)]
                                : [Color(white: 0.95), Color(white: 0.78)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 46, height: 52)
                    .overlay(
                        Text(isOn ? "ON" : "OFF")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(isOn ? onColor : .secondary)
                            .padding(isOn ? .top : .bottom, 6),
                        alignment: isOn ? .top : .bottom
                    )
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: isOn ? 2 : -2)
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
