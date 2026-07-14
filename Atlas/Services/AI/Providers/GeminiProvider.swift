import Foundation

/// Gemini AI provider using the Google Generative Language REST API.
public final class GeminiProvider: AIProvider {
    private let apiKey: String
    private let textModel: String
    private let visionModel: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"
    
    public init(apiKey: String, textModel: String = "gemini-1.5-flash", visionModel: String = "gemini-1.5-flash") {
        // 👱‍♀️ ponytail: hardcoded to 1.5-flash for stability until 2.0 graduates
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.textModel = textModel
        self.visionModel = visionModel
    }
    
    // MARK: - AIProvider
    
    public func generateText(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else { throw AIProviderError.invalidConfiguration }
        
        guard let url = URL(string: "\(baseURL)/\(textModel):generateContent?key=\(apiKey)") else {
            throw AIProviderError.invalidConfiguration
        }
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.4,
                "topP": 0.95,
                "maxOutputTokens": 4096
            ]
        ]
        
        return try await performRequest(url: url, body: body)
    }
    
    public func analyzeImage(imageData: Data, prompt: String) async throws -> String {
        guard !apiKey.isEmpty else { throw AIProviderError.invalidConfiguration }
        
        guard let url = URL(string: "\(baseURL)/\(visionModel):generateContent?key=\(apiKey)") else {
            throw AIProviderError.invalidConfiguration
        }
        let base64Image = imageData.base64EncodedString()
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.3,
                "topP": 0.95,
                "maxOutputTokens": 4096
            ]
        ]
        
        return try await performRequest(url: url, body: body)
    }
    
    // MARK: - Private
    
    private func performRequest(url: URL, body: [String: Any]) async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 60
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIProviderError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try parseGeminiResponse(data)
        case 400:
            let message = parseErrorMessage(data) ?? "Bad request"
            throw AIProviderError.apiError(message)
        case 403:
            throw AIProviderError.apiError("Invalid API key or insufficient permissions.")
        case 429:
            throw AIProviderError.rateLimitExceeded
        default:
            let message = parseErrorMessage(data) ?? "HTTP \(httpResponse.statusCode)"
            throw AIProviderError.apiError(message)
        }
    }
    
    private func parseGeminiResponse(_ data: Data) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else {
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
