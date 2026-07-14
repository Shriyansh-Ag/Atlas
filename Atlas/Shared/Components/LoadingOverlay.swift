import SwiftUI

/// Full-screen semi-transparent overlay with a pulsing Atlas Intelligence animation.
/// Used during AI operations that take a few seconds (meal recognition, recipe generation, etc.)
public struct LoadingOverlay: View {
    @State private var isPulsing = false
    @State private var rotation: Double = 0
    
    public var message: String
    
    public init(message: String = "Atlas Intelligence is thinking...") {
        self.message = message
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.large) {
                ZStack {
                    // Outer pulsing ring
                    Circle()
                        .stroke(Color.Atlas.primary.opacity(0.3), lineWidth: 2)
                        .frame(width: 100, height: 100)
                        .scaleEffect(isPulsing ? 1.3 : 1.0)
                        .opacity(isPulsing ? 0.0 : 0.6)
                    
                    // Inner rotating ring
                    Circle()
                        .trim(from: 0.0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [Color.Atlas.primary, Color.Atlas.primary.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(rotation))
                    
                    // Center icon
                    Image(systemName: "sparkles")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(Color.Atlas.primary)
                        .scaleEffect(isPulsing ? 1.1 : 0.9)
                }
                
                VStack(spacing: Spacing.xSmall) {
                    Text(message)
                        .atlasFont(AtlasTypography.headline())
                        .foregroundColor(Color.Atlas.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("This may take a few seconds")
                        .atlasFont(AtlasTypography.caption())
                        .foregroundColor(Color.Atlas.textTertiary)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading. \(message)")
    }
}
