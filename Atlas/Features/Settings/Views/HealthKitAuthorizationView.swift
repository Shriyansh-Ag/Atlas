import SwiftUI
import HealthKit

public struct HealthKitAuthorizationView: View {
    @Environment(\.appEnvironment) private var environment
    @StateObject private var permissionManager = HealthPermissionManager()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.xLarge) {
                    // Header
                    VStack(spacing: Spacing.medium) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color.Atlas.primary)
                            .padding(.top, 40)
                        
                        Text("Connect Apple Health")
                            .atlasFont(AtlasTypography.title())
                            .foregroundColor(Color.Atlas.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Atlas uses HealthKit as the single source of truth for your fitness journey. We read your data to provide insights and write your logged data back so your records stay in sync.")
                            .atlasFont(AtlasTypography.body())
                            .foregroundColor(Color.Atlas.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.large)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: Spacing.large) {
                        FeatureRow(
                            icon: "figure.walk",
                            title: "Activity Tracking",
                            description: "Automatically sync your steps, workouts, and energy burned."
                        )
                        
                        FeatureRow(
                            icon: "bed.double.fill",
                            title: "Sleep & Recovery",
                            description: "Read sleep stages to calculate your daily recovery score."
                        )
                        
                        FeatureRow(
                            icon: "scalemass.fill",
                            title: "Body Measurements",
                            description: "Sync your weight and body fat percentage seamlessly."
                        )
                    }
                    .padding(.horizontal, Spacing.large)
                    
                    Spacer(minLength: 40)
                    
                    // Action Buttons
                    VStack(spacing: Spacing.medium) {
                        if let error = permissionManager.error {
                            Text(error)
                                .atlasFont(AtlasTypography.subheadline())
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, Spacing.small)
                        }
                        
                        if permissionManager.isRequesting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.Atlas.primary))
                        } else {
                            Button(action: {
                                Task {
                                    await permissionManager.requestPermissions()
                                    if permissionManager.authorizationStatus != .notDetermined {
                                        environment.router.pop()
                                    }
                                }
                            }) {
                                Text("Continue")
                                    .atlasFont(AtlasTypography.headline())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.Atlas.primary)
                                    .cornerRadius(CornerRadius.medium)
                            }
                            
                            Button(action: {
                                environment.router.pop()
                            }) {
                                Text("Not Now")
                                    .atlasFont(AtlasTypography.headline())
                                    .foregroundColor(Color.Atlas.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.large)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(Color.Atlas.primary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .atlasFont(AtlasTypography.headline())
                    .foregroundColor(Color.Atlas.textPrimary)
                
                Text(description)
                    .atlasFont(AtlasTypography.subheadline())
                    .foregroundColor(Color.Atlas.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    HealthKitAuthorizationView()
        .environment(\.appEnvironment, .preview)
}
