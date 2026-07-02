import SwiftUI

public struct FinishStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    public var environment: AppEnvironment
    
    @State private var isSaving = false
    
    public var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            if isSaving {
                ProgressView()
                    .scaleEffect(2)
                    .tint(Color.Atlas.primary)
                Text("Personalizing Atlas...")
                    .font(AtlasTypography.title2())
                    .foregroundColor(Color.Atlas.textPrimary)
                    .padding(.top, 16)
            } else {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color.Atlas.success)
                
                Text("All Set!")
                    .font(AtlasTypography.largeTitle())
                    .foregroundColor(Color.Atlas.textPrimary)
                
                Text("We've tailored everything for you. Let's start your journey.")
                    .font(AtlasTypography.body())
                    .foregroundColor(Color.Atlas.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            PrimaryButton(title: "Go to Dashboard", action: {
                finishOnboarding()
            })
            .padding(.horizontal)
            .padding(.bottom, 32)
            .disabled(isSaving)
        }
    }
    
    private func finishOnboarding() {
        isSaving = true
        // Allow a small delay for UI effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            viewModel.saveProfile {
                // Navigate to dashboard
                environment.router.push(.dashboard)
            }
        }
    }
}
