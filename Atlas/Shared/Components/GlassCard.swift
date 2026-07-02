import SwiftUI

public struct GlassCard<Content: View>: View {
    private let content: Content
    private let padding: CGFloat
    
    public init(padding: CGFloat = Spacing.medium, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            content
        }
        .padding(padding)
        .glassBackground()
    }
}

#Preview {
    ZStack {
        Color.Atlas.background.ignoresSafeArea()
        GlassCard {
            Text("Premium UI")
                .atlasFont(AtlasTypography.title3())
                .foregroundColor(Color.Atlas.textPrimary)
            Text("This is a glass card example that looks natively Apple.")
                .atlasFont(AtlasTypography.body())
                .foregroundColor(Color.Atlas.textSecondary)
        }
        .padding()
    }
}
