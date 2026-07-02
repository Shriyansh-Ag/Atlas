import SwiftUI

public struct WorkoutExperienceStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("What's your workout experience?")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 40)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(WorkoutExperience.allCases) { exp in
                        SelectionCard(
                            title: exp.rawValue,
                            isSelected: viewModel.workoutExperience == exp,
                            action: { viewModel.workoutExperience = exp }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
        }
    }
}
