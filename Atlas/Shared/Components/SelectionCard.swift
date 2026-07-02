import SwiftUI

public struct SelectionCard: View {
    public let title: String
    public let subtitle: String?
    public let isSelected: Bool
    public let action: () -> Void
    
    public init(title: String, subtitle: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AtlasTypography.headline())
                        .foregroundColor(isSelected ? .white : Color.Atlas.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(AtlasTypography.subheadline())
                            .foregroundColor(isSelected ? .white.opacity(0.8) : Color.Atlas.textSecondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "circle")
                        .font(.title3)
                        .foregroundColor(Color.Atlas.textTertiary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.Atlas.primary : Color.Atlas.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.Atlas.primary : Color.Atlas.surface, lineWidth: 2)
            )
        }
        .buttonStyle(.plain) // Prevent default button styling issues
    }
}
