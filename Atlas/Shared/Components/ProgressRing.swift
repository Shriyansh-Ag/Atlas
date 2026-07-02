import SwiftUI

public struct ProgressRing: View {
    let progress: Double
    let color: Color
    let thickness: CGFloat
    let size: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    public init(progress: Double, color: Color = Color.Atlas.primary, thickness: CGFloat = 12, size: CGFloat = 120) {
        self.progress = min(max(progress, 0), 1)
        self.color = color
        self.thickness = thickness
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: thickness, lineCap: .round))
            
            // Progress
            Circle()
                .trim(from: 0.0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: thickness, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(Angle(degrees: -90))
                .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 0)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(AtlasAnimations.springSmooth.delay(0.1)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(AtlasAnimations.springSmooth) {
                animatedProgress = newValue
            }
        }
    }
}
