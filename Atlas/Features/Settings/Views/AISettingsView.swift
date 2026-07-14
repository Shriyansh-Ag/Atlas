import SwiftUI

public struct AISettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var config = AIConfiguration.shared
    
    @State private var isTesting = false
    @State private var testResult: AIStatusView.Status = .idle
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.large) {
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Provider Configuration")
                            .atlasFont(AtlasTypography.headline())
                            .foregroundColor(Color.Atlas.textPrimary)
                        
                        GlassCard {
                            VStack(spacing: Spacing.medium) {
                                HStack {
                                    Text("Active Provider")
                                        .atlasFont(AtlasTypography.body())
                                        .foregroundColor(Color.Atlas.textPrimary)
                                    Spacer()
                                    Picker("Provider", selection: $config.activeProviderRaw) {
                                        ForEach(AIConfiguration.AIProviderType.allCases, id: \.rawValue) { type in
                                            Text(type.rawValue).tag(type.rawValue)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .accentColor(Color.Atlas.primary)
                                }
                                
                                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("API Key")
                                        .atlasFont(AtlasTypography.caption())
                                        .foregroundColor(Color.Atlas.textSecondary)
                                    
                                    SecureField("Enter API Key (Optional for Mock)", text: $config.apiKey)
                                        .padding()
                                        .background(Color.black.opacity(0.2))
                                        .cornerRadius(CornerRadius.small)
                                }
                                
                                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                                
                                HStack {
                                    Button(action: testConnection) {
                                        Text(isTesting ? "Testing..." : "Test Connection")
                                            .atlasFont(AtlasTypography.subheadline(weight: .semibold))
                                            .foregroundColor(isTesting ? Color.Atlas.textSecondary : Color.Atlas.primary)
                                    }
                                    .disabled(isTesting)
                                    
                                    Spacer()
                                    
                                    AIStatusView(status: testResult)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Feature Toggles")
                            .atlasFont(AtlasTypography.headline())
                            .foregroundColor(Color.Atlas.textPrimary)
                        
                        GlassCard {
                            VStack(spacing: Spacing.medium) {
                                Toggle("Meal Recognition", isOn: $config.enableMealRecognition)
                                    .tint(Color.Atlas.primary)
                                    .atlasFont(AtlasTypography.body())
                                
                                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                                
                                Toggle("Proactive Coaching Insights", isOn: $config.enableAICoaching)
                                    .tint(Color.Atlas.primary)
                                    .atlasFont(AtlasTypography.body())
                                
                                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                                
                                Toggle("Weekly Summary Reports", isOn: $config.enableWeeklyReports)
                                    .tint(Color.Atlas.primary)
                                    .atlasFont(AtlasTypography.body())
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Privacy Notice")
                            .atlasFont(AtlasTypography.headline())
                            .foregroundColor(Color.Atlas.textPrimary)
                        
                        GlassCard {
                            Text("When using a cloud provider (Gemini, OpenAI, Anthropic), meal photos and aggregated health summaries are sent to their APIs for processing. We never store this data on our servers. You can turn off these features or use a local mock provider at any time.")
                                .atlasFont(AtlasTypography.caption())
                                .foregroundColor(Color.Atlas.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.large)
            }
        }
        .navigationTitle("Atlas Intelligence")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func testConnection() {
        guard config.isConfigured else {
            testResult = .error("API Key required (Check AIConfiguration.swift if hardcoding)")
            return
        }
        
        isTesting = true
        testResult = .loading
        
        Task {
            do {
                let provider = config.getProvider()
                let result = try await provider.generateText(prompt: "Reply with the word 'Success'")
                
                await MainActor.run {
                    isTesting = false
                    if result.lowercased().contains("success") || config.activeProviderRaw == AIConfiguration.AIProviderType.mock.rawValue {
                        testResult = .success
                    } else {
                        testResult = .error("Unexpected response")
                    }
                }
            } catch {
                await MainActor.run {
                    isTesting = false
                    if let aiError = error as? AIProviderError {
                        testResult = .error(aiError.localizedDescription)
                    } else {
                        testResult = .error("Connection failed")
                    }
                }
            }
        }
    }
}
