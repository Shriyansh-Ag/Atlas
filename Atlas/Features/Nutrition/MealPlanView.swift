import SwiftUI
import SwiftData

public struct MealPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var daysToPlan = 3
    @State private var isLoading = false
    @State private var mealPlan: [MealPlanDay] = []
    @State private var errorMessage: String? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.Atlas.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.large) {
                        
                        if mealPlan.isEmpty {
                            // Setup State
                            GlassCard {
                                VStack(alignment: .leading, spacing: Spacing.medium) {
                                    Text("AI Meal Planner")
                                        .atlasFont(AtlasTypography.title2())
                                        .foregroundColor(Color.Atlas.textPrimary)
                                    
                                    Text("Atlas will generate a personalized meal plan based on your macro targets, dietary preferences, and allergies.")
                                        .atlasFont(AtlasTypography.body())
                                        .foregroundColor(Color.Atlas.textSecondary)
                                    
                                    Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                                    
                                    VStack(alignment: .leading, spacing: Spacing.small) {
                                        Text("How many days?")
                                            .atlasFont(AtlasTypography.headline())
                                            .foregroundColor(Color.Atlas.textPrimary)
                                        
                                        Picker("Days", selection: $daysToPlan) {
                                            Text("1 Day").tag(1)
                                            Text("3 Days").tag(3)
                                            Text("7 Days").tag(7)
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                    
                                    Button(action: generatePlan) {
                                        Text("Generate Plan")
                                            .atlasFont(AtlasTypography.headline())
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.Atlas.primary)
                                            .cornerRadius(CornerRadius.medium)
                                    }
                                    .padding(.top, Spacing.small)
                                }
                            }
                        } else {
                            // Results State
                            ForEach(mealPlan) { day in
                                MealPlanDayCard(day: day)
                            }
                        }
                        
                        if let error = errorMessage {
                            Text(error)
                                .atlasFont(AtlasTypography.subheadline())
                                .foregroundColor(Color.Atlas.error)
                                .padding()
                                .background(Color.Atlas.error.opacity(0.1))
                                .cornerRadius(CornerRadius.small)
                        }
                    }
                    .padding(Spacing.medium)
                }
                
                if isLoading {
                    LoadingOverlay(message: "Atlas is planning your meals...")
                }
            }
            .navigationTitle("Meal Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(mealPlan.isEmpty ? "Close" : "Reset") {
                        if mealPlan.isEmpty {
                            dismiss()
                        } else {
                            mealPlan = []
                        }
                    }
                }
            }
        }
    }
    
    private func generatePlan() {
        isLoading = true
        errorMessage = nil
        
        Task {
            let result = await AIService.shared.generateMealPlan(days: daysToPlan, context: modelContext)
            
            await MainActor.run {
                isLoading = false
                switch result {
                case .success(let plan):
                    self.mealPlan = plan
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

private struct MealPlanDayCard: View {
    let day: MealPlanDay
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text(day.dayLabel)
                    .atlasFont(AtlasTypography.title2())
                    .foregroundColor(Color.Atlas.primary)
                
                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                
                MealPlanEntryRow(title: "Breakfast", entry: day.breakfast)
                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                MealPlanEntryRow(title: "Lunch", entry: day.lunch)
                Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                MealPlanEntryRow(title: "Dinner", entry: day.dinner)
                
                if let snack = day.snack {
                    Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                    MealPlanEntryRow(title: "Snack", entry: snack)
                }
            }
        }
    }
}

private struct MealPlanEntryRow: View {
    let title: String
    let entry: MealPlanDay.MealPlanEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .atlasFont(AtlasTypography.caption(weight: .bold))
                    .foregroundColor(Color.Atlas.textSecondary)
                    .textCase(.uppercase)
                Spacer()
                Text("\(Int(entry.estimatedCalories)) kcal")
                    .atlasFont(AtlasTypography.caption(weight: .semibold))
                    .foregroundColor(Color.Atlas.primary)
            }
            
            Text(entry.name)
                .atlasFont(AtlasTypography.headline())
                .foregroundColor(Color.Atlas.textPrimary)
            
            Text(entry.description)
                .atlasFont(AtlasTypography.subheadline())
                .foregroundColor(Color.Atlas.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: Spacing.small) {
                Text("P: \(Int(entry.estimatedProtein))g")
                    .foregroundColor(.blue)
                Text("C: \(Int(entry.estimatedCarbs))g")
                    .foregroundColor(.green)
                Text("F: \(Int(entry.estimatedFat))g")
                    .foregroundColor(.purple)
            }
            .font(.caption2.bold())
            .padding(.top, 4)
        }
    }
}
