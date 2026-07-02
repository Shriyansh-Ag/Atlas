import SwiftUI

public struct ProgressBar: View {
    public let progress: Double // 0.0 to 1.0
    
    public init(progress: Double) {
        self.progress = progress
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.Atlas.surface)
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.Atlas.primary)
                    .frame(width: max(0, geometry.size.width * CGFloat(progress)), height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: 8)
    }
}
