import SwiftUI
import SwiftData
import HealthKit

public struct SettingsView: View {
    @Environment(\.appEnvironment) private var environment
    @Environment(\.modelContext) private var modelContext
    @StateObject private var permissionManager = HealthPermissionManager()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.large) {
                    CustomNavigationBar(title: "Settings") {
                        Button(action: { environment.router.pop() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color.Atlas.secondary)
                        }
                    }
                    
                    Button(action: { environment.router.push(.profileSettings) }) {
                        GlassCard {
                            VStack(spacing: Spacing.medium) {
                                HStack {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(Color.Atlas.primary)
                                    
                                    VStack(alignment: .leading) {
                                        Text("My Profile")
                                            .atlasFont(AtlasTypography.title3())
                                            .foregroundColor(Color.Atlas.textPrimary)
                                        Text("Tap to edit")
                                            .atlasFont(AtlasTypography.subheadline())
                                            .foregroundColor(Color.Atlas.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.Atlas.secondary)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Spacing.medium)
                    
                    VStack(spacing: Spacing.small) {
                        SettingRow(icon: "bell.badge.fill", title: "Notifications", color: .red)
                        
                        // Health Section
                        VStack(spacing: 0) {
                            let isDetermined = permissionManager.authorizationStatus != .notDetermined
                            Button(action: { 
                                if !isDetermined {
                                    environment.router.push(.healthKitAuthorization) 
                                } else {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }) {
                                SettingRow(
                                    icon: "heart.fill", 
                                    title: "Apple Health", 
                                    color: .pink,
                                    valueText: isDetermined ? "Connected" : nil
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        
                        SettingRow(icon: "paintpalette.fill", title: "Appearance", color: .purple)
                        SettingRow(icon: "lock.fill", title: "Privacy", color: .blue)
                    }
                    .padding(.horizontal, Spacing.medium)
                    
                    Button(action: { deleteAccount() }) {
                        Text("Delete Account")
                            .atlasFont(AtlasTypography.headline())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(CornerRadius.medium)
                    }
                    .padding(.horizontal, Spacing.medium)
                    .padding(.top, Spacing.large)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            permissionManager.updateStatus()
        }
    }
    
    private func deleteAccount() {
        do {
            try modelContext.delete(model: UserProfile.self)
            try modelContext.save()
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            environment.router.popToRoot()
            environment.router.push(.onboarding)
        } catch {
            print("Failed to delete account data: \(error)")
        }
    }
}

private struct SettingRow: View {
    let icon: String
    let title: String
    let color: Color
    var valueText: String? = nil
    
    var body: some View {
        HStack(spacing: Spacing.medium) {
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .semibold))
            }
            
            Text(title)
                .atlasFont(AtlasTypography.headline())
                .foregroundColor(Color.Atlas.textPrimary)
            
            Spacer()
            
            if let text = valueText {
                Text(text)
                    .atlasFont(AtlasTypography.subheadline())
                    .foregroundColor(Color.Atlas.textSecondary)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.Atlas.secondary)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .padding()
        .glassBackground(cornerRadius: CornerRadius.medium)
    }
}

#Preview {
    SettingsView()
        .environment(\.appEnvironment, .preview)
}
