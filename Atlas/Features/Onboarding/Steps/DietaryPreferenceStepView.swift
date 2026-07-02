import SwiftUI

public struct DietaryPreferenceStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("Any dietary preferences?")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
                .padding(.top, 40)
            
            Text("Select all that apply.")
                .font(AtlasTypography.body())
                .foregroundColor(Color.Atlas.textSecondary)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(DietaryPreference.allCases) { pref in
                        SelectionCard(
                            title: pref.rawValue,
                            isSelected: viewModel.dietaryPreferences.contains(pref),
                            action: {
                                if pref == .none {
                                    viewModel.dietaryPreferences.removeAll()
                                    viewModel.dietaryPreferences.insert(.none)
                                } else {
                                    viewModel.dietaryPreferences.remove(.none)
                                    if viewModel.dietaryPreferences.contains(pref) {
                                        viewModel.dietaryPreferences.remove(pref)
                                    } else {
                                        viewModel.dietaryPreferences.insert(pref)
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
        }
    }
}
