import Foundation
import SwiftData
import Combine

@MainActor
public class FoodSearchService: ObservableObject {
    private let providers: [FoodProvider]
    private let foodRepository: FoodRepository
    
    @Published public var searchResults: [FoodItem] = []
    @Published public var isSearching: Bool = false
    @Published public var recentSearches: [String] = []
    
    public init(providers: [FoodProvider]? = nil, foodRepository: FoodRepository? = nil) {
        self.providers = providers ?? [USDAProvider(), OpenFoodFactsProvider()]
        self.foodRepository = foodRepository ?? FoodRepository()
    }
    
    public func search(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        defer { isSearching = false }
        
        var results: [FoodItem] = []
        
        // 1. Search local cached foods (both custom and previously logged API foods)
        if let allCached = try? foodRepository.fetchAll() {
            let matches = allCached.filter { $0.name.localizedCaseInsensitiveContains(query) || ($0.brand?.localizedCaseInsensitiveContains(query) == true) }
            results.append(contentsOf: matches)
        }
        
        // 2. Search external providers sequentially to avoid Sendable warnings with SwiftData models
        for provider in providers {
            if let providerResults = try? await provider.search(query: query) {
                results.append(contentsOf: providerResults)
            }
        }
        
        // 3. Deduplicate by name/brand combo (simplified)
        var seen = Set<String>()
        var deduped: [FoodItem] = []
        for item in results {
            let key = "\(item.name.lowercased())_\(item.brand?.lowercased() ?? "")"
            if !seen.contains(key) {
                seen.insert(key)
                deduped.append(item)
            }
        }
        
        self.searchResults = deduped
        
        // Update recent searches
        if !recentSearches.contains(query) {
            recentSearches.insert(query, at: 0)
            if recentSearches.count > 10 {
                recentSearches.removeLast()
            }
        }
    }
    
    public func lookupBarcode(_ barcode: String) async -> FoodItem? {
        // 1. Check local DB first
        if let local = try? foodRepository.fetch(byBarcode: barcode) {
            return local
        }
        
        // 2. Ask providers
        for provider in providers {
            if let result = try? await provider.fetchByBarcode(barcode) {
                return result
            }
        }
        return nil
    }
}
