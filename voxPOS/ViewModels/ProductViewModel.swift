//
//  ProductViewModel.swift
//  Groceries
//
//  Created by Shuvam Shrestha on 14/8/2026.
//

import Foundation
import Combine

@MainActor
class ProductViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case ready([Product])
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    /// The menu for this shift. Empty until it has loaded.
    var products: [Product] {
        guard case .ready(let products) = state else { return [] }

        return products
    }

    var errorMessage: String? {
        guard case .failed(let message) = state else { return nil }

        return message
    }

    var isReady: Bool {
        !products.isEmpty
    }

    /// Reads the menu for the shift that is starting.
    ///
    /// Called once when a staff member signs in, before they can reach the till.
    /// A till with nothing to sell is treated as a failure rather than an empty menu.
    func bootstrap() {
        guard !isReady else { return }

        let products = repository.load()

        guard !products.isEmpty else {
            state = .failed("The menu could not be loaded. Please try again.")
            return
        }

        guard products.contains(where: \.isAvailable) else {
            state = .failed("Every item is sold out. Please contact your manager.")
            return
        }

        state = .ready(products)
    }

    /// Drops the menu when the shift ends, so the next staff member reads a fresh one.
    func reset() {
        state = .idle
    }

    func add(_ product: Product) {
        repository.add(product)
        reload()
    }

    func update(_ product: Product) {
        repository.update(product)
        reload()
    }

    func delete(_ product: Product) {
        repository.delete(product)
        reload()
    }

    private func reload() {
        state = .ready(repository.products)
    }
}
