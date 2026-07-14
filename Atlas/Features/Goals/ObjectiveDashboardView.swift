import SwiftUI
import SwiftData

public struct ObjectiveDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AtlasObjective.targetDate) private var objectives: [AtlasObjective]
    
    @State private var showingBuilder = false
    
    public init() {}
    
    private var goals: [AtlasObjective] {
        objectives.filter { !$0.isChallenge }
    }
    
    private var challenges: [AtlasObjective] {
        objectives.filter { $0.isChallenge }
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.Atlas.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.large) {
                        
                        // Goals Section
                        VStack(alignment: .leading, spacing: Spacing.medium) {
                            SectionHeader(title: "My Goals")
                            
                            if goals.isEmpty {
                                EmptyState(
                                    title: "No Active Goals",
                                    description: "Set a fitness goal to stay focused.",
                                    icon: "target",
                                    actionTitle: "Create Goal",
                                    action: { showingBuilder = true }
                                )
                            } else {
                                ForEach(goals) { goal in
                                    let prog = ObjectiveCalculator.calculateProgress(for: goal, context: modelContext)
                                    ObjectiveCard(objective: goal, currentValue: prog.currentValue, status: prog.status) {
                                        // Detail view or edit
                                    }
                                }
                            }
                        }
                        
                        // Challenges Section
                        VStack(alignment: .leading, spacing: Spacing.medium) {
                            SectionHeader(title: "Challenges")
                            
                            if challenges.isEmpty {
                                EmptyState(
                                    title: "No Active Challenges",
                                    description: "Join a challenge or create your own.",
                                    icon: "flame",
                                    actionTitle: "Create Challenge",
                                    action: { showingBuilder = true }
                                )
                            } else {
                                ForEach(challenges) { challenge in
                                    let prog = ObjectiveCalculator.calculateProgress(for: challenge, context: modelContext)
                                    ObjectiveCard(objective: challenge, currentValue: prog.currentValue, status: prog.status) {
                                        // Detail view or edit
                                    }
                                }
                            }
                        }
                    }
                    .padding(Spacing.medium)
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingBuilder = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color.Atlas.primary)
                    }
                }
            }
            .sheet(isPresented: $showingBuilder) {
                ObjectiveBuilderView()
            }
        }
    }
}
