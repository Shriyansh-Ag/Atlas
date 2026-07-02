import SwiftUI
import SwiftData

public struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appEnvironment) private var environment
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.Atlas.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar (hide on first and last step)
                if viewModel.currentStepIndex > 0 && viewModel.currentStepIndex < viewModel.totalSteps - 1 {
                    ProgressBar(progress: viewModel.progress)
                        .padding(.horizontal)
                        .padding(.top, 16)
                }
                
                // Content
                TabView(selection: $viewModel.currentStepIndex) {
                    WelcomeStepView(viewModel: viewModel)
                        .tag(0)
                    NameStepView(viewModel: viewModel)
                        .tag(1)
                    AgeStepView(viewModel: viewModel)
                        .tag(2)
                    SexStepView(viewModel: viewModel)
                        .tag(3)
                    HeightStepView(viewModel: viewModel)
                        .tag(4)
                    WeightStepView(viewModel: viewModel)
                        .tag(5)
                    GoalWeightStepView(viewModel: viewModel)
                        .tag(6)
                    FitnessGoalStepView(viewModel: viewModel)
                        .tag(7)
                    ActivityLevelStepView(viewModel: viewModel)
                        .tag(8)
                    WorkoutExperienceStepView(viewModel: viewModel)
                        .tag(9)
                    WorkoutDaysStepView(viewModel: viewModel)
                        .tag(10)
                    DietaryPreferenceStepView(viewModel: viewModel)
                        .tag(11)
                    AllergiesStepView(viewModel: viewModel)
                        .tag(12)
                    NotificationsStepView(viewModel: viewModel)
                        .tag(13)
                    HealthKitStepView(viewModel: viewModel)
                        .tag(14)
                    SummaryStepView(viewModel: viewModel)
                        .tag(15)
                    FinishStepView(viewModel: viewModel, environment: environment)
                        .tag(16)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                // Disable swiping between tabs, forcing the use of buttons
                .scrollDisabled(true)
                
                // Bottom Navigation
                if viewModel.currentStepIndex > 0 && viewModel.currentStepIndex < viewModel.totalSteps - 1 {
                    HStack {
                        if viewModel.currentStepIndex > 1 {
                            Button(action: {
                                viewModel.previousStep()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(Color.Atlas.textSecondary)
                                    .padding()
                                    .background(Circle().fill(Color.Atlas.surface))
                            }
                        }
                        
                        Spacer()
                        
                        PrimaryButton(
                            title: viewModel.currentStepIndex == 15 ? "Complete" : "Continue",
                            action: {
                                viewModel.nextStep()
                            }
                        )
                        .disabled(!viewModel.isCurrentStepValid)
                        .opacity(viewModel.isCurrentStepValid ? 1.0 : 0.5)
                        .frame(maxWidth: 200)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
        // Dismiss keyboard on tap
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
