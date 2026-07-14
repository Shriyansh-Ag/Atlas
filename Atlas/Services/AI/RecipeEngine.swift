import Foundation

/// Generates AI-powered recipe suggestions based on user-provided ingredients and goals.
public class RecipeEngine {
    public static let shared = RecipeEngine()
    
    private init() {}
    
    public func generateRecipes(
        ingredients: [String],
        goal: String,
        targetCalories: Int,
        targetProtein: Int
    ) async throws -> [RecipeSuggestion] {
        let provider = AIConfiguration.shared.getProvider()
        let ingredientString = ingredients.joined(separator: ", ")
        
        let prompt = PromptBuilder.buildRecipePrompt(
            ingredients: ingredientString,
            goal: goal,
            targetCalories: targetCalories,
            targetProtein: targetProtein
        )
        
        let jsonString = try await provider.generateJSON(prompt: prompt)
        
        guard let data = jsonString.data(using: .utf8) else {
            throw AIProviderError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([RecipeSuggestion].self, from: data)
        } catch {
            throw AIProviderError.apiError("Failed to parse recipe suggestions: \(error.localizedDescription)")
        }
    }
}
