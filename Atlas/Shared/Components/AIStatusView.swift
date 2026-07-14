import SwiftUI

/// Small inline status indicator for AI-powered features.
/// Shows loading, error, or success states.
public struct AIStatusView: View {
    public enum Status: Equatable {
        case idle
        case loading
        case success
        case error(String)
    }
    
    public let status: Status
    
    public init(status: Status) {
        self.status = status
    }
    
    public var body: some View {
        HStack(spacing: 6) {
            switch status {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.Atlas.primary))
                    .scaleEffect(0.7)
                Text("Atlas Intelligence thinking...")
                    .atlasFont(AtlasTypography.caption())
                    .foregroundColor(Color.Atlas.textSecondary)
            case .success:
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(Color.Atlas.primary)
                Text("Powered by Atlas Intelligence")
                    .atlasFont(AtlasTypography.caption())
                    .foregroundColor(Color.Atlas.textTertiary)
            case .error(let message):
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color.Atlas.warning)
                Text(message)
                    .atlasFont(AtlasTypography.caption())
                    .foregroundColor(Color.Atlas.textSecondary)
                    .lineLimit(1)
            }
        }
        .animation(AtlasAnimations.transition, value: status)
    }
}
