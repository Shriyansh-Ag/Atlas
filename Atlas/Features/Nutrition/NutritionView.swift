import SwiftUI
import SwiftData

public struct NutritionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealLog.date, order: .reverse) private var logs: [MealLog]
    
    @State private var selectedMealType: MealType? = nil
    
    private var todayLogs: [MealLog] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return logs.filter { $0.date >= startOfDay && $0.date < endOfDay }
    }
    
    private var todayMacros: (calories: Double, protein: Double, carbs: Double, fat: Double) {
        var c = 0.0, p = 0.0, cb = 0.0, f = 0.0
        for log in todayLogs {
            let m = NutritionCalculator.totalMacros(for: log.items)
            c += m.calories
            p += m.protein
            cb += m.carbs
            f += m.fat
        }
        return (c, p, cb, f)
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.large) {
                    CustomNavigationBar(title: "Nutrition")
                    
                    // Macro Summary
                    let m = todayMacros
                    GlassCard {
                        VStack(spacing: Spacing.medium) {
                            HStack {
                                Text("Macronutrients")
                                    .atlasFont(AtlasTypography.title3())
                                    .foregroundColor(Color.Atlas.textPrimary)
                                Spacer()
                                Text("\(Int(m.calories)) / 2,400 kcal")
                                    .atlasFont(AtlasTypography.headline())
                                    .foregroundColor(Color.Atlas.textSecondary)
                            }
                            
                            HStack(spacing: Spacing.medium) {
                                MacroIndicator(title: "Protein", current: Int(m.protein), target: 160, color: .red)
                                MacroIndicator(title: "Carbs", current: Int(m.carbs), target: 250, color: .blue)
                                MacroIndicator(title: "Fats", current: Int(m.fat), target: 70, color: .orange)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.medium)
                    
                    // Meal Timeline
                    VStack(spacing: Spacing.medium) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            let log = todayLogs.first(where: { $0.type == type })
                            MealTimelineView(type: type, log: log) {
                                selectedMealType = type
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.medium)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedMealType) { type in
            NavigationStack {
                FoodSearchView(mealType: type)
            }
        }
    }
}

extension MealType: Identifiable {
    public var id: String { self.rawValue }
}

public struct MealTimelineView: View {
    let type: MealType
    let log: MealLog?
    let onAddTap: () -> Void
    
    public init(type: MealType, log: MealLog?, onAddTap: @escaping () -> Void) {
        self.type = type
        self.log = log
        self.onAddTap = onAddTap
    }
    
    public var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack {
                    Text(type.rawValue.capitalized)
                        .atlasFont(AtlasTypography.headline(weight: .bold))
                        .foregroundColor(Color.Atlas.textPrimary)
                    Spacer()
                    if let log = log, !log.items.isEmpty {
                        let m = NutritionCalculator.totalMacros(for: log.items)
                        Text("\(Int(m.calories)) kcal")
                            .atlasFont(AtlasTypography.subheadline(weight: .semibold))
                            .foregroundColor(Color.Atlas.textSecondary)
                    }
                    Button(action: onAddTap) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.Atlas.primary)
                            .font(.system(size: 24))
                    }
                }
                
                if let log = log, !log.items.isEmpty {
                    Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                    ForEach(log.items) { item in
                        HStack {
                            Text(item.foodItem?.name ?? "Unknown")
                                .atlasFont(AtlasTypography.body())
                                .foregroundColor(Color.Atlas.textPrimary)
                            Spacer()
                            Text("\(item.servingQuantity, specifier: "%.1f")x")
                                .atlasFont(AtlasTypography.subheadline())
                                .foregroundColor(Color.Atlas.textSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

private struct MacroIndicator: View {
    let title: String
    let current: Int
    let target: Int
    let color: Color
    
    var progress: Double {
        target > 0 ? Double(current) / Double(target) : 0
    }
    
    var body: some View {
        VStack(spacing: Spacing.xSmall) {
            ProgressRing(progress: progress, color: color, thickness: 6, size: 60)
            
            VStack(spacing: 2) {
                Text(title)
                    .atlasFont(AtlasTypography.caption(weight: .semibold))
                    .foregroundColor(Color.Atlas.textSecondary)
                Text("\(current)g")
                    .atlasFont(AtlasTypography.subheadline(weight: .bold))
                    .foregroundColor(Color.Atlas.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
