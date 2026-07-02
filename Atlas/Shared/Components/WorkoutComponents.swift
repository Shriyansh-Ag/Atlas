import SwiftUI
import SwiftData

public struct SetRow: View {
    @Binding var set: LoggedSet
    var onCheck: () -> Void
    
    public init(set: Binding<LoggedSet>, onCheck: @escaping () -> Void) {
        self._set = set
        self.onCheck = onCheck
    }
    
    public var body: some View {
        HStack(spacing: Spacing.medium) {
            Text("\(set.order + 1)")
                .atlasFont(AtlasTypography.callout())
                .foregroundColor(Color.Atlas.textSecondary)
                .frame(width: 30)
            
            TextField("lbs", value: $set.weight, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .padding(.vertical, Spacing.small)
                .background(Color.Atlas.surface)
                .cornerRadius(CornerRadius.small)
            
            TextField("reps", value: $set.reps, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .padding(.vertical, Spacing.small)
                .background(Color.Atlas.surface)
                .cornerRadius(CornerRadius.small)
            
            Button(action: {
                set.isCompleted.toggle()
                if set.isCompleted {
                    onCheck()
                }
            }) {
                Image(systemName: set.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.system(size: 24))
                    .foregroundColor(set.isCompleted ? Color.Atlas.success : Color.Atlas.textSecondary)
            }
        }
    }
}

public struct ExerciseCard: View {
    let exercise: LoggedExercise
    @Binding var sets: [LoggedSet]
    
    public var body: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading) {
                    Text(exercise.exercise?.name ?? "Unknown Exercise")
                        .atlasFont(AtlasTypography.headline())
                        .foregroundColor(Color.Atlas.textPrimary)
                    Text(exercise.exercise?.primaryMuscle ?? "")
                        .atlasFont(AtlasTypography.subheadline())
                        .foregroundColor(Color.Atlas.textSecondary)
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color.Atlas.textSecondary)
                }
            }
            
            VStack(spacing: Spacing.small) {
                HStack(spacing: Spacing.medium) {
                    Text("Set").frame(width: 30)
                    Text("lbs").frame(maxWidth: .infinity)
                    Text("Reps").frame(maxWidth: .infinity)
                    Image(systemName: "checkmark").frame(width: 30)
                }
                .atlasFont(AtlasTypography.caption())
                .foregroundColor(Color.Atlas.textSecondary)
                
                ForEach($sets) { $set in
                    SetRow(set: $set) {
                        RestTimerManager.shared.start(duration: 90)
                    }
                }
                
                Button(action: {
                    // Handled by parent view / SessionManager
                }) {
                    Text("+ Add Set")
                        .atlasFont(AtlasTypography.callout(weight: .semibold))
                        .foregroundColor(Color.Atlas.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.small)
                        .background(Color.Atlas.primary.opacity(0.1))
                        .cornerRadius(CornerRadius.small)
                }
            }
        }
    }
}

public struct RestTimerView: View {
    @ObservedObject var manager = RestTimerManager.shared
    
    public init() {}
    
    public var body: some View {
        if manager.isRunning {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(Color.Atlas.primary)
                Text(timeString(from: manager.remainingSeconds))
                    .atlasFont(AtlasTypography.headline(weight: .bold))
                    .foregroundColor(Color.Atlas.textPrimary)
                    .monospacedDigit()
                
                Spacer()
                
                Button(action: { manager.addTime(30) }) {
                    Text("+30s")
                        .atlasFont(AtlasTypography.caption(weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.Atlas.surface)
                        .cornerRadius(12)
                }
                
                Button(action: { manager.stop() }) {
                    Text("Skip")
                        .atlasFont(AtlasTypography.caption(weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.Atlas.surface)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(CornerRadius.medium)
            .padding(.horizontal)
            .shadow(radius: 10)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%d:%02d", min, sec)
    }
}

public struct PRBadge: View {
    let title: String
    
    public init(title: String) {
        self.title = title
    }
    
    public var body: some View {
        HStack {
            Image(systemName: "trophy.fill")
                .foregroundColor(.yellow)
            Text(title)
                .atlasFont(AtlasTypography.caption(weight: .bold))
                .foregroundColor(Color.Atlas.textPrimary)
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.small)
        .background(Color.yellow.opacity(0.2))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
        )
        .cornerRadius(CornerRadius.large)
    }
}
