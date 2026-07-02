import SwiftUI
import SwiftData

public struct WorkoutBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var planName: String = ""
    @State private var showingExerciseSearch = false
    
    // For simplicity, building a single day plan
    @State private var day = WorkoutPlanDay(name: "Day 1", order: 0)
    
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
                        ForEach(day.exercises) { plannedEx in
                            PlannedExerciseRow(plannedEx: plannedEx)
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
                    .disabled(planName.isEmpty || day.exercises.isEmpty)
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
        let planned = PlannedExercise(exercise: ex, order: day.exercises.count)
        // Add 3 default sets
        for i in 0..<3 {
            let set = PlannedSet(order: i, targetReps: 10)
            set.plannedExercise = planned
            planned.sets.append(set)
        }
        planned.day = day
        day.exercises.append(planned)
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        day.exercises.move(fromOffsets: source, toOffset: destination)
        for (index, ex) in day.exercises.enumerated() {
            ex.order = index
        }
    }
    
    private func delete(at offsets: IndexSet) {
        day.exercises.remove(atOffsets: offsets)
        for (index, ex) in day.exercises.enumerated() {
            ex.order = index
        }
    }
    
    private func savePlan() {
        let plan = WorkoutPlan(name: planName)
        day.plan = plan
        plan.days.append(day)
        
        modelContext.insert(plan)
        try? modelContext.save()
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct PlannedExerciseRow: View {
    @Bindable var plannedEx: PlannedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(plannedEx.exercise?.name ?? "")
                .atlasFont(AtlasTypography.headline())
                .foregroundColor(Color.Atlas.textPrimary)
            
            ForEach($plannedEx.sets) { $set in
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
                plannedEx.sets.remove(atOffsets: offsets)
                for (index, set) in plannedEx.sets.enumerated() {
                    set.order = index
                }
            }
            
            Button(action: {
                let newSet = PlannedSet(order: plannedEx.sets.count, targetReps: 10)
                newSet.plannedExercise = plannedEx
                plannedEx.sets.append(newSet)
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
