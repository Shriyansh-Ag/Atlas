import SwiftUI

public struct AllergiesStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("Any allergies?")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
                .padding(.top, 40)
            
            Text("Select all that apply.")
                .font(AtlasTypography.body())
                .foregroundColor(Color.Atlas.textSecondary)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Allergy.allCases) { allergy in
                        SelectionCard(
                            title: allergy.rawValue,
                            isSelected: viewModel.allergies.contains(allergy),
                            action: {
                                if viewModel.allergies.contains(allergy) {
                                    viewModel.allergies.remove(allergy)
                                } else {
                                    viewModel.allergies.insert(allergy)
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
