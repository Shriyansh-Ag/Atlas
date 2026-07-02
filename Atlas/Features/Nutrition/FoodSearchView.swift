import SwiftUI
import SwiftData

public struct FoodSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var searchService = FoodSearchService()
    @State private var query: String = ""
    @State private var showBarcodeScanner = false
    
    let mealType: MealType
    
    public init(mealType: MealType) {
        self.mealType = mealType
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(Color.Atlas.textSecondary)
                    TextField("Search food...", text: $query)
                        .onChange(of: query) { newValue in
                            Task {
                                await searchService.search(query: newValue)
                            }
                        }
                    if !query.isEmpty {
                        Button(action: { query = "" }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(Color.Atlas.textSecondary)
                        }
                    }
                }
                .padding(Spacing.small)
                .glassBackground()
                .cornerRadius(CornerRadius.medium)
                
                BarcodeButton {
                    showBarcodeScanner = true
                }
            }
            .padding()
            
            if searchService.isSearching {
                Spacer()
                ProgressView()
                Spacer()
            } else if searchService.searchResults.isEmpty && !query.isEmpty {
                Spacer()
                EmptyState(
                    title: "No foods found",
                    description: "We couldn't find any food matching '\(query)'.",
                    icon: "magnifyingglass",
                    actionTitle: "Create Custom Food",
                    action: {
                        // TODO: Navigate to create custom food
                    }
                )
                Spacer()
            } else {
                List {
                    ForEach(searchService.searchResults) { food in
                        NavigationLink(destination: FoodDetailView(food: food, mealType: mealType)) {
                            FoodRow(food: food) {}
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(Color.Atlas.background.ignoresSafeArea())
        .navigationTitle("Log \(mealType.rawValue.capitalized)")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showBarcodeScanner) {
            BarcodeScannerView { barcode in
                Task {
                    query = barcode
                    if let result = await searchService.lookupBarcode(barcode) {
                        searchService.searchResults = [result]
                    }
                }
            }
        }
    }
}
