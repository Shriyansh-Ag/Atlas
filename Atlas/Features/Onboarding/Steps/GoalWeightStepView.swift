import SwiftUI

public struct GoalWeightStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 24) {
            Text("Do you have a goal weight?")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            Text("This is optional. You can skip it if you're not focusing on a specific number.")
                .font(AtlasTypography.body())
                .foregroundColor(Color.Atlas.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            UnitToggleButton(
                isMetric: $viewModel.isMetric,
                metricLabel: "kg",
                imperialLabel: "lbs"
            )
            
            Spacer()
            
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                if viewModel.isMetric {
                    TextField("Goal (Optional)", value: $viewModel.goalWeightKg, format: .number)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(Color.Atlas.primary)
                        .multilineTextAlignment(.center)
                        .frame(width: 200)
                    
                    Text("kg")
                        .font(AtlasTypography.title2())
                        .foregroundColor(Color.Atlas.textSecondary)
                } else {
                    TextField("Goal (Optional)", value: $viewModel.goalWeightLbs, format: .number)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(Color.Atlas.primary)
                        .multilineTextAlignment(.center)
                        .frame(width: 200)
                    
                    Text("lbs")
                        .font(AtlasTypography.title2())
                        .foregroundColor(Color.Atlas.textSecondary)
                }
            }
            
            Spacer()
        }
    }
}
