import SwiftUI

public struct SplashView: View {
    @Environment(\.appEnvironment) private var environment
    @State private var opacity = 0.0
    @State private var scale = 0.8
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            VStack(spacing: Spacing.large) {
                Image(systemName: "bolt.heart.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color.Atlas.primary)
                
                Text("ATLAS")
                    .atlasFont(AtlasTypography.largeTitle(weight: .black))
                    .foregroundColor(Color.Atlas.textPrimary)
                    .tracking(8)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(AtlasAnimations.springBouncy) {
                opacity = 1.0
                scale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                if hasCompletedOnboarding {
                    environment.router.push(.dashboard)
                } else {
                    environment.router.push(.onboarding)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
