//
//  LocalProductRepository.swift
//  Groceries
//
//  Created by Shuvam Shrestha on 21/8/2026.
//

import Foundation

class LocalProductRepository: ProductRepository {
    private(set) var products: [Product] = []
    
    init() {
        products = load()
    }
    
    func load() -> [Product] {
        let localProducts = [
            Product(title: "Pineapple", image: "pineapple"),
            Product(title: "Tomato", description: "Please get the Roma kind, not the Gourmet. I'll go ham if I receive a Gourmet."),
         
        ]
       
        return localProducts
    }
    
    func add(_ product: Product) {
        products.append(product)
    }
    
    func update(_ product: Product) {
        guard let index = products.firstIndex(where: {$0.id == product.id}) else { return }
        
        products[index] = product
    }
    
    func delete(_ product: Product) {
        guard let index = products.firstIndex(where: {$0.id == product.id}) else { return }
        
        products.remove(at: index)
    }
    
    
}



