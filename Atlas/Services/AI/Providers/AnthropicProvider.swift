import Foundation

/// Anthropic provider using the Messages REST API.
public final class AnthropicProvider: AIProvider {
    private let apiKey: String
    private let model: String
    private let baseURL = "https://api.anthropic.com/v1/messages"
    
    public init(apiKey: String, model: String = "claude-3-5-sonnet-20241022") {
        self.apiKey = apiKey
        self.model = model
    }
    
    // MARK: - AIProvider
    
    public func generateText(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else { throw AIProviderError.invalidConfiguration }
        
        let body: [String: Any] = [
            "model": model,
            "max_tokens": 4096,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]
        
        return try await performRequest(body: body)
    }
    
    public func analyzeImage(imageData: Data, prompt: String) async throws -> String {
        guard !apiKey.isEmpty else { throw AIProviderError.invalidConfiguration }
        
        let base64Image = imageData.base64EncodedString()
        
        let body: [String: Any] = [
            "model": model,
            "max_tokens": 4096,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": prompt
                        ]
                    ] as [[String: Any]]
                ]
            ]
        ]
        
        return try await performRequest(body: body)
    }
    
    // MARK: - Private
    
    private func performRequest(body: [String: Any]) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw AIProviderError.invalidConfiguration
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 60
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIProviderError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try parseAnthropicResponse(data)
        case 401:
            throw AIProviderError.apiError("Invalid API key.")
        case 429:
            throw AIProviderError.rateLimitExceeded
        case 500...599:
            throw AIProviderError.apiError("Anthropic server error. Please try again later.")
        default:
            let message = parseErrorMessage(data) ?? "HTTP \(httpResponse.statusCode)"
            throw AIProviderError.apiError(message)
        }
    }
    
    private func parseAnthropicResponse(_ data: Data) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let text = firstBlock["text"] as? String else {
            throw AIProviderError.invalidResponse
        }
        return text
    }
    
    private func parseErrorMessage(_ data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let error = json["error"] as? [String: Any],
              let message = error["message"] as? String else {
            return nil
        }
        return message
    }
}
