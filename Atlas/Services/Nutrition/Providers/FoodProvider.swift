import Foundation

@MainActor
public protocol FoodProvider {
    var providerName: String { get }
    func search(query: String) async throws -> [FoodItem]
    func fetchByBarcode(_ barcode: String) async throws -> FoodItem?
}
