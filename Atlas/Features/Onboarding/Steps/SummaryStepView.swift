import SwiftUI

public struct SummaryStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("Review Your Profile")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
                .padding(.top, 40)
            
            ScrollView {
                VStack(spacing: 16) {
                    SummaryRow(title: "Name", value: viewModel.name)
                    SummaryRow(title: "Age", value: "\(viewModel.age)")
                    SummaryRow(title: "Sex", value: viewModel.biologicalSex?.rawValue ?? "Not set")
                    
                    if viewModel.isMetric {
                        SummaryRow(title: "Height", value: String(format: "%.1f cm", viewModel.heightCm))
                        SummaryRow(title: "Weight", value: String(format: "%.1f kg", viewModel.weightKg))
                        if let gw = viewModel.goalWeightKg {
                            SummaryRow(title: "Goal Weight", value: String(format: "%.1f kg", gw))
                        } else {
                            SummaryRow(title: "Goal Weight", value: "Not set")
                        }
                    } else {
                        SummaryRow(title: "Height", value: "\(viewModel.heightFt)' \(viewModel.heightIn)\"")
                        SummaryRow(title: "Weight", value: String(format: "%.1f lbs", viewModel.weightLbs))
                        if let gw = viewModel.goalWeightLbs {
                            SummaryRow(title: "Goal Weight", value: String(format: "%.1f lbs", gw))
                        } else {
                            SummaryRow(title: "Goal Weight", value: "Not set")
                        }
                    }
                    
                    SummaryRow(title: "Fitness Goal", value: viewModel.fitnessGoal?.rawValue ?? "Not set")
                    SummaryRow(title: "Activity Level", value: viewModel.activityLevel?.rawValue ?? "Not set")
                    SummaryRow(title: "Experience", value: viewModel.workoutExperience?.rawValue ?? "Not set")
                    SummaryRow(title: "Workouts/Week", value: "\(viewModel.workoutDaysPerWeek) days")
                    
                    SummaryRow(title: "Diet", value: viewModel.dietaryPreferences.isEmpty ? "None" : viewModel.dietaryPreferences.map { $0.rawValue }.joined(separator: ", "))
                    SummaryRow(title: "Allergies", value: viewModel.allergies.isEmpty ? "None" : viewModel.allergies.map { $0.rawValue }.joined(separator: ", "))
                }
                .padding()
                .background(Color.Atlas.surface)
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
        }
    }
}

fileprivate struct SummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(AtlasTypography.body())
                .foregroundColor(Color.Atlas.textSecondary)
            Spacer()
            Text(value)
                .font(AtlasTypography.headline())
                .foregroundColor(Color.Atlas.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        Divider().background(Color.Atlas.textSecondary.opacity(0.3))
    }
}
