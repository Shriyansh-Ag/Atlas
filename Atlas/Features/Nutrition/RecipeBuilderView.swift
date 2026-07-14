import SwiftUI
import SwiftData

public struct RecipeBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var ingredientsText: String = ""
    @State private var goal: String = "High protein, low carb meal"
    @State private var targetCalories: Double = 500
    @State private var targetProtein: Double = 40
    
    @State private var isLoading = false
    @State private var recipes: [RecipeSuggestion] = []
    @State private var errorMessage: String? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.Atlas.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.large) {
                        
                        // Input Section
                        GlassCard {
                            VStack(alignment: .leading, spacing: Spacing.medium) {
                                Text("What's in your fridge?")
                                    .atlasFont(AtlasTypography.headline())
                                    .foregroundColor(Color.Atlas.textPrimary)
                                
                                TextField("e.g. Chicken, rice, broccoli, soy sauce", text: $ingredientsText, axis: .vertical)
                                    .lineLimit(3...5)
                                    .padding()
                                    .background(Color.black.opacity(0.2))
                                    .cornerRadius(CornerRadius.small)
                                    .foregroundColor(Color.Atlas.textPrimary)
                                
                                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                                
                                Text("Meal Goal")
                                    .atlasFont(AtlasTypography.headline())
                                    .foregroundColor(Color.Atlas.textPrimary)
                                
                                TextField("e.g. High protein, quick to make", text: $goal)
                                    .padding()
                                    .background(Color.black.opacity(0.2))
                                    .cornerRadius(CornerRadius.small)
                                    .foregroundColor(Color.Atlas.textPrimary)
                                
                                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                                
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Target Calories: \(Int(targetCalories)) kcal")
                                        Spacer()
                                    }
                                    Slider(value: $targetCalories, in: 200...1500, step: 50)
                                        .tint(Color.Atlas.primary)
                                    
                                    HStack {
                                        Text("Target Protein: \(Int(targetProtein))g")
                                        Spacer()
                                    }
                                    Slider(value: $targetProtein, in: 10...100, step: 5)
                                        .tint(Color.orange)
                                }
                                .atlasFont(AtlasTypography.subheadline())
                                .foregroundColor(Color.Atlas.textSecondary)
                                
                                Button(action: generateRecipes) {
                                    Text("Generate Recipes")
                                        .atlasFont(AtlasTypography.headline())
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(ingredientsText.isEmpty ? Color.gray : Color.Atlas.primary)
                                        .cornerRadius(CornerRadius.medium)
                                }
                                .disabled(ingredientsText.isEmpty || isLoading)
                                .padding(.top, Spacing.small)
                            }
                        }
                        
                        // Error
                        if let error = errorMessage {
                            Text(error)
                                .atlasFont(AtlasTypography.subheadline())
                                .foregroundColor(Color.Atlas.error)
                                .padding()
                                .background(Color.Atlas.error.opacity(0.1))
                                .cornerRadius(CornerRadius.small)
                        }
                        
                        // Results
                        if !recipes.isEmpty {
                            VStack(spacing: Spacing.medium) {
                                Text("Suggested Recipes")
                                    .atlasFont(AtlasTypography.title2())
                                    .foregroundColor(Color.Atlas.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                ForEach(recipes) { recipe in
                                    RecipeSuggestionCard(recipe: recipe, onSave: { saveRecipe(recipe) })
                                }
                            }
                        }
                    }
                    .padding(Spacing.medium)
                }
                
                if isLoading {
                    LoadingOverlay(message: "Chef Atlas is thinking...")
                }
            }
            .navigationTitle("Recipe Builder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    private func generateRecipes() {
        guard !ingredientsText.isEmpty else { return }
        let ingredientsList = ingredientsText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            let result = await AIService.shared.generateRecipes(
                ingredients: ingredientsList,
                goal: goal,
                targetCalories: Int(targetCalories),
                targetProtein: Int(targetProtein)
            )
            
            await MainActor.run {
                isLoading = false
                switch result {
                case .success(let generated):
                    self.recipes = generated
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func saveRecipe(_ suggestion: RecipeSuggestion) {
        // Save to SwiftData
        let newRecipe = Recipe(
            name: suggestion.name,
            instructions: suggestion.instructions.joined(separator: "\n\n"),
            servingCount: suggestion.servings
        )
        
        // Since we don't have FoodItems for the ingredients, we would create dummy food items
        // or just rely on the text instructions for now in the actual app implementation.
        // For simplicity in this demo, we save the text.
        modelContext.insert(newRecipe)
        try? modelContext.save()
        
        // Let user know
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
        dismiss()
    }
}

private struct RecipeSuggestionCard: View {
    let recipe: RecipeSuggestion
    let onSave: () -> Void
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text(recipe.name)
                    .atlasFont(AtlasTypography.title3())
                    .foregroundColor(Color.Atlas.textPrimary)
                
                HStack(spacing: Spacing.medium) {
                    MacroPill(value: "\(Int(recipe.estimatedCalories))", label: "kcal", color: .orange)
                    MacroPill(value: "\(Int(recipe.estimatedProtein))g", label: "Pro", color: .blue)
                    MacroPill(value: "\(Int(recipe.estimatedCarbs))g", label: "Carb", color: .green)
                    MacroPill(value: "\(Int(recipe.estimatedFat))g", label: "Fat", color: .purple)
                }
                
                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                
                Text("Ingredients")
                    .atlasFont(AtlasTypography.headline())
                    .foregroundColor(Color.Atlas.textPrimary)
                
                ForEach(recipe.ingredients, id: \.name) { ing in
                    HStack {
                        Text(ing.name)
                            .foregroundColor(Color.Atlas.textSecondary)
                        Spacer()
                        Text(ing.quantity)
                            .foregroundColor(Color.Atlas.textPrimary)
                    }
                    .font(.subheadline)
                }
                
                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                
                Button(action: onSave) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save Recipe")
                    }
                    .atlasFont(AtlasTypography.headline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.Atlas.primary)
                    .cornerRadius(CornerRadius.medium)
                }
            }
        }
    }
}

private struct MacroPill: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .atlasFont(AtlasTypography.subheadline(weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(Color.Atlas.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(CornerRadius.small)
    }
}
