//
//  Grocery.swift
//  Groceries
//
//  Created by Shuvam Shrestha on 4/9/2026.
//

import SwiftData

@Model class Grocery {
    var title: String
    @Relationship var items: [GroceryItem] = []
    
    init(title: String) {
        self.title = title
    }
}

@Model class GroceryItem {
    var title: String
    var notes: String?
    var imageURL: String?
    var isPurchased: Bool = false
    var quantity: Int = 0
    
    init(title: String, notes: String? = nil, imageURL: String? = nil, isPurchased: Bool, quantity: Int) {
        self.title = title
        self.notes = notes
        self.imageURL = imageURL
        self.isPurchased = isPurchased
        self.quantity = quantity
    }
}
