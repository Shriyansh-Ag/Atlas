import SwiftUI
import WidgetKit

// MARK: - Shared Widget Views

/// Mini progress ring for widget use — simplified from the main app's ProgressRing.
struct WidgetProgressRing: View {
    let progress: Double
    let color: Color
    let size: CGFloat
    let lineWidth: CGFloat
    
    init(progress: Double, color: Color, size: CGFloat = 50, lineWidth: CGFloat = 6) {
        self.progress = progress
        self.color = color
        self.size = size
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}

/// A compact metric row for medium/large widgets.
struct WidgetMetricRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
                .frame(width: 14)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }
}

/// Macro bar for nutrition widgets.
struct WidgetMacroBar: View {
    let label: String
    let current: Double
    let target: Double
    let color: Color
    
    private var progress: Double {
        target > 0 ? min(current / target, 1.0) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(current))/\(Int(target))g")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.primary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(color.opacity(0.2))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 4)
        }
    }
}

/// Streak dots row.
struct WidgetStreakDots: View {
    let streak: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.caption)
                .foregroundStyle(.orange)
            Text("\(streak)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
            Text("day streak")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
