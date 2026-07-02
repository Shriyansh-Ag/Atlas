import SwiftUI
import SwiftData

public struct WorkoutPlansView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutPlan.name) private var plans: [WorkoutPlan]
    
    @State private var showingBuilder = false
    
    public init() {}
    
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
                                Text(plan.name)
                                    .atlasFont(AtlasTypography.headline())
                                    .foregroundColor(Color.Atlas.textPrimary)
                                
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
    
    private func deletePlans(at offsets: IndexSet) {
        for index in offsets {
            let plan = plans[index]
            modelContext.delete(plan)
        }
        try? modelContext.save()
    }
}
