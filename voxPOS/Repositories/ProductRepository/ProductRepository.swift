//
//  ProductRepository.swift
//  Groceries
//
//  Created by Shuvam Shrestha on 14/8/2026.
//

import Foundation

protocol ProductRepository {
    var products: [Product] { get }
    func load() -> [Product]
    func add(_ product: Product)
    func update(_ product: Product)
    func delete(_ product: Product)
}

extension ProductRepository {

    /// The products that can actually be ordered right now.
    var availableProducts: [Product] {
        products.filter(\.isAvailable)
    }

    func product(named name: String) -> Product? {
        let wanted = name.normalisedForMatching

        guard !wanted.isEmpty else { return nil }

        return products.first { $0.title.normalisedForMatching == wanted }
    }

}

private extension String {
    var normalisedForMatching: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}
