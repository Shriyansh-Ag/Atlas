import SwiftUI
import SwiftData

public struct MealRecognitionResultView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var items: [AIFoodItem]
    @State private var originalItems: [AIFoodItem]
    @State private var isSaving = false
    
    public init(items: [AIFoodItem]) {
        _items = State(initialValue: items)
        _originalItems = State(initialValue: items)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.Atlas.background.ignoresSafeArea()
                
                VStack(spacing: Spacing.medium) {
                    ScrollView {
                        VStack(spacing: Spacing.small) {
                            ForEach($items) { $item in
                                AIFoodItemRow(item: $item)
                            }
                        }
                        .padding(.horizontal, Spacing.medium)
                        .padding(.top, Spacing.small)
                    }
                    
                    VStack(spacing: Spacing.small) {
                        HStack {
                            Text("Total Estimated")
                                .atlasFont(AtlasTypography.headline())
                            Spacer()
                            Text("\(Int(items.reduce(0) { $0 + $1.calories })) kcal")
                                .atlasFont(AtlasTypography.title3())
                        }
                        .foregroundColor(Color.Atlas.textPrimary)
                        .padding(.horizontal, Spacing.medium)
                        
                        Button(action: saveToLog) {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Log Meal")
                                    .atlasFont(AtlasTypography.headline())
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.Atlas.primary)
                        .disabled(isSaving)
                        .padding(.horizontal, Spacing.medium)
                        .padding(.bottom, Spacing.medium)
                    }
                }
            }
            .navigationTitle("AI Estimation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func saveToLog() {
        isSaving = true
        
        Task {
            // Give UI time to show loading
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            await MainActor.run {
                for (index, item) in items.enumerated() {
                    let original = originalItems[index]
                    
                    // Track correction if modified
                    if item.name != original.name || 
                       item.calories != original.calories || 
                       item.protein != original.protein || 
                       item.carbs != original.carbs || 
                       item.fat != original.fat {
                        AIEngine.shared.correctMealItem(original: original, corrected: item, context: modelContext)
                    }
                    
                    // Create FoodItem
                    let food = FoodItem(
                        name: item.name,
                        brand: "AI Estimated",
                        calories: item.calories,
                        protein: item.protein,
                        carbs: item.carbs,
                        fat: item.fat,
                        servingSize: 1,
                        servingUnit: "serving"
                    )
                    modelContext.insert(food)
                    
                    // Create MealLog and MealItem
                    let log = MealLog(date: Date(), type: .lunch)
                    let mealItem = MealItem(foodItem: food, servingQuantity: 1)
                    log.items.append(mealItem)
                    modelContext.insert(log)
                }
                
                try? modelContext.save()
                
                // Force an update to the daily nutrition manager
                DailyNutritionManager.shared.update(with: modelContext)
                
                let impact = UINotificationFeedbackGenerator()
                impact.notificationOccurred(.success)
                
                dismiss()
            }
        }
    }
}

struct AIFoodItemRow: View {
    @Binding var item: AIFoodItem
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack {
                    TextField("Food Name", text: $item.name)
                        .atlasFont(AtlasTypography.headline())
                        .foregroundColor(Color.Atlas.textPrimary)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Image(systemName: "sparkles")
                        Text("\(Int(item.confidence * 100))%")
                    }
                    .font(.caption)
                    .foregroundColor(item.confidence > 0.8 ? .green : .orange)
                }
                
                HStack(spacing: Spacing.medium) {
                    MacroEditor(title: "Cal", value: $item.calories, color: .orange)
                    MacroEditor(title: "Pro", value: $item.protein, color: .blue)
                    MacroEditor(title: "Carb", value: $item.carbs, color: .green)
                    MacroEditor(title: "Fat", value: $item.fat, color: .purple)
                }
            }
        }
    }
}

struct MacroEditor: View {
    let title: String
    @Binding var value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(Color.Atlas.textSecondary)
            
            TextField("", value: $value, formatter: NumberFormatter())
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .font(.subheadline.bold())
                .foregroundColor(color)
                .padding(4)
                .background(Color.black.opacity(0.1))
                .cornerRadius(4)
        }
    }
}
