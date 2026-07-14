import SwiftUI

/// Displays a weekly report summary with key metrics and AI-generated analysis.
public struct WeeklyReportCard: View {
    public let report: WeeklyReportData
    @State private var isExpanded = false
    
    public init(report: WeeklyReportData) {
        self.report = report
    }
    
    public var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("WEEKLY REPORT")
                            .atlasFont(AtlasTypography.caption(weight: .bold))
                            .foregroundColor(Color.Atlas.primary)
                            .tracking(1.2)
                        Text("Last 7 Days")
                            .atlasFont(AtlasTypography.caption())
                            .foregroundColor(Color.Atlas.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chart.bar.doc.horizontal.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color.Atlas.primary)
                }
                
                // Metric Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.small) {
                    ReportMetricPill(label: "Workouts", value: "\(Int(report.workoutConsistency))%", color: .purple)
                    ReportMetricPill(label: "Nutrition", value: "\(Int(report.nutritionConsistency))%", color: .orange)
                    ReportMetricPill(label: "Avg Sleep", value: "\(Int(report.averageSleepScore))", color: .indigo)
                    ReportMetricPill(label: "Weight", value: report.weightTrend, color: .green)
                }
                
                // Best Workout
                HStack(spacing: Spacing.xSmall) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 14))
                    Text("Best: \(report.bestWorkout)")
                        .atlasFont(AtlasTypography.caption(weight: .semibold))
                        .foregroundColor(Color.Atlas.textPrimary)
                        .lineLimit(1)
                }
                
                // Expandable Details
                if isExpanded {
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Divider().background(Color.Atlas.textSecondary.opacity(0.3))
                        
                        Text(report.summaryText)
                            .atlasFont(AtlasTypography.subheadline())
                            .foregroundColor(Color.Atlas.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if !report.highlights.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(report.highlights, id: \.self) { highlight in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                            .foregroundColor(Color.Atlas.primary)
                                        Text(highlight)
                                            .atlasFont(AtlasTypography.caption())
                                            .foregroundColor(Color.Atlas.textSecondary)
                                    }
                                }
                            }
                        }
                        
                        // Focus for next week
                        VStack(alignment: .leading, spacing: 4) {
                            Text("FOCUS NEXT WEEK")
                                .atlasFont(AtlasTypography.caption(weight: .bold))
                                .foregroundColor(Color.Atlas.primary)
                                .tracking(1.0)
                            Text(report.suggestedFocus)
                                .atlasFont(AtlasTypography.subheadline())
                                .foregroundColor(Color.Atlas.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(Spacing.small)
                        .background(Color.Atlas.primary.opacity(0.08))
                        .cornerRadius(CornerRadius.small)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Expand/Collapse Button
                Button(action: {
                    withAnimation(AtlasAnimations.springSmooth) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Spacer()
                        Text(isExpanded ? "Show Less" : "View Full Report")
                            .atlasFont(AtlasTypography.caption(weight: .semibold))
                            .foregroundColor(Color.Atlas.primary)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.Atlas.primary)
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

private struct ReportMetricPill: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.xSmall) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(Color.Atlas.textTertiary)
                Text(value)
                    .atlasFont(AtlasTypography.subheadline(weight: .semibold))
                    .foregroundColor(Color.Atlas.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
