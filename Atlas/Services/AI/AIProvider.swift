import Foundation

public protocol AIProvider {
    func generateText(prompt: String) async throws -> String
    func analyzeImage(imageData: Data, prompt: String) async throws -> String
}

// MARK: - Default Implementation

public extension AIProvider {
    /// Convenience: calls `generateText` and strips markdown JSON fences from LLM responses.
    func generateJSON(prompt: String) async throws -> String {
        let raw = try await generateText(prompt: prompt)
        return raw.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Convenience: calls `analyzeImage` and strips markdown JSON fences from LLM responses.
    func analyzeImageJSON(imageData: Data, prompt: String) async throws -> String {
        let raw = try await analyzeImage(imageData: imageData, prompt: prompt)
        return raw.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Errors

public enum AIProviderError: LocalizedError {
    case invalidConfiguration
    case networkError(Error)
    case apiError(String)
    case rateLimitExceeded
    case invalidResponse
    case featureDisabled
    
    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "AI provider is not configured. Please add your API key in Settings → Atlas Intelligence."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError(let message):
            return "AI service error: \(message)"
        case .rateLimitExceeded:
            return "Rate limit reached. Please wait a moment and try again."
        case .invalidResponse:
            return "Received an unexpected response from the AI service."
        case .featureDisabled:
            return "This AI feature is currently disabled. Enable it in Settings → Atlas Intelligence."
        }
    }
}
