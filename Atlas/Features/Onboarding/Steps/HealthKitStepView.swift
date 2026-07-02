import SwiftUI

public struct HealthKitStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(Color.Atlas.primary)
                .symbolEffect(.pulse, options: .repeating)
            
            Text("Apple Health")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
            
            Text("Connect Atlas to Apple Health to automatically sync your workouts, steps, and body measurements.")
                .font(AtlasTypography.body())
                .foregroundColor(Color.Atlas.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            VStack(spacing: 16) {
                PrimaryButton(title: "Connect Health", action: {
                    Task {
                        do {
                            try await HealthKitService.shared.requestAuthorization()
                            await MainActor.run {
                                viewModel.healthKitPermissionRequested = true
                                viewModel.nextStep()
                            }
                        } catch {
                            print("HealthKit Error: \(error)")
                            await MainActor.run {
                                viewModel.healthKitPermissionRequested = false
                                viewModel.nextStep()
                            }
                        }
                    }
                })
                
                Button(action: {
                    viewModel.healthKitPermissionRequested = false
                    viewModel.nextStep()
                }) {
                    Text("Skip")
                        .font(AtlasTypography.headline())
                        .foregroundColor(Color.Atlas.textSecondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 80) // Account for bottom bar
        }
    }
}
