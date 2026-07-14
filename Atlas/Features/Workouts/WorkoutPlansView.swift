import SwiftUI
import SwiftData

public struct WorkoutPlansView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    @Query(sort: \WorkoutPlan.name) private var plans: [WorkoutPlan]
    
    @Binding var showingActiveWorkout: Bool
    @State private var showingBuilder = false
    
    public init(showingActiveWorkout: Binding<Bool>) {
        self._showingActiveWorkout = showingActiveWorkout
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.Atlas.background.ignoresSafeArea()
                
                if plans.isEmpty {
                    EmptyState(
                        title: "No Plans Yet",
                        description: "Create your first workout plan to get started.",
                        icon: "list.clipboard",
                        actionTitle: "Create Plan",
                        action: { showingBuilder = true }
                    )
                } else {
                    List {
                        ForEach(plans) { plan in
                            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                                HStack {
                                    Text(plan.name)
                                        .atlasFont(AtlasTypography.headline())
                                        .foregroundColor(Color.Atlas.textPrimary)
                                    Spacer()
                                    Button(action: { startPlan(plan) }) {
                                        Text("Start")
                                            .atlasFont(AtlasTypography.caption(weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.Atlas.primary)
                                            .cornerRadius(12)
                                    }
                                }
                                
                                let totalExercises = plan.days.reduce(0) { $0 + $1.exercises.count }
                                Text("\(plan.days.count) days • \(totalExercises) exercises")
                                    .atlasFont(AtlasTypography.subheadline())
                                    .foregroundColor(Color.Atlas.textSecondary)
                            }
                            .listRowBackground(Color.Atlas.surface)
                        }
                        .onDelete(perform: deletePlans)
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("My Plans")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingBuilder = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingBuilder) {
                WorkoutBuilderView()
            }
        }
    }
    
    private func startPlan(_ plan: WorkoutPlan) {
        if let firstDay = plan.days.first {
            WorkoutSessionManager.shared.startWorkout(from: firstDay, context: modelContext)
            presentationMode.wrappedValue.dismiss()
            
            // Allow time for dismiss animation before presenting the active workout sheet from dashboard
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingActiveWorkout = true
            }
        }
    }
    
    private func deletePlans(at offsets: IndexSet) {
        for index in offsets {
            let plan = plans[index]
            modelContext.delete(plan)
        }
        try? modelContext.save()
    }
}
