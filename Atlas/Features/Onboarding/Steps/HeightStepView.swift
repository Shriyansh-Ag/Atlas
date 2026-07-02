import SwiftUI

public struct HeightStepView: View {
    @ObservedObject public var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack(spacing: 24) {
            Text("How tall are you?")
                .font(AtlasTypography.largeTitle())
                .foregroundColor(Color.Atlas.textPrimary)
                .padding(.top, 40)
            
            UnitToggleButton(
                isMetric: $viewModel.isMetric,
                metricLabel: "cm",
                imperialLabel: "ft / in"
            )
            
            Spacer()
            
            if viewModel.isMetric {
                VStack {
                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        TextField("Height", value: $viewModel.heightCm, format: .number)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundColor(Color.Atlas.primary)
                            .multilineTextAlignment(.center)
                            .frame(width: 150)
                        
                        Text("cm")
                            .font(AtlasTypography.title2())
                            .foregroundColor(Color.Atlas.textSecondary)
                    }
                }
            } else {
                HStack(spacing: 20) {
                    // Feet
                    VStack {
                        Picker("Feet", selection: $viewModel.heightFt) {
                            ForEach(1...8, id: \.self) { ft in
                                Text("\(ft)'").tag(ft)
                                    .font(AtlasTypography.title())
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 200)
                        .clipped()
                    }
                    
                    // Inches
                    VStack {
                        Picker("Inches", selection: $viewModel.heightIn) {
                            ForEach(0...11, id: \.self) { inch in
                                Text("\(inch)\"").tag(inch)
                                    .font(AtlasTypography.title())
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 200)
                        .clipped()
                    }
                }
            }
            
            Spacer()
        }
    }
}
