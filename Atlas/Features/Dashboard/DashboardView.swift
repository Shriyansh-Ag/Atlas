import SwiftUI
import SwiftData
import HealthKit

public struct DashboardView: View {
    @Environment(\.appEnvironment) private var environment
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var viewModel: DashboardViewModel
    
    // Filter for today's metrics
    @Query(filter: #Predicate<CachedHealthMetric> { metric in
        true
    }) private var metrics: [CachedHealthMetric]
    
    @Query(sort: \AtlasObjective.targetDate) private var objectives: [AtlasObjective]
    
    @MainActor
    public init() {
        _viewModel = StateObject(wrappedValue: DashboardViewModel())
    }
    
    public init(viewModel: DashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            if viewModel.isLoading {
                dashboardContent
                    .redacted(reason: .placeholder)
            } else {
                dashboardContent
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.update(with: metrics, context: modelContext)
        }
        .onChange(of: metrics) { _, newMetrics in
            viewModel.update(with: newMetrics, context: modelContext)
        }
        .task {
            if HealthPermissionManager().authorizationStatus == .notDetermined {
                environment.router.presentedSheet = .healthKitAuthorization
            } else {
                await HealthSyncManager.shared.sync(context: modelContext)
            }
        }
    }
    
    private var dashboardContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.large) {
                topNavigation
                
                // SECTION 1 & 8: Summary and Motivation
                if !viewModel.dailyInsights.isEmpty {
                    VStack(spacing: Spacing.small) {
                        SectionHeader(title: "Today's Coaching")
                        ForEach(viewModel.dailyInsights) { insight in
                            InsightCard(insight: insight)
                        }
                    }
                    .padding(.horizontal, Spacing.medium)
                    
                    if !viewModel.workoutRecommendations.isEmpty || !viewModel.nutritionRecommendations.isEmpty {
                        VStack(spacing: Spacing.small) {
                            HStack {
                                SectionHeader(title: "Coach Says")
                                Spacer()
                                AIStatusView(status: .success)
                            }
                            
                            ForEach(viewModel.workoutRecommendations.prefix(1)) { rec in
                                CoachRecommendationCard(
                                    icon: "dumbbell.fill",
                                    iconColor: .purple,
                                    title: "Workout Coach",
                                    message: rec.message,
                                    detail: rec.reasoning,
                                    confidence: rec.confidence
                                )
                            }
                            
                            ForEach(viewModel.nutritionRecommendations.prefix(1)) { rec in
                                CoachRecommendationCard(
                                    icon: "fork.knife",
                                    iconColor: .orange,
                                    title: "Nutrition Coach",
                                    message: rec.message,
                                    detail: rec.details
                                )
                            }
                        }
                        .padding(.horizontal, Spacing.medium)
                    }
                } else {
                    MotivationCard(message: viewModel.motivationalMessage)
                        .padding(.horizontal, Spacing.medium)
                }
                
                // SECTION 1.5: Today's Focus (Goals)
                if let topObjective = objectives.first(where: { !$0.isCompleted }) {
                    VStack(spacing: Spacing.small) {
                        SectionHeader(title: "Today's Focus")
                        
                        let prog = ObjectiveCalculator.calculateProgress(for: topObjective, context: modelContext)
                        ObjectiveCard(objective: topObjective, currentValue: prog.currentValue, status: prog.status) {
                            environment.router.push(.goals)
                        }
                    }
                    .padding(.horizontal, Spacing.medium)
                }
                
                // SECTION 2 & 3: Calories & Macros
                caloriesAndMacrosSection
                
                // SECTION 4: Today's Workout
                workoutSection
                
                // SECTION 6: Quick Actions
                quickActionsSection
                
                // SECTION 5: Health Snapshot
                healthSnapshotSection
                
                // SECTION 7: Weekly Streak
                streakSection
                
                Spacer(minLength: 40)
            }
        }
        .refreshable {
            await HealthSyncManager.shared.sync(context: modelContext)
        }
    }
    
    // MARK: - Sections
    
    private var topNavigation: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                    .atlasFont(AtlasTypography.caption(weight: .semibold))
                    .foregroundColor(Color.Atlas.primary)
                    .tracking(1.5)
                    .textCase(.uppercase)
                
                Text("Ready to go?")
                    .atlasFont(AtlasTypography.title2())
                    .foregroundColor(Color.Atlas.textPrimary)
            }
            
            Spacer()
            
            Button(action: { environment.router.push(.settings) }) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color.Atlas.secondary)
            }
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.top, Spacing.small)
    }
    
    private var caloriesAndMacrosSection: some View {
        VStack(spacing: Spacing.small) {
            SectionHeader(title: "Nutrition")
            
            HStack(spacing: Spacing.medium) {
                // Circular Calorie Progress
                ZStack {
                    ProgressRing(progress: viewModel.calorieProgress, color: Color.Atlas.primary, thickness: 14, size: 130)
                    
                    VStack(spacing: 2) {
                        Text("\(Int(viewModel.caloriesRemaining))")
                            .atlasFont(AtlasTypography.title2())
                            .foregroundColor(Color.Atlas.textPrimary)
                        Text("kcal left")
                            .atlasFont(AtlasTypography.caption())
                            .foregroundColor(Color.Atlas.textSecondary)
                    }
                }
                .padding(.trailing, Spacing.small)
                
                // Macros Vertical Stack
                VStack(spacing: Spacing.medium) {
                    MacroProgressCard(
                        title: "Protein",
                        current: viewModel.macroData.proteinConsumed,
                        target: viewModel.macroData.proteinTarget,
                        unit: "g",
                        color: .blue
                    )
                    MacroProgressCard(
                        title: "Carbs",
                        current: viewModel.macroData.carbsConsumed,
                        target: viewModel.macroData.carbsTarget,
                        unit: "g",
                        color: .orange
                    )
                    MacroProgressCard(
                        title: "Fat",
                        current: viewModel.macroData.fatConsumed,
                        target: viewModel.macroData.fatTarget,
                        unit: "g",
                        color: .purple
                    )
                }
            }
            .padding(.horizontal, Spacing.medium)
        }
    }
    
    private var workoutSection: some View {
        VStack(spacing: Spacing.small) {
            SectionHeader(title: "Today's Workouts")
            
            if !viewModel.importedWorkouts.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.medium) {
                        ForEach(viewModel.importedWorkouts, id: \.uuid) { workout in
                            ImportedWorkoutCard(workout: workout)
                        }
                    }
                    .padding(.horizontal, Spacing.medium)
                }
            } else {
                EmptyState(
                    title: "Rest Day",
                    description: "No workouts logged today in Apple Health. Enjoy your recovery!",
                    icon: "dumbbell.fill",
                    actionTitle: "Refresh Data",
                    action: { 
                        Task { await HealthSyncManager.shared.sync(context: modelContext) }
                    }
                )
                .padding(.horizontal, Spacing.medium)
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: Spacing.small) {
            SectionHeader(title: "Quick Actions")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.medium) {
                    QuickActionButton(title: "Log Meal", icon: "fork.knife", color: .orange) { }
                    QuickActionButton(title: "Scan", icon: "barcode.viewfinder", color: .blue) { }
                    QuickActionButton(title: "Water", icon: "drop.fill", color: .cyan) { }
                    QuickActionButton(title: "Weight", icon: "scalemass.fill", color: .green) { }
                }
                .padding(.horizontal, Spacing.medium)
            }
        }
    }
    
    private var healthSnapshotSection: some View {
        VStack(spacing: Spacing.small) {
            SectionHeader(title: "Health Snapshot")
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: Spacing.medium)], spacing: Spacing.medium) {
                MetricCard(title: "Sleep", value: "\(viewModel.healthSnapshot.sleepScore)", unit: "score", icon: "bed.double.fill", color: .indigo)
                MetricCard(title: "Steps", value: "\(viewModel.healthSnapshot.steps)", unit: "steps", icon: "figure.walk", color: .blue)
                MetricCard(title: "Resting HR", value: "\(viewModel.healthSnapshot.restingHeartRate)", unit: "bpm", icon: "heart.fill", color: .red)
                MetricCard(title: "Water", value: String(format: "%.1f", viewModel.healthSnapshot.waterIntakeLiters), unit: "L / \(String(format: "%.1f", viewModel.healthSnapshot.waterTargetLiters))L", icon: "drop.fill", color: .cyan)
                MetricCard(title: "Weight", value: String(format: "%.1f", viewModel.healthSnapshot.bodyWeightKg), unit: "kg", icon: "scalemass.fill", color: .green)
                MetricCard(title: "VO2 Max", value: String(format: "%.1f", viewModel.healthSnapshot.vo2Max), unit: "ml/kg/min", icon: "lungs.fill", color: .orange)
            }
            .padding(.horizontal, Spacing.medium)
        }
    }
    
    private var streakSection: some View {
        VStack(spacing: Spacing.small) {
            SectionHeader(title: "Weekly Activity")
            
            GlassCard {
                ViewThatFits {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: Spacing.xSmall) {
                            Text("\(viewModel.streakData.currentStreak) Day Streak")
                                .atlasFont(AtlasTypography.title3())
                                .foregroundColor(Color.Atlas.primary)
                                .minimumScaleFactor(0.8)
                            Text("Longest: \(viewModel.streakData.longestStreak) days")
                                .atlasFont(AtlasTypography.subheadline())
                                .foregroundColor(Color.Atlas.textSecondary)
                                .minimumScaleFactor(0.8)
                        }
                        
                        Spacer(minLength: Spacing.medium)
                        
                        HStack(spacing: 8) {
                            ForEach(1...7, id: \.self) { day in
                                VStack(spacing: 4) {
                                    Text(dayName(for: day))
                                        .atlasFont(AtlasTypography.caption())
                                        .foregroundColor(Color.Atlas.textSecondary)
                                    Circle()
                                        .fill(viewModel.streakData.completedDaysThisWeek.contains(day) ? Color.Atlas.primary : Color.Atlas.surface)
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        VStack(alignment: .leading, spacing: Spacing.xSmall) {
                            Text("\(viewModel.streakData.currentStreak) Day Streak")
                                .atlasFont(AtlasTypography.title3())
                                .foregroundColor(Color.Atlas.primary)
                            Text("Longest: \(viewModel.streakData.longestStreak) days")
                                .atlasFont(AtlasTypography.subheadline())
                                .foregroundColor(Color.Atlas.textSecondary)
                        }
                        
                        HStack(spacing: 12) {
                            ForEach(1...7, id: \.self) { day in
                                VStack(spacing: 4) {
                                    Text(dayName(for: day))
                                        .atlasFont(AtlasTypography.caption())
                                        .foregroundColor(Color.Atlas.textSecondary)
                                    Circle()
                                        .fill(viewModel.streakData.completedDaysThisWeek.contains(day) ? Color.Atlas.primary : Color.Atlas.surface)
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .padding(.horizontal, Spacing.medium)
        }
    }
    
    private func dayName(for index: Int) -> String {
        let names = ["S", "M", "T", "W", "T", "F", "S"]
        guard index >= 1 && index <= 7 else { return "" }
        return names[index - 1]
    }
}

// MARK: - Imported Workout Card
struct ImportedWorkoutCard: View {
    let workout: HKWorkout
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        // Extract custom name if available in metadata, else use generic type name
                        Text(workoutName)
                            .atlasFont(AtlasTypography.headline())
                            .foregroundColor(Color.Atlas.textPrimary)
                            .lineLimit(1)
                        
                        Text(timeString)
                            .atlasFont(AtlasTypography.caption())
                            .foregroundColor(Color.Atlas.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "applewatch")
                        .foregroundColor(Color.Atlas.primary)
                }
                
                HStack(spacing: Spacing.medium) {
                    VStack(alignment: .leading) {
                        Text("Duration")
                            .atlasFont(AtlasTypography.caption())
                            .foregroundColor(Color.Atlas.textSecondary)
                        Text("\(Int(workout.duration / 60)) min")
                            .atlasFont(AtlasTypography.title3())
                            .foregroundColor(Color.Atlas.textPrimary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Calories")
                            .atlasFont(AtlasTypography.caption())
                            .foregroundColor(Color.Atlas.textSecondary)
                        Text("\(Int(workout.statistics(for: HKQuantityType(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0)) kcal")
                            .atlasFont(AtlasTypography.title3())
                            .foregroundColor(Color.Atlas.textPrimary)
                    }
                }
                .padding(.top, Spacing.xSmall)
            }
        }
        .frame(width: 260)
    }
    
    private var workoutName: String {
        // Map activity type to string
        switch workout.workoutActivityType {
        case .traditionalStrengthTraining: return "Strength Training"
        case .running: return "Running"
        case .cycling: return "Cycling"
        case .swimming: return "Swimming"
        case .walking: return "Walking"
        case .yoga: return "Yoga"
        case .highIntensityIntervalTraining: return "HIIT"
        default: return "Workout"
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: workout.startDate)) - \(formatter.string(from: workout.endDate))"
    }
}

#Preview {
    return DashboardView()
        .environment(\.appEnvironment, .preview)
        .modelContainer(for: CachedHealthMetric.self, inMemory: true)
}
