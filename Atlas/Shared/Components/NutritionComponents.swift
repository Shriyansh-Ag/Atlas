import SwiftUI

public struct FoodRow: View {
    public let food: FoodItem
    public let action: () -> Void
    
    public init(food: FoodItem, action: @escaping () -> Void) {
        self.food = food
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .atlasFont(AtlasTypography.body(weight: .semibold))
                        .foregroundColor(Color.Atlas.textPrimary)
                    if let brand = food.brand {
                        Text(brand)
                            .atlasFont(AtlasTypography.caption())
                            .foregroundColor(Color.Atlas.textSecondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(food.calories)) kcal")
                        .atlasFont(AtlasTypography.subheadline(weight: .bold))
                        .foregroundColor(Color.Atlas.textPrimary)
                    HStack(spacing: 8) {
                        MacroBadge(title: "P", value: food.protein, color: .red)
                        MacroBadge(title: "C", value: food.carbs, color: .blue)
                        MacroBadge(title: "F", value: food.fat, color: .orange)
                    }
                }
            }
            .padding(.vertical, Spacing.small)
        }
    }
}

public struct MacroBadge: View {
    public let title: String
    public let value: Double
    public let color: Color
    
    public init(title: String, value: Double, color: Color) {
        self.title = title
        self.value = value
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 2) {
            Text(title)
                .atlasFont(AtlasTypography.caption(weight: .bold))
                .foregroundColor(color)
            Text("\(Int(value))g")
                .atlasFont(AtlasTypography.caption())
                .foregroundColor(Color.Atlas.textSecondary)
        }
    }
}

public struct NutritionFactsCard: View {
    public let food: FoodItem
    
    public init(food: FoodItem) {
        self.food = food
    }
    
    public var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Nutrition Facts")
                    .atlasFont(AtlasTypography.title3(weight: .bold))
                    .foregroundColor(Color.Atlas.textPrimary)
                
                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                
                FactRow(title: "Calories", value: "\(Int(food.calories))", isBold: true)
                FactRow(title: "Total Fat", value: "\(food.fat)g", isBold: true)
                FactRow(title: "Total Carbohydrate", value: "\(food.carbs)g", isBold: true)
                if let fiber = food.fiber {
                    FactRow(title: "Dietary Fiber", value: "\(fiber)g", isBold: false, indent: true)
                }
                if let sugar = food.sugar {
                    FactRow(title: "Total Sugars", value: "\(sugar)g", isBold: false, indent: true)
                }
                FactRow(title: "Protein", value: "\(food.protein)g", isBold: true)
                if let sodium = food.sodium {
                    FactRow(title: "Sodium", value: "\(sodium)mg", isBold: false)
                }
            }
        }
    }
}

private struct FactRow: View {
    let title: String
    let value: String
    let isBold: Bool
    var indent: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .atlasFont(AtlasTypography.body(weight: isBold ? .semibold : .regular))
                .padding(.leading, indent ? Spacing.medium : 0)
            Spacer()
            Text(value)
                .atlasFont(AtlasTypography.body(weight: isBold ? .semibold : .regular))
        }
        .foregroundColor(Color.Atlas.textPrimary)
    }
}

public struct BarcodeButton: View {
    public let action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 24))
                .foregroundColor(Color.Atlas.textPrimary)
                .padding(Spacing.small)
                .glassBackground()
                .clipShape(Circle())
        }
    }
}
