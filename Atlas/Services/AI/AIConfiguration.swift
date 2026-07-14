import Foundation
import SwiftUI
import Combine

public class AIConfiguration: ObservableObject {
    public static let shared = AIConfiguration()
    
    // 👱‍♀️ ponytail: hardcoded API key fallback for quick testing without UI entry
    public let hardcodedAPIKey = "YOUR_API_KEY_HERE"
    
    @Published public var activeProviderRaw: String {
        didSet { UserDefaults.standard.set(activeProviderRaw, forKey: "aiProvider") }
    }
    
    @Published public var apiKey: String {
        didSet { UserDefaults.standard.set(apiKey, forKey: "aiApiKey") }
    }
    
    @Published public var enableMealRecognition: Bool {
        didSet { UserDefaults.standard.set(enableMealRecognition, forKey: "enableMealRecognition") }
    }
    
    @Published public var enableAICoaching: Bool {
        didSet { UserDefaults.standard.set(enableAICoaching, forKey: "enableAICoaching") }
    }
    
    @Published public var enableWeeklyReports: Bool {
        didSet { UserDefaults.standard.set(enableWeeklyReports, forKey: "enableWeeklyReports") }
    }
    
    private init() {
        self.activeProviderRaw = UserDefaults.standard.string(forKey: "aiProvider") ?? AIProviderType.mock.rawValue
        self.apiKey = UserDefaults.standard.string(forKey: "aiApiKey") ?? ""
        self.enableMealRecognition = UserDefaults.standard.object(forKey: "enableMealRecognition") as? Bool ?? true
        self.enableAICoaching = UserDefaults.standard.object(forKey: "enableAICoaching") as? Bool ?? true
        self.enableWeeklyReports = UserDefaults.standard.object(forKey: "enableWeeklyReports") as? Bool ?? true
    }
    
    public enum AIProviderType: String, CaseIterable {
        case mock = "Mock / Offline"
        case gemini = "Google Gemini"
        case openai = "OpenAI"
        case anthropic = "Anthropic"
    }
    
    public var activeProvider: AIProviderType {
        get { AIProviderType(rawValue: activeProviderRaw) ?? .mock }
        set { activeProviderRaw = newValue.rawValue }
    }
    
    public func getProvider() -> AIProvider {
        let provider: AIProvider
        let effectiveKey = apiKey.isEmpty ? hardcodedAPIKey : apiKey
        let isInvalidKey = effectiveKey.isEmpty || effectiveKey == "YOUR_API_KEY_HERE"
        
        switch activeProvider {
        case .gemini:
            provider = isInvalidKey ? MockAIProvider() : GeminiProvider(apiKey: effectiveKey)
        case .openai:
            provider = isInvalidKey ? MockAIProvider() : OpenAIProvider(apiKey: effectiveKey)
        case .anthropic:
            provider = isInvalidKey ? MockAIProvider() : AnthropicProvider(apiKey: effectiveKey)
        case .mock:
            provider = MockAIProvider()
        }
        
        return FallbackAIProvider(primary: provider)
    }
    
    /// Whether the current configuration has a valid API key for the selected provider.
    public var isConfigured: Bool {
        if activeProvider == .mock { return true }
        let effectiveKey = apiKey.isEmpty ? hardcodedAPIKey : apiKey
        return !effectiveKey.isEmpty && effectiveKey != "YOUR_API_KEY_HERE"
    }
}

public class FallbackAIProvider: AIProvider {
    private let primary: AIProvider
    private let fallback = MockAIProvider()

    public init(primary: AIProvider) {
        self.primary = primary
    }

    public func generateText(prompt: String) async throws -> String {
        do {
            return try await primary.generateText(prompt: prompt)
        } catch AIProviderError.rateLimitExceeded {
            print("⚠️ API Rate limit exceeded. Falling back to Mock.")
            return try await fallback.generateText(prompt: prompt)
        } catch AIProviderError.apiError(let msg) where msg.lowercased().contains("rate limit") || msg.lowercased().contains("quota") {
            print("⚠️ API Quota exceeded. Falling back to Mock.")
            return try await fallback.generateText(prompt: prompt)
        }
    }

    public func analyzeImage(imageData: Data, prompt: String) async throws -> String {
        do {
            return try await primary.analyzeImage(imageData: imageData, prompt: prompt)
        } catch AIProviderError.rateLimitExceeded {
            print("⚠️ API Rate limit exceeded. Falling back to Mock.")
            return try await fallback.analyzeImage(imageData: imageData, prompt: prompt)
        } catch AIProviderError.apiError(let msg) where msg.lowercased().contains("rate limit") || msg.lowercased().contains("quota") {
            print("⚠️ API Quota exceeded. Falling back to Mock.")
            return try await fallback.analyzeImage(imageData: imageData, prompt: prompt)
        }
    }
}
