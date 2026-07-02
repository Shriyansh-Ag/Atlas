import SwiftUI
import SwiftData

public struct FoodDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let food: FoodItem
    let mealType: MealType
    let date: Date
    
    @State private var servingQuantity: String = "1"
    
    public init(food: FoodItem, mealType: MealType, date: Date = Date()) {
        self.food = food
        self.mealType = mealType
        self.date = date
    }
    
    private var quantity: Double {
        Double(servingQuantity) ?? 1.0
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .atlasFont(AtlasTypography.title2())
                    if let brand = food.brand {
                        Text(brand)
                            .atlasFont(AtlasTypography.body())
                            .foregroundColor(Color.Atlas.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Serving adjust
                GlassCard {
                    HStack {
                        Text("Number of Servings")
                            .atlasFont(AtlasTypography.body(weight: .semibold))
                        Spacer()
                        TextField("1", text: $servingQuantity)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .padding(8)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(CornerRadius.small)
                    }
                    HStack {
                        Text("Serving Size")
                            .atlasFont(AtlasTypography.body(weight: .semibold))
                        Spacer()
                        Text("\(food.servingSize, specifier: "%.1f") \(food.servingUnit)")
                            .foregroundColor(Color.Atlas.textSecondary)
                    }
                }
                .padding(.horizontal)
                
                // Nutrition Facts
                NutritionFactsCard(food: calculateAdjustedFood())
                    .padding(.horizontal)
                
                // Log Button
                Button(action: logMeal) {
                    Text("Log Food")
                        .atlasFont(AtlasTypography.headline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.Atlas.primary)
                        .cornerRadius(CornerRadius.medium)
                }
                .padding()
            }
        }
        .background(Color.Atlas.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func calculateAdjustedFood() -> FoodItem {
        let f = food
        return FoodItem(
            name: f.name,
            brand: f.brand,
            calories: f.calories * quantity,
            protein: f.protein * quantity,
            carbs: f.carbs * quantity,
            fat: f.fat * quantity,
            fiber: f.fiber.map { $0 * quantity },
            sugar: f.sugar.map { $0 * quantity },
            sodium: f.sodium.map { $0 * quantity },
            servingSize: f.servingSize * quantity,
            servingUnit: f.servingUnit,
            provider: f.provider,
            isCustom: f.isCustom
        )
    }
    
    private func logMeal() {
        let mealRepo = MealRepository(context: modelContext)
        let foodRepo = FoodRepository(context: modelContext)
        
        do {
            // Ensure food is in local cache so relations work
            if try foodRepo.fetch(byId: food.id) == nil {
                try foodRepo.save(food)
            }
            
            // Get or create log
            let log = try mealRepo.fetchLog(for: date, type: mealType) ?? {
                let newLog = MealLog(date: date, type: mealType)
                try? mealRepo.save(newLog)
                return newLog
            }()
            
            let item = MealItem(foodItem: food, servingQuantity: quantity)
            item.log = log
            log.items.append(item)
            try mealRepo.save(log)
            
            dismiss()
        } catch {
            print("Failed to log meal: \(error)")
        }
    }
}
