//
//  ProductViewModel.swift
//  Groceries
//
//  Created by Shuvam Shrestha on 14/8/2026.
//

import Foundation
import Combine

final class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    
    let repository: ProductRepository
    
    init(repository: ProductRepository) {
        self.repository = repository
        load()
    }
    
    func load() {
        products = repository.products
    }
    
    func add(_ product: Product) {
            if let existingProduct = checkProductExists(for: product) {
                var updatedProduct = existingProduct
         //       updatedProduct.quantity += product.quantity
                update(updatedProduct)
            } else {
                repository.add(product)
                load()
            }
        }
    
    func update(_ product: Product) {
        repository.update(product)
        load()
    }
    
    func delete(_ product: Product) {
        repository.delete(product)
        load()
    }
}

extension ProductViewModel {
    func checkProductExists(for product: Product) -> Product? {
            products.first { existing in
                existing.title == product.title &&
                existing.description == product.description &&
                existing.image == product.image
            }
  
        }
}
