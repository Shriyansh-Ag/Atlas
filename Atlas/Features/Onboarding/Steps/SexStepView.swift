import SwiftUI

public struct SexStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 24) {
            Text("What is your biological sex?")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 40)
            
            Text("This is required for accurate basal metabolic rate (BMR) calculations.")
                .font(AtlasTypography.body())
                .foregroundColor(Color.Atlas.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 16) {
                ForEach(BiologicalSex.allCases) { sex in
                    SelectionCard(
                        title: sex.rawValue,
                        isSelected: viewModel.biologicalSex == sex,
                        action: { viewModel.biologicalSex = sex }
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}
