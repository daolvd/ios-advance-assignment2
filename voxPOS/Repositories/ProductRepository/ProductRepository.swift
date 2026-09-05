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
