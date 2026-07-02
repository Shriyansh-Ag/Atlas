import SwiftUI

public struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    
    public func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark) // Enforce dark mode on glass for consistent look
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 8)
    }
}

public extension View {
    func glassBackground(cornerRadius: CGFloat = CornerRadius.large) -> some View {
        modifier(GlassModifier(cornerRadius: cornerRadius))
    }
}
