import SwiftUI
import SwiftData
import UIKit

public struct NutritionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MealLog.date, order: .reverse) private var logs: [MealLog]
    
    @State private var selectedMealType: MealType? = nil
    
    @State private var isAnalyzingImage = false
    @State private var showingAIResults = false
    @State private var aiFoodItems: [AIFoodItem] = []
    
    @State private var showingRecipeBuilder = false
    @State private var showingMealPlan = false
    
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
                    HStack {
                        CustomNavigationBar(title: "Nutrition")
                        Spacer()
                        
                        if AIConfiguration.shared.enableMealRecognition {
                            Button(action: {
                                simulateAIPhoto()
                            }) {
                                if isAnalyzingImage {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                } else {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color.Atlas.primary)
                                }
                            }
                            .disabled(isAnalyzingImage)
                            .padding(.trailing, Spacing.medium)
                        }
                    }
                    
                    // AI Actions
                    HStack(spacing: Spacing.medium) {
                        Button(action: { showingRecipeBuilder = true }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Recipes")
                            }
                            .atlasFont(AtlasTypography.headline())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.Atlas.primary)
                            .cornerRadius(CornerRadius.medium)
                        }
                        
                        Button(action: { showingMealPlan = true }) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                Text("Meal Plan")
                            }
                            .atlasFont(AtlasTypography.headline())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.Atlas.primary)
                            .cornerRadius(CornerRadius.medium)
                        }
                    }
                    .padding(.horizontal, Spacing.medium)
                    
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
        .sheet(isPresented: $showingAIResults) {
            MealRecognitionResultView(items: aiFoodItems)
        }
        .sheet(isPresented: $showingRecipeBuilder) {
            RecipeBuilderView()
        }
        .sheet(isPresented: $showingMealPlan) {
            MealPlanView()
        }
    }
    
    private func simulateAIPhoto() {
        isAnalyzingImage = true
        Task {
            do {
                // We pass an empty UIImage for mock purposes
                let items = try await AIEngine.shared.recognizeMeal(from: UIImage())
                await MainActor.run {
                    self.aiFoodItems = items
                    self.isAnalyzingImage = false
                    self.showingAIResults = true
                }
            } catch {
                await MainActor.run {
                    self.isAnalyzingImage = false
                    print("AI Error: \(error)")
                }
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
