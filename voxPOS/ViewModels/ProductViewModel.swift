//
//  ProductViewModel.swift
//  Groceries
//
//  Created by Shuvam Shrestha on 14/8/2026.
//

import Foundation
import Combine

class ProductViewModel: ObservableObject {
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

 
