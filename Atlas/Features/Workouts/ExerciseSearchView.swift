import SwiftUI
import SwiftData

public struct ExerciseSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExerciseDefinition.name) private var exercises: [ExerciseDefinition]
    
    @State private var searchText = ""
    var onSelect: (ExerciseDefinition) -> Void
    
    public init(onSelect: @escaping (ExerciseDefinition) -> Void) {
        self.onSelect = onSelect
    }
    
    var filteredExercises: [ExerciseDefinition] {
        if searchText.isEmpty { return exercises }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.primaryMuscle.localizedCaseInsensitiveContains(searchText) }
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.Atlas.background.ignoresSafeArea()
                
                VStack {
                    TextField("Search exercises, muscle...", text: $searchText)
                        .padding()
                        .background(Color.Atlas.surface)
                        .cornerRadius(CornerRadius.medium)
                        .padding()
                    
                    List(filteredExercises) { ex in
                        Button(action: { onSelect(ex) }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(ex.name)
                                        .atlasFont(AtlasTypography.headline())
                                        .foregroundColor(Color.Atlas.textPrimary)
                                    Text("\(ex.primaryMuscle) • \(ex.equipment.rawValue)")
                                        .atlasFont(AtlasTypography.subheadline())
                                        .foregroundColor(Color.Atlas.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color.Atlas.primary)
                            }
                        }
                        .listRowBackground(Color.Atlas.background)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                ExerciseRepository(context: modelContext).seedInitialExercisesIfNeeded()
            }
        }
    }
}
