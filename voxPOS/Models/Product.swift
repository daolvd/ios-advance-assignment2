//
//  Product.swift
//  Groceries
//
//  Created by Shuvam Shrestha on 7/8/2026.
//

import Foundation

struct Product: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var description: String?
    var image: String?
    
 
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "product_name"
        case description
        case image
    }
}
