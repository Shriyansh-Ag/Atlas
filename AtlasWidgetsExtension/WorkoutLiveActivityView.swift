import SwiftUI
import WidgetKit
import ActivityKit

/// Live Activity and Dynamic Island views for workout sessions.
struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            // Lock Screen / Banner view
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.workoutName)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                        Text(context.state.currentExercise)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        if context.state.isResting {
                            Text(context.state.formattedRest)
                                .font(.title3.weight(.bold).monospacedDigit())
                                .foregroundStyle(.orange)
                            Text("Rest")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        } else {
                            Text(context.state.formattedDuration)
                                .font(.title3.weight(.bold).monospacedDigit())
                            Text("Elapsed")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    // Progress bar
                    VStack(spacing: 4) {
                        ProgressView(value: context.state.progress)
                            .tint(.blue)
                        HStack {
                            Text(context.state.currentSetInfo)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(context.state.estimatedCalories) kcal")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    EmptyView()
                }
            } compactLeading: {
                // Compact leading
                if context.state.isResting {
                    Image(systemName: "timer")
                        .foregroundStyle(.orange)
                } else {
                    Image(systemName: "dumbbell.fill")
                        .foregroundStyle(.blue)
                }
            } compactTrailing: {
                // Compact trailing
                if context.state.isResting {
                    Text(context.state.formattedRest)
                        .font(.caption.weight(.bold).monospacedDigit())
                        .foregroundStyle(.orange)
                } else {
                    Text(context.state.formattedDuration)
                        .font(.caption.weight(.bold).monospacedDigit())
                }
            } minimal: {
                // Minimal — just the timer
                if context.state.isResting {
                    Image(systemName: "timer")
                        .foregroundStyle(.orange)
                } else {
                    Image(systemName: "dumbbell.fill")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
    
    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<WorkoutActivityAttributes>) -> some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.workoutName)
                        .font(.headline.weight(.bold))
                    Text(context.state.currentExercise)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    if context.state.isResting {
                        Text(context.state.formattedRest)
                            .font(.title2.weight(.bold).monospacedDigit())
                            .foregroundStyle(.orange)
                        Text("Rest Timer")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    } else {
                        Text(context.state.formattedDuration)
                            .font(.title2.weight(.bold).monospacedDigit())
                        Text("Duration")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            ProgressView(value: context.state.progress)
                .tint(.blue)
            
            HStack {
                Label(context.state.currentSetInfo, systemImage: "number.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Label("\(context.state.estimatedCalories) kcal", systemImage: "flame")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
