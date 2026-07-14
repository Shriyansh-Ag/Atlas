import Foundation

/// OpenAI provider using the Chat Completions REST API.
public final class OpenAIProvider: AIProvider {
    private let apiKey: String
    private let textModel: String
    private let visionModel: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    public init(apiKey: String, textModel: String = "gpt-4o-mini", visionModel: String = "gpt-4o") {
        self.apiKey = apiKey
        self.textModel = textModel
        self.visionModel = visionModel
    }
    
    // MARK: - AIProvider
    
    public func generateText(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else { throw AIProviderError.invalidConfiguration }
        
        let body: [String: Any] = [
            "model": textModel,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.4,
            "max_tokens": 4096
        ]
        
        return try await performRequest(body: body)
    }
    
    public func analyzeImage(imageData: Data, prompt: String) async throws -> String {
        guard !apiKey.isEmpty else { throw AIProviderError.invalidConfiguration }
        
        let base64Image = imageData.base64EncodedString()
        
        let body: [String: Any] = [
            "model": visionModel,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": prompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)",
                                "detail": "low"
                            ]
                        ]
                    ] as [[String: Any]]
                ]
            ],
            "temperature": 0.3,
            "max_tokens": 4096
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
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 60
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIProviderError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try parseOpenAIResponse(data)
        case 401:
            throw AIProviderError.apiError("Invalid API key.")
        case 429:
            throw AIProviderError.rateLimitExceeded
        case 500...599:
            throw AIProviderError.apiError("OpenAI server error. Please try again later.")
        default:
            let message = parseErrorMessage(data) ?? "HTTP \(httpResponse.statusCode)"
            throw AIProviderError.apiError(message)
        }
    }
    
    private func parseOpenAIResponse(_ data: Data) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIProviderError.invalidResponse
        }
        return content
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
