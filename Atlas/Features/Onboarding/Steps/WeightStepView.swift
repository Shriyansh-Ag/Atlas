import SwiftUI

public struct WeightStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 24) {
            Text("What is your current weight?")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            UnitToggleButton(
                isMetric: $viewModel.isMetric,
                metricLabel: "kg",
                imperialLabel: "lbs"
            )
            
            Spacer()
            
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                if viewModel.isMetric {
                    TextField("Weight", value: $viewModel.weightKg, format: .number)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(Color.Atlas.primary)
                        .multilineTextAlignment(.center)
                        .frame(width: 150)
                    
                    Text("kg")
                        .font(AtlasTypography.title2())
                        .foregroundColor(Color.Atlas.textSecondary)
                } else {
                    TextField("Weight", value: $viewModel.weightLbs, format: .number)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(Color.Atlas.primary)
                        .multilineTextAlignment(.center)
                        .frame(width: 150)
                    
                    Text("lbs")
                        .font(AtlasTypography.title2())
                        .foregroundColor(Color.Atlas.textSecondary)
                }
            }
            
            Spacer()
        }
    }
}
