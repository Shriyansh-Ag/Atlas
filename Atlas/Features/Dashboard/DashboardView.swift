import SwiftUI
import SwiftData
import HealthKit

public struct DashboardView: View {
    @Environment(\.appEnvironment) private var environment
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var viewModel: DashboardViewModel
    
    @State private var showingActiveWorkout = false
    @State private var showingWorkoutPlans = false
    
    // Filter for today's metrics
    @Query(filter: #Predicate<CachedHealthMetric> { metric in
        // A naive filter for simplicity, typically you'd filter by date bounds.
        // SwiftData predicates have limitations with Date functions, so often we fetch and filter in memory if needed,
        // or rely on our unique ID scheme which includes the date string.
        true
    }) private var metrics: [CachedHealthMetric]
    
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
        .sheet(isPresented: $showingActiveWorkout) {
            ActiveWorkoutView()
        }
        .sheet(isPresented: $showingWorkoutPlans) {
            WorkoutPlansView()
        }
    }
    
    private var dashboardContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.large) {
                topNavigation
                
                // SECTION 1 & 8: Summary and Motivation
                MotivationCard(message: viewModel.motivationalMessage)
                    .padding(.horizontal, Spacing.medium)
                
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
            SectionHeader(title: "Today's Workout")
            
            if let workout = viewModel.todaysWorkout {
                GlassCard {
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xSmall) {
                            Text(workout.name)
                                .atlasFont(AtlasTypography.title3())
                                .foregroundColor(Color.Atlas.textPrimary)
                            
                            HStack {
                                Image(systemName: "clock")
                                Text("\(workout.durationMinutes) min")
                                Text("•")
                                Text("\(workout.exerciseCount) exercises")
                            }
                            .atlasFont(AtlasTypography.subheadline())
                            .foregroundColor(Color.Atlas.textSecondary)
                            
                            Text(workout.muscleGroups.joined(separator: ", "))
                                .atlasFont(AtlasTypography.caption())
                                .foregroundColor(Color.Atlas.primary)
                                .padding(.top, 2)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                        }) {
                            Image(systemName: workout.isCompleted ? "checkmark.circle.fill" : "play.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(workout.isCompleted ? Color.Atlas.success : Color.Atlas.primary)
                        }
                        .disabled(workout.isCompleted)
                    }
                }
                .padding(.horizontal, Spacing.medium)
            } else {
                EmptyState(
                    title: "Rest Day",
                    description: "No workout planned for today. Enjoy your recovery!",
                    icon: "dumbbell.fill",
                    actionTitle: "My Plans",
                    action: { showingWorkoutPlans = true }
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
                    QuickActionButton(title: "Workout", icon: "dumbbell.fill", color: .purple) { showingActiveWorkout = true }
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
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.medium) {
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
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: Spacing.xSmall) {
                        Text("\(viewModel.streakData.currentStreak) Day Streak")
                            .atlasFont(AtlasTypography.title3())
                            .foregroundColor(Color.Atlas.primary)
                        Text("Longest: \(viewModel.streakData.longestStreak) days")
                            .atlasFont(AtlasTypography.subheadline())
                            .foregroundColor(Color.Atlas.textSecondary)
                    }
                    
                    Spacer()
                    
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

#Preview {
    return DashboardView()
        .environment(\.appEnvironment, .preview)
        .modelContainer(for: CachedHealthMetric.self, inMemory: true)
}
