import SwiftUI
import SwiftData

public struct ProfileSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appEnvironment) private var environment
    @Query private var profiles: [UserProfile]
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            if let profile = profiles.first {
                ProfileEditorView(profile: profile)
            } else {
                VStack {
                    Text("No Profile Found")
                        .foregroundColor(Color.Atlas.textSecondary)
                    PrimaryButton(title: "Start Onboarding") {
                        environment.router.push(.onboarding)
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

fileprivate struct ProfileEditorView: View {
    @Bindable var profile: UserProfile
    @Environment(\.appEnvironment) private var environment
    @State private var showingSaveConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "Edit Profile") {
                Button(action: { environment.router.pop() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.Atlas.secondary)
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Basic Info
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Basic Info").font(AtlasTypography.title3()).foregroundColor(Color.Atlas.primary)
                            
                            EditableRow(title: "Name", value: $profile.name)
                            EditableNumberRow(title: "Age", value: Binding(
                                get: { Double(profile.age) },
                                set: { profile.age = Int($0); recalculate() }
                            ))
                            
                            HStack {
                                Text("Sex").foregroundColor(Color.Atlas.textSecondary)
                                Spacer()
                                Picker("", selection: Binding(
                                    get: { profile.biologicalSex },
                                    set: { profile.biologicalSex = $0; recalculate() }
                                )) {
                                    ForEach(BiologicalSex.allCases) { sex in
                                        Text(sex.rawValue).tag(sex)
                                    }
                                }
                                .tint(Color.Atlas.textPrimary)
                            }
                        }
                    }
                    
                    // Metrics
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Metrics").font(AtlasTypography.title3()).foregroundColor(Color.Atlas.primary)
                            
                            EditableNumberRow(title: "Height (cm)", value: Binding(
                                get: { profile.heightCm },
                                set: { profile.heightCm = $0; recalculate() }
                            ))
                            EditableNumberRow(title: "Weight (kg)", value: Binding(
                                get: { profile.weightKg },
                                set: { profile.weightKg = $0; recalculate() }
                            ))
                            EditableOptionalNumberRow(title: "Goal Wt (kg)", value: Binding(
                                get: { profile.goalWeightKg },
                                set: { profile.goalWeightKg = $0; recalculate() }
                            ))
                        }
                    }
                    
                    // Goals & Activity
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Goals & Activity").font(AtlasTypography.title3()).foregroundColor(Color.Atlas.primary)
                            
                            HStack {
                                Text("Goal").foregroundColor(Color.Atlas.textSecondary)
                                Spacer()
                                Picker("", selection: Binding(
                                    get: { profile.fitnessGoal },
                                    set: { profile.fitnessGoal = $0; recalculate() }
                                )) {
                                    ForEach(FitnessGoal.allCases) { goal in
                                        Text(goal.rawValue).tag(goal)
                                    }
                                }
                                .tint(Color.Atlas.textPrimary)
                            }
                            
                            HStack {
                                Text("Activity").foregroundColor(Color.Atlas.textSecondary)
                                Spacer()
                                Picker("", selection: Binding(
                                    get: { profile.activityLevel },
                                    set: { profile.activityLevel = $0; recalculate() }
                                )) {
                                    ForEach(ActivityLevel.allCases) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                .tint(Color.Atlas.textPrimary)
                            }
                        }
                    }
                    
                    // Display Calculated Data
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Calculated Targets").font(AtlasTypography.title3()).foregroundColor(Color.Atlas.success)
                            Text("BMR: \(Int(profile.bmr)) kcal")
                            Text("TDEE: \(Int(profile.tdee)) kcal")
                            Text("Daily Goal: \(Int(profile.dailyCalories)) kcal")
                            HStack {
                                Text("P: \(Int(profile.targetProteinGram))g")
                                Text("C: \(Int(profile.targetCarbsGram))g")
                                Text("F: \(Int(profile.targetFatGram))g")
                            }
                            .foregroundColor(Color.Atlas.textSecondary)
                        }
                        .foregroundColor(Color.Atlas.textPrimary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func recalculate() {
        let bmr = ProfileCalculationService.calculateBMR(weightKg: profile.weightKg, heightCm: profile.heightCm, age: profile.age, sex: profile.biologicalSex)
        let tdee = ProfileCalculationService.calculateTDEE(bmr: bmr, activityLevel: profile.activityLevel)
        let calories = ProfileCalculationService.calculateDailyCalories(tdee: tdee, goal: profile.fitnessGoal)
        let macros = ProfileCalculationService.calculateMacros(calories: calories, weightKg: profile.weightKg, goal: profile.fitnessGoal)
        
        profile.bmr = bmr
        profile.tdee = tdee
        profile.dailyCalories = calories
        profile.targetProteinGram = macros.protein
        profile.targetCarbsGram = macros.carbs
        profile.targetFatGram = macros.fat
        profile.lastUpdatedAt = Date()
    }
}

fileprivate struct EditableRow: View {
    let title: String
    @Binding var value: String
    
    var body: some View {
        HStack {
            Text(title).foregroundColor(Color.Atlas.textSecondary)
            Spacer()
            TextField("", text: $value)
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color.Atlas.textPrimary)
        }
    }
}

fileprivate struct EditableNumberRow: View {
    let title: String
    @Binding var value: Double
    
    var body: some View {
        HStack {
            Text(title).foregroundColor(Color.Atlas.textSecondary)
            Spacer()
            TextField("", value: $value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color.Atlas.textPrimary)
        }
    }
}

fileprivate struct EditableOptionalNumberRow: View {
    let title: String
    @Binding var value: Double?
    
    var body: some View {
        HStack {
            Text(title).foregroundColor(Color.Atlas.textSecondary)
            Spacer()
            TextField("None", value: $value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color.Atlas.textPrimary)
        }
    }
}
