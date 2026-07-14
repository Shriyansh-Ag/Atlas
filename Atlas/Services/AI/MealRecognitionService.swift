import Foundation
import UIKit

public class MealRecognitionService {
    public static let shared = MealRecognitionService()
    
    private init() {}
    
    public func recognizeMeal(from image: UIImage) async throws -> [AIFoodItem] {
        guard let compressedData = image.jpegData(compressionQuality: 0.5) else {
            throw AIProviderError.invalidConfiguration
        }
        
        let provider = AIConfiguration.shared.getProvider()
        let prompt = PromptBuilder.buildMealRecognitionPrompt()
        
        let jsonString = try await provider.analyzeImage(imageData: compressedData, prompt: prompt)
        
        // Clean up markdown JSON formatting if the LLM returned it
        let cleanedString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            
        guard let data = cleanedString.data(using: .utf8) else {
            throw AIProviderError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        do {
            let items = try decoder.decode([AIFoodItem].self, from: data)
            return items
        } catch {
            throw AIProviderError.apiError("Failed to parse JSON: \(error.localizedDescription)")
        }
    }
}
