import SwiftUI
import AppKit

/// Claude.ai-inspired design system: warm cream palette, serif headings,
/// sans-serif body, soft corners. Light/dark adaptive (warm-dark, never
/// clinical black).
enum Theme {
    // Radii
    static let radiusSm: CGFloat = 6
    static let radiusMd: CGFloat = 10   // buttons / toggles / controls
    static let radiusLg: CGFloat = 16   // container cards

    // Backgrounds
    static let bgPrimary   = dyn(0xF4F1EA, 0x21201B)
    static let bgSecondary = dyn(0xEEEAE0, 0x2B2924)
    static let bgElevated  = dyn(0xFFFFFF, 0x34322B)

    // Text
    static let textPrimary   = dyn(0x1F1B16, 0xF4F1EA)
    static let textSecondary = dyn(0x6B6358, 0xB5AE9F)
    static let textMuted     = dyn(0x9A9286, 0x847C6F)

    // Accent
    static let accent     = dyn(0xC2693B, 0xD67C4C)
    static let accentSoft = dyn(0xEDD9C8, 0x4A3528)

    // Borders & status
    static let border  = dyn(0xDEDAD0, 0x3C3A32)
    static let success = dyn(0x4F7D5C, 0x6FA37E)
    static let error   = dyn(0xB3493F, 0xD46B61)
    static let warning = dyn(0xC9952B, 0xDCAE4E)

    static let shadow = Color.black.opacity(0.08)

    // Serif display font for headings / brand identity.
    static func serif(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    private static func dyn(_ light: UInt, _ dark: UInt) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            return NSColor(hex: isDark ? dark : light)
        })
    }
}

extension NSColor {
    fileprivate convenience init(hex: UInt) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

/// A warm elevated card with a hairline border and very subtle shadow.
private struct ThemeCardModifier: ViewModifier {
    var radius: CGFloat = Theme.radiusLg
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return content
            .padding(padding)
            .background(Theme.bgElevated, in: shape)
            .overlay(shape.strokeBorder(Theme.border, lineWidth: 1))
            .shadow(color: Theme.shadow, radius: 3, x: 0, y: 1)
    }
}

/// Accent-filled primary action button.
struct ThemePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundStyle(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                Theme.accent.opacity(configuration.isPressed ? 0.85 : 1),
                in: RoundedRectangle(cornerRadius: Theme.radiusMd, style: .continuous)
            )
    }
}

extension ButtonStyle where Self == ThemePrimaryButtonStyle {
    static var themePrimary: ThemePrimaryButtonStyle { ThemePrimaryButtonStyle() }
}

/// Solid warm-cream window fill.
struct ThemeWindowBackground: View {
    var body: some View { Theme.bgPrimary.ignoresSafeArea() }
}

extension View {
    func themeCard(radius: CGFloat = Theme.radiusLg, padding: CGFloat = 16) -> some View {
        modifier(ThemeCardModifier(radius: radius, padding: padding))
    }
}
