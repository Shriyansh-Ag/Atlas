import SwiftUI

public struct AgeStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 24) {
            Text("How old are you?")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
                .padding(.horizontal)
                .padding(.top, 40)
            
            Text("This helps us calculate your calorie and macro needs accurately.")
                .font(AtlasTypography.body())
                .foregroundColor(Color.Atlas.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Picker("Age", selection: $viewModel.age) {
                ForEach(13...100, id: \.self) { age in
                    Text("\(age)").tag(age)
                        .font(AtlasTypography.largeTitle())
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 250)
            .clipped()
            
            Spacer()
        }
    }
}
