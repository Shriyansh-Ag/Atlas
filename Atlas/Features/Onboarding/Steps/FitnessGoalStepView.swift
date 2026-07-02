import SwiftUI

public struct FitnessGoalStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("What is your main goal?")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
                .padding(.top, 40)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(FitnessGoal.allCases) { goal in
                        SelectionCard(
                            title: goal.rawValue,
                            isSelected: viewModel.fitnessGoal == goal,
                            action: { viewModel.fitnessGoal = goal }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
        }
    }
}
