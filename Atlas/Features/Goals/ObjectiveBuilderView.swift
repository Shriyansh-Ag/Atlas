import SwiftUI
import SwiftData

public struct ObjectiveBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    @State private var type: ObjectiveType = .weightLoss
    @State private var targetValue: Double = 0
    @State private var targetDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    @State private var isChallenge: Bool = false
    @State private var reminderEnabled: Bool = true
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Objective Details")) {
                    TextField("Title (e.g. Summer Cut)", text: $title)
                    
                    Picker("Type", selection: $type) {
                        ForEach(ObjectiveType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    
                    HStack {
                        Text("Target Value")
                        Spacer()
                        TextField("Value", value: $targetValue, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                }
                
                Section(header: Text("Configuration")) {
                    Toggle("Is Challenge?", isOn: $isChallenge)
                    Toggle("Smart Reminders", isOn: $reminderEnabled)
                }
            }
            .navigationTitle("New Objective")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                        .disabled(title.isEmpty || targetValue == 0)
                }
            }
        }
    }
    
    private func save() {
        let obj = AtlasObjective(
            title: title,
            type: type,
            targetValue: targetValue,
            targetDate: targetDate,
            isChallenge: isChallenge,
            reminderEnabled: reminderEnabled
        )
        modelContext.insert(obj)
        try? modelContext.save()
        dismiss()
    }
}
