import SwiftUI
import SwiftData

public struct RecoveryView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<CachedHealthMetric> { _ in true })
    private var allMetrics: [CachedHealthMetric]
    
    @State private var recoveryRecommendations: [RecoveryRecommendation] = []
    @State private var aiStatus: AIStatusView.Status = .idle
    @State private var isLoadingRecs = false
    
    public init() {}
    
    // MARK: - Computed Metrics
    
    private var todayMetrics: [HealthMetricType: Double] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        var dict = [HealthMetricType: Double]()
        for m in allMetrics where m.id.hasSuffix(todayString) {
            dict[m.type] = m.value
        }
        return dict
    }
    
    private var recoveryScore: Int { Int(todayMetrics[.recoveryScore] ?? 0) }
    private var sleepScore: Int { Int(todayMetrics[.sleepScore] ?? 0) }
    private var hrv: Int { Int(todayMetrics[.hrv] ?? 0) }
    private var restingHR: Int { Int(todayMetrics[.restingHeartRate] ?? 0) }
    private var steps: Int { Int(todayMetrics[.steps] ?? 0) }
    
    private var recoveryColor: Color {
        if recoveryScore >= 75 { return .green }
        if recoveryScore >= 50 { return .orange }
        return .red
    }
    
    private var recoveryMessage: String {
        if recoveryScore >= 80 { return "Your body is well rested. Great day to push your limits." }
        if recoveryScore >= 60 { return "Moderate recovery. A standard workout is fine today." }
        if recoveryScore >= 40 { return "Recovery is below average. Consider a lighter session." }
        return "Low recovery detected. Rest or light mobility recommended."
    }
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.large) {
                    CustomNavigationBar(title: "Recovery")
                    
                    // Recovery Score Hero Card
                    recoveryScoreCard
                    
                    // Health Metrics Detail
                    healthMetricsSection
                    
                    // AI Recovery Coaching
                    recoveryCoachingSection
                    
                    Spacer(minLength: 40)
                }
            }
            .refreshable {
                await HealthSyncManager.shared.sync(context: modelContext)
                await fetchRecommendations()
            }
        }
        .navigationBarHidden(true)
        .task {
            await fetchRecommendations()
        }
    }
    
    // MARK: - Recovery Score Card
    
    private var recoveryScoreCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack {
                    Text("RECOVERY SCORE")
                        .atlasFont(AtlasTypography.caption(weight: .bold))
                        .foregroundColor(Color.Atlas.textSecondary)
                        .tracking(1.2)
                    Spacer()
                    Image(systemName: "heart.text.square.fill")
                        .foregroundColor(recoveryColor)
                        .font(.system(size: 22))
                }
                
                HStack(alignment: .center, spacing: Spacing.medium) {
                    // Circular Score
                    ZStack {
                        ProgressRing(
                            progress: Double(recoveryScore) / 100.0,
                            color: recoveryColor,
                            thickness: 10,
                            size: 100
                        )
                        
                        VStack(spacing: 0) {
                            Text("\(recoveryScore)")
                                .atlasFont(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(Color.Atlas.textPrimary)
                            Text("/ 100")
                                .atlasFont(AtlasTypography.caption())
                                .foregroundColor(Color.Atlas.textTertiary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.xSmall) {
                        Text(recoveryStatusLabel)
                            .atlasFont(AtlasTypography.title3())
                            .foregroundColor(recoveryColor)
                        
                        Text(recoveryMessage)
                            .atlasFont(AtlasTypography.subheadline())
                            .foregroundColor(Color.Atlas.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.medium)
    }
    
    private var recoveryStatusLabel: String {
        if recoveryScore >= 80 { return "Excellent" }
        if recoveryScore >= 60 { return "Good" }
        if recoveryScore >= 40 { return "Fair" }
        return "Low"
    }
    
    // MARK: - Health Metrics Section
    
    private var healthMetricsSection: some View {
        VStack(spacing: Spacing.small) {
            SectionHeader(title: "Recovery Metrics")
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.medium) {
                MetricCard(
                    title: "Sleep",
                    value: "\(sleepScore)",
                    unit: "score",
                    icon: "moon.stars.fill",
                    color: .indigo
                )
                MetricCard(
                    title: "HRV",
                    value: "\(hrv)",
                    unit: "ms",
                    icon: "waveform.path.ecg",
                    color: .cyan
                )
                MetricCard(
                    title: "Resting HR",
                    value: "\(restingHR)",
                    unit: "bpm",
                    icon: "heart.fill",
                    color: .red
                )
                MetricCard(
                    title: "Steps",
                    value: "\(steps)",
                    unit: "steps",
                    icon: "figure.walk",
                    color: .blue
                )
            }
            .padding(.horizontal, Spacing.medium)
        }
    }
    
    // MARK: - AI Recovery Coaching
    
    private var recoveryCoachingSection: some View {
        VStack(spacing: Spacing.small) {
            HStack {
                SectionHeader(title: "Coach Says")
                Spacer()
                AIStatusView(status: aiStatus)
            }
            .padding(.horizontal, Spacing.medium)
            
            if isLoadingRecs {
                GlassCard {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.Atlas.primary))
                        Text("Analyzing your recovery data...")
                            .atlasFont(AtlasTypography.subheadline())
                            .foregroundColor(Color.Atlas.textSecondary)
                        Spacer()
                    }
                }
                .padding(.horizontal, Spacing.medium)
            } else if recoveryRecommendations.isEmpty {
                GlassCard {
                    HStack(spacing: Spacing.small) {
                        Image(systemName: "sparkles")
                            .foregroundColor(Color.Atlas.primary)
                        Text("Pull to refresh for AI recovery insights")
                            .atlasFont(AtlasTypography.subheadline())
                            .foregroundColor(Color.Atlas.textSecondary)
                        Spacer()
                    }
                }
                .padding(.horizontal, Spacing.medium)
            } else {
                ForEach(recoveryRecommendations) { rec in
                    CoachRecommendationCard(
                        icon: iconForRecType(rec.recommendationType),
                        iconColor: colorForRecType(rec.recommendationType),
                        title: titleForRecType(rec.recommendationType),
                        message: rec.message,
                        detail: rec.reasoning
                    )
                    .padding(.horizontal, Spacing.medium)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func fetchRecommendations() async {
        isLoadingRecs = true
        aiStatus = .loading
        
        let result = await AIService.shared.fetchRecoveryRecommendations(context: modelContext)
        
        await MainActor.run {
            switch result {
            case .success(let recs):
                self.recoveryRecommendations = recs
                self.aiStatus = recs.isEmpty ? .idle : .success
            case .failure(let error):
                self.aiStatus = .error(error.localizedDescription)
            }
            self.isLoadingRecs = false
        }
    }
    
    private func iconForRecType(_ type: RecoveryRecommendation.RecommendationType) -> String {
        switch type {
        case .rest: return "bed.double.fill"
        case .lightWorkout: return "figure.walk"
        case .heavyWorkout: return "dumbbell.fill"
        case .mobility: return "figure.flexibility"
        case .sleep: return "moon.zzz.fill"
        }
    }
    
    private func colorForRecType(_ type: RecoveryRecommendation.RecommendationType) -> Color {
        switch type {
        case .rest: return .indigo
        case .lightWorkout: return .cyan
        case .heavyWorkout: return .purple
        case .mobility: return .green
        case .sleep: return .blue
        }
    }
    
    private func titleForRecType(_ type: RecoveryRecommendation.RecommendationType) -> String {
        switch type {
        case .rest: return "Rest Day"
        case .lightWorkout: return "Light Workout"
        case .heavyWorkout: return "Go Hard"
        case .mobility: return "Mobility Work"
        case .sleep: return "Sleep Focus"
        }
    }
}

#Preview {
    RecoveryView()
        .modelContainer(for: CachedHealthMetric.self, inMemory: true)
}
