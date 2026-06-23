import SwiftUI

/// Shared "Liquid Glass" design tokens and reusable view styling so the
/// popover and Settings window stay visually consistent.
enum Glass {
    static let cardRadius: CGFloat = 16
    static let innerRadius: CGFloat = 12
    static let cardPadding: CGFloat = 14
}

/// A translucent glass card: ultra-thin material, smooth continuous corners,
/// a subtle top-edge highlight, and a soft shadow for depth.
private struct GlassCardModifier: ViewModifier {
    var radius: CGFloat = Glass.cardRadius
    var padding: CGFloat = Glass.cardPadding

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial, in: shape)
            .overlay(
                shape.strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.35), .white.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
            )
            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
    }
}

/// Fills a window with vibrant glass so opaque system backgrounds disappear.
struct GlassWindowBackground: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .ignoresSafeArea()
            .overlay(
                LinearGradient(
                    colors: [.white.opacity(0.06), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
    }
}

extension View {
    /// Wraps the view in a translucent glass card.
    func glassCard(radius: CGFloat = Glass.cardRadius,
                   padding: CGFloat = Glass.cardPadding) -> some View {
        modifier(GlassCardModifier(radius: radius, padding: padding))
    }
}
