import SwiftUI

public struct CustomNavigationBar<Trailing: View>: View {
    let title: String
    let trailingView: Trailing
    
    public init(title: String, @ViewBuilder trailingView: () -> Trailing) {
        self.title = title
        self.trailingView = trailingView()
    }
    
    public var body: some View {
        HStack(alignment: .bottom) {
            Text(title)
                .atlasFont(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
            
            Spacer()
            
            trailingView
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.top, Spacing.large)
        .padding(.bottom, Spacing.small)
        .background(
            Color.Atlas.background
                .ignoresSafeArea(edges: .top)
        )
    }
}

public extension CustomNavigationBar where Trailing == EmptyView {
    init(title: String) {
        self.title = title
        self.trailingView = EmptyView()
    }
}
