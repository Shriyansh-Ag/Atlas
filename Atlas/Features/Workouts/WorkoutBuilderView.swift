import SwiftUI
import SwiftData

public struct WorkoutBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var planName: String = ""
    @State private var showingExerciseSearch = false
    
    // Use draft structs to avoid SwiftData un-inserted relationship bugs
    @State private var draftExercises: [DraftExercise] = []
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.Atlas.background.ignoresSafeArea()
                
                VStack {
                    TextField("Plan Name", text: $planName)
                        .atlasFont(AtlasTypography.title2())
                        .padding()
                        .background(Color.Atlas.surface)
                        .cornerRadius(CornerRadius.medium)
                        .padding()
                    
                    List {
                        ForEach($draftExercises) { $draftEx in
                            DraftExerciseRow(draftEx: $draftEx)
                            .listRowBackground(Color.Atlas.surface)
                        }
                        .onMove(perform: move)
                        .onDelete(perform: delete)
                        
                        Button(action: { showingExerciseSearch = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Exercise")
                            }
                            .foregroundColor(Color.Atlas.primary)
                        }
                        .listRowBackground(Color.Atlas.surface)
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("New Workout Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePlan()
                    }
                    .disabled(planName.isEmpty || draftExercises.isEmpty)
                }
            }
            .sheet(isPresented: $showingExerciseSearch) {
                ExerciseSearchView { ex in
                    addExercise(ex)
                    showingExerciseSearch = false
                }
            }
        }
    }
    
    private func addExercise(_ ex: ExerciseDefinition) {
        let draftSets = (0..<3).map { DraftSet(order: $0, targetReps: 10) }
        let draftEx = DraftExercise(exercise: ex, order: draftExercises.count, sets: draftSets)
        draftExercises.append(draftEx)
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        draftExercises.move(fromOffsets: source, toOffset: destination)
        for (index, _) in draftExercises.enumerated() {
            draftExercises[index].order = index
        }
    }
    
    private func delete(at offsets: IndexSet) {
        draftExercises.remove(atOffsets: offsets)
        for (index, _) in draftExercises.enumerated() {
            draftExercises[index].order = index
        }
    }
    
    private func savePlan() {
        let plan = WorkoutPlan(name: planName)
        let day = WorkoutPlanDay(name: "Day 1", order: 0)
        day.plan = plan
        plan.days.append(day)
        
        for draftEx in draftExercises {
            let plannedEx = PlannedExercise(exercise: draftEx.exercise, order: draftEx.order)
            plannedEx.day = day
            day.exercises.append(plannedEx)
            
            for draftSet in draftEx.sets {
                let plannedSet = PlannedSet(order: draftSet.order, targetReps: draftSet.targetReps)
                plannedSet.plannedExercise = plannedEx
                plannedEx.sets.append(plannedSet)
            }
        }
        
        modelContext.insert(plan)
        try? modelContext.save()
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Draft Models & Views

struct DraftSet: Identifiable {
    let id = UUID()
    var order: Int
    var targetReps: Int
}

struct DraftExercise: Identifiable {
    let id = UUID()
    var exercise: ExerciseDefinition
    var order: Int
    var sets: [DraftSet]
}

struct DraftExerciseRow: View {
    @Binding var draftEx: DraftExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(draftEx.exercise.name)
                .atlasFont(AtlasTypography.headline())
                .foregroundColor(Color.Atlas.textPrimary)
            
            ForEach($draftEx.sets) { $set in
                HStack {
                    Text("Set \(set.order + 1)")
                        .atlasFont(AtlasTypography.caption())
                        .foregroundColor(Color.Atlas.textSecondary)
                    Spacer()
                    TextField("Reps", value: $set.targetReps, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 50)
                        .padding(4)
                        .background(Color.Atlas.background)
                        .cornerRadius(4)
                    Text("reps")
                        .atlasFont(AtlasTypography.caption())
                        .foregroundColor(Color.Atlas.textSecondary)
                }
            }
            .onDelete { offsets in
                draftEx.sets.remove(atOffsets: offsets)
                for (index, _) in draftEx.sets.enumerated() {
                    draftEx.sets[index].order = index
                }
            }
            
            Button(action: {
                let newSet = DraftSet(order: draftEx.sets.count, targetReps: 10)
                draftEx.sets.append(newSet)
            }) {
                Text("+ Add Set")
                    .atlasFont(AtlasTypography.caption(weight: .semibold))
                    .foregroundColor(Color.Atlas.primary)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
}
