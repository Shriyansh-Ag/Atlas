import SwiftUI
import SwiftData

public struct ProgressDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \ProgressPhoto.date, order: .reverse) private var photos: [ProgressPhoto]
    @Query(sort: \BodyMeasurement.date, order: .reverse) private var measurements: [BodyMeasurement]
    @Query(filter: #Predicate<CachedHealthMetric> { _ in true }) private var healthMetrics: [CachedHealthMetric]
    
    @State private var showingAddWeight = false
    @State private var showingAddMeasurement = false
    @State private var showingPhotoCapture = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.Atlas.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.large) {
                        
                        // Today's Progress Snapshot
                        snapshotSection
                        
                        // Transformation Timeline
                        timelineSection
                        
                        // Measurements
                        measurementSection
                        
                        // Photos
                        photoSection
                    }
                    .padding(Spacing.medium)
                }
            }
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add Weight") { showingAddWeight = true }
                        Button("Add Measurement") { showingAddMeasurement = true }
                        Button("Add Photo") { showingPhotoCapture = true }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color.Atlas.primary)
                    }
                }
            }
        }
    }
    
    private var snapshotSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            SectionHeader(title: "Today's Snapshot")
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: Spacing.medium)], spacing: Spacing.medium) {
                let weightMetric = healthMetrics.filter { $0.type == .weight }.max(by: { $0.date < $1.date })
                MetricCard(
                    title: "Weight",
                    value: weightMetric.map { String(format: "%.1f", $0.value) } ?? "--",
                    unit: "kg",
                    icon: "scalemass.fill"
                )
                
                let bodyFatMetric = healthMetrics.filter { $0.type == .bodyFatPercentage }.max(by: { $0.date < $1.date })
                MetricCard(
                    title: "Body Fat",
                    value: bodyFatMetric.map { String(format: "%.1f", $0.value) } ?? "--",
                    unit: "%",
                    icon: "figure.arms.open"
                )
            }
        }
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            SectionHeader(title: "Recent Achievements")
            
            let milestones = MilestoneEngine.computeMilestones(context: modelContext)
            if milestones.isEmpty {
                EmptyState(
                    title: "No Milestones Yet",
                    description: "Keep training to unlock achievements.",
                    icon: "medal",
                    actionTitle: "Log Workout",
                    action: { }
                )
            } else {
                ForEach(milestones) { milestone in
                    MilestoneCard(milestone: milestone)
                }
            }
        }
    }
    
    private var measurementSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            SectionHeader(title: "Measurements", actionTitle: "View All", action: {})
            
            if let latest = measurements.first {
                BodyCompositionCard(measurement: latest)
            } else {
                EmptyState(
                    title: "No Measurements",
                    description: "Track your body composition changes.",
                    icon: "ruler",
                    actionTitle: "Add Measurement",
                    action: { showingAddMeasurement = true }
                )
            }
        }
    }
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            SectionHeader(title: "Progress Photos", actionTitle: "Compare", action: {})
            
            if photos.isEmpty {
                EmptyState(
                    title: "No Photos",
                    description: "A picture is worth a thousand data points.",
                    icon: "camera",
                    actionTitle: "Take Photo",
                    action: { showingPhotoCapture = true }
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.medium) {
                        ForEach(photos) { photo in
                            ProgressPhotoCard(photo: photo)
                        }
                    }
                }
            }
        }
    }
}
