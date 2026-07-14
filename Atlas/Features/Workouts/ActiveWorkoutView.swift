import SwiftUI
import SwiftData

public struct ActiveWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var sessionManager = WorkoutSessionManager.shared
    
    @State private var showingExerciseSearch = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            if let session = sessionManager.activeSession {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(session.name)
                                .atlasFont(AtlasTypography.title2())
                                .foregroundColor(Color.Atlas.textPrimary)
                            Text(timeString(from: Int(sessionManager.elapsedTime)))
                                .atlasFont(AtlasTypography.callout())
                                .foregroundColor(Color.Atlas.primary)
                                .monospacedDigit()
                        }
                        Spacer()
                        Button(action: { sessionManager.finishWorkout(context: modelContext) }) {
                            Text("Finish")
                                .atlasFont(AtlasTypography.callout(weight: .bold))
                                .padding(.horizontal, Spacing.medium)
                                .padding(.vertical, 8)
                                .background(Color.Atlas.primary)
                                .foregroundColor(.white)
                                .cornerRadius(CornerRadius.medium)
                        }
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: Spacing.large) {
                            ForEach(session.exercises) { loggedEx in
                                ExerciseCardWrapper(exercise: loggedEx)
                            }
                            
                            Button(action: { showingExerciseSearch = true }) {
                                Text("Add Exercise")
                                    .atlasFont(AtlasTypography.headline())
                                    .foregroundColor(Color.Atlas.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.Atlas.surface)
                                    .cornerRadius(CornerRadius.medium)
                            }
                        }
                        .padding()
                    }
                }
            } else {
                VStack {
                    Text("No Active Workout")
                        .atlasFont(AtlasTypography.title2())
                        .foregroundColor(Color.Atlas.textSecondary)
                    
                    Button(action: { sessionManager.startWorkout(context: modelContext) }) {
                        Text("Start Freestyle Workout")
                            .atlasFont(AtlasTypography.headline())
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.Atlas.primary)
                            .cornerRadius(CornerRadius.medium)
                    }
                    .padding(.top, Spacing.large)
                }
            }
            
            VStack {
                Spacer()
                RestTimerView()
            }
        }
        .sheet(isPresented: $showingExerciseSearch) {
            ExerciseSearchView(onSelect: { ex in
                sessionManager.addExercise(ex, context: modelContext)
                showingExerciseSearch = false
            })
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }
}

public struct ExerciseCardWrapper: View {
    @Bindable var exercise: LoggedExercise
    @Environment(\.modelContext) private var modelContext
    
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
                
                ForEach($exercise.sets) { $set in
                    SetRow(set: $set) {
                        RestTimerManager.shared.start(duration: 90)
                    }
                }
                
                Button(action: {
                    WorkoutSessionManager.shared.addSet(to: exercise, context: modelContext)
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
