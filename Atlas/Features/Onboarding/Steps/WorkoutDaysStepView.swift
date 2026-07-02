import SwiftUI

public struct WorkoutDaysStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 24) {
            Text("How many days per week can you work out?")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 40)
            
            Spacer()
            
            Text("\(viewModel.workoutDaysPerWeek) Days")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(Color.Atlas.primary)
            
            Stepper("", value: $viewModel.workoutDaysPerWeek, in: 0...7)
                .labelsHidden()
                .scaleEffect(1.5)
                .padding()
            
            Spacer()
        }
    }
}
