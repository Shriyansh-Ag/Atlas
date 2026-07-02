import SwiftUI

public struct LoadingView: View {
    let message: String?
    
    public init(message: String? = nil) {
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: Spacing.medium) {
            ProgressView()
                .controlSize(.large)
                .tint(Color.Atlas.primary)
            
            if let message = message {
                Text(message)
                    .atlasFont(AtlasTypography.headline())
                    .foregroundColor(Color.Atlas.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Atlas.background)
    }
}
