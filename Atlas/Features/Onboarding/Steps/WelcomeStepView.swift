import SwiftUI

public struct WelcomeStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    @State private var isAnimating = false
    
    public var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated Illustration
            ZStack {
                Circle()
                    .fill(Color.Atlas.primary.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                
                Image(systemName: "figure.run")
                    .font(.system(size: 80))
                    .foregroundColor(Color.Atlas.primary)
                    .offset(x: isAnimating ? 10 : -10)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
            }
            .padding(.bottom, 24)
            
            Text("Welcome to Atlas")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
            
            Text("Your personal journey to peak fitness starts here. Let's get to know you.")
                .font(AtlasTypography.body())
                .foregroundColor(Color.Atlas.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            PrimaryButton(title: "Get Started", action: {
                viewModel.nextStep()
            })
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .onAppear {
            isAnimating = true
        }
    }
}
