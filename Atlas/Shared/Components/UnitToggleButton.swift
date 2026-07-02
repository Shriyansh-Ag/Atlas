import SwiftUI

public struct UnitToggleButton: View {
    @Binding public var isMetric: Bool
    public let metricLabel: String
    public let imperialLabel: String
    
    public init(isMetric: Binding<Bool>, metricLabel: String, imperialLabel: String) {
        self._isMetric = isMetric
        self.metricLabel = metricLabel
        self.imperialLabel = imperialLabel
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                withAnimation(.snappy) {
                    isMetric = true
                }
            }) {
                Text(metricLabel)
                    .font(AtlasTypography.subheadline(weight: isMetric ? .bold : .medium))
                    .foregroundColor(isMetric ? .white : Color.Atlas.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isMetric ? Color.Atlas.primary : Color.clear)
                    )
            }
            
            Button(action: {
                withAnimation(.snappy) {
                    isMetric = false
                }
            }) {
                Text(imperialLabel)
                    .font(AtlasTypography.subheadline(weight: !isMetric ? .bold : .medium))
                    .foregroundColor(!isMetric ? .white : Color.Atlas.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(!isMetric ? Color.Atlas.primary : Color.clear)
                    )
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.Atlas.surface)
        )
        .frame(width: 200)
    }
}
