import SwiftUI

public struct NameStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    @FocusState private var isFocused: Bool
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What should we call you?")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
                .padding(.horizontal)
                .padding(.top, 40)
            
            TextField("Your Name", text: $viewModel.name)
                .font(AtlasTypography.title2())
                .foregroundColor(Color.Atlas.textPrimary)
                .padding()
                .background(Color.Atlas.surface)
                .cornerRadius(12)
                .padding(.horizontal)
                .focused($isFocused)
                .submitLabel(.continue)
                .onSubmit {
                    if viewModel.isCurrentStepValid {
                        viewModel.nextStep()
                    }
                }
            
            if !viewModel.name.isEmpty {
                Text("Nice to meet you, \(viewModel.name)!")
                    .font(AtlasTypography.callout())
                    .foregroundColor(Color.Atlas.primary)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
            
            Spacer()
        }
        .onAppear {
            isFocused = true
        }
    }
}
