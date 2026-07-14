import SwiftUI
import SwiftData

public struct WeeklyReportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var isLoading = false
    @State private var report: WeeklyReportData? = nil
    @State private var errorMessage: String? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.Atlas.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.large) {
                        
                        if let error = errorMessage {
                            Text(error)
                                .atlasFont(AtlasTypography.subheadline())
                                .foregroundColor(Color.Atlas.error)
                                .padding()
                                .background(Color.Atlas.error.opacity(0.1))
                                .cornerRadius(CornerRadius.small)
                        }
                        
                        if let report = report {
                            WeeklyReportCard(report: report)
                                .padding(Spacing.medium)
                        } else if !isLoading && errorMessage == nil {
                            EmptyState(
                                title: "Weekly Report",
                                description: "Generate a comprehensive AI analysis of your past week's performance, consistency, and trends.",
                                icon: "chart.bar.doc.horizontal",
                                actionTitle: "Generate Report"
                            ) {
                                generateReport()
                            }
                            .padding(.top, Spacing.xxLarge)
                        }
                    }
                }
                
                if isLoading {
                    LoadingOverlay(message: "Atlas is analyzing your week...")
                }
            }
            .navigationTitle("Weekly Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                if AIConfiguration.shared.enableWeeklyReports && report == nil {
                    // Auto-generate if enabled and not already generated
                    // (In a real app, we might check if it's Sunday, but we'll allow manual trigger too)
                }
            }
        }
    }
    
    private func generateReport() {
        isLoading = true
        errorMessage = nil
        
        Task {
            let result = await AIService.shared.generateWeeklyReport(context: modelContext)
            
            await MainActor.run {
                isLoading = false
                switch result {
                case .success(let data):
                    self.report = data
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
