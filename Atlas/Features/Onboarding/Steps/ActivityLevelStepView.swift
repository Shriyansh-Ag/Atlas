import SwiftUI

public struct ActivityLevelStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("How active are you?")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
                .padding(.top, 40)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(ActivityLevel.allCases) { level in
                        SelectionCard(
                            title: level.rawValue,
                            subtitle: level.description,
                            isSelected: viewModel.activityLevel == level,
                            action: { viewModel.activityLevel = level }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
        }
    }
}
