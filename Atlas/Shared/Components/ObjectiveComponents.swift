import SwiftUI

public struct ObjectiveCard: View {
    let objective: AtlasObjective
    let currentValue: Double
    let status: ObjectiveStatus
    let onTap: () -> Void
    
    public init(objective: AtlasObjective, currentValue: Double, status: ObjectiveStatus, onTap: @escaping () -> Void) {
        self.objective = objective
        self.currentValue = currentValue
        self.status = status
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            GlassCard {
                HStack(spacing: Spacing.medium) {
                    // Progress Ring
                    ObjectiveProgressRing(
                        progress: progressRatio,
                        color: colorForStatus(status),
                        icon: iconForObjective(objective.type)
                    )
                    .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(objective.title)
                            .atlasFont(AtlasTypography.headline(weight: .semibold))
                            .foregroundColor(Color.Atlas.textPrimary)
                            .lineLimit(1)
                        
                        Text("\(formatValue(currentValue)) / \(formatValue(objective.targetValue))")
                            .atlasFont(AtlasTypography.subheadline())
                            .foregroundColor(Color.Atlas.textSecondary)
                        
                        if objective.isChallenge {
                            Text("CHALLENGE")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.purple.opacity(0.8))
                                .cornerRadius(4)
                        } else {
                            Text(statusText(status))
                                .font(.caption2.bold())
                                .foregroundColor(colorForStatus(status))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.Atlas.textSecondary.opacity(0.5))
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private var progressRatio: Double {
        if objective.targetValue == 0 { return 0 }
        
        if objective.type == .weightLoss || objective.type == .targetBodyFat {
            // Simplification: In a real app we'd need a starting baseline to compute a true 0-100% progress.
            // For UI purposes, we'll just show it mostly full if they are close.
            let diff = abs(currentValue - objective.targetValue)
            if diff < 1.0 { return 0.95 }
            return 0.5
        } else {
            return min(currentValue / objective.targetValue, 1.0)
        }
    }
    
    private func formatValue(_ val: Double) -> String {
        if val == floor(val) {
            return "\(Int(val))"
        }
        return String(format: "%.1f", val)
    }
    
    private func colorForStatus(_ status: ObjectiveStatus) -> Color {
        switch status {
        case .completed: return .green
        case .onTrack: return .blue
        case .behind: return .orange
        case .notStarted: return .gray
        }
    }
    
    private func statusText(_ status: ObjectiveStatus) -> String {
        switch status {
        case .completed: return "COMPLETED"
        case .onTrack: return "ON TRACK"
        case .behind: return "NEEDS ATTENTION"
        case .notStarted: return "NOT STARTED"
        }
    }
    
    private func iconForObjective(_ type: ObjectiveType) -> String {
        switch type {
        case .weightLoss, .weightGain, .maintainWeight: return "scalemass.fill"
        case .targetBodyFat: return "figure.stand"
        case .proteinGoal: return "fork.knife"
        case .waterGoal: return "drop.fill"
        case .stepGoal: return "figure.walk"
        case .sleepGoal: return "bed.double.fill"
        case .workoutConsistency: return "dumbbell.fill"
        case .custom: return "star.fill"
        }
    }
}

public struct ObjectiveProgressRing: View {
    var progress: Double
    var color: Color
    var icon: String
    
    public init(progress: Double, color: Color, icon: String) {
        self.progress = progress
        self.color = color
        self.icon = icon
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 5)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0), value: progress)
            
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
        }
    }
}
