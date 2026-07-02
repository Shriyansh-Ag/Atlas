import SwiftUI

public struct NotificationsStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundColor(Color.Atlas.primary)
            
            Text("Stay on Track")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
            
            Text("Allow notifications to get reminders for your workouts, meals, and daily check-ins. You can always change this later.")
                .font(AtlasTypography.body())
                .foregroundColor(Color.Atlas.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            VStack(spacing: 16) {
                PrimaryButton(title: "Enable Notifications", action: {
                    // Actual permission request will go here.
                    // For now, simulate granting it.
                    viewModel.notificationPermissionGranted = true
                    viewModel.nextStep()
                })
                
                Button(action: {
                    viewModel.notificationPermissionGranted = false
                    viewModel.nextStep()
                }) {
                    Text("Not Now")
                        .font(AtlasTypography.headline())
                        .foregroundColor(Color.Atlas.textSecondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 80) // Account for bottom bar
        }
    }
}
