//
//  Product.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation

struct Product: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var description: String?
    var image: String?
    var isAvailable: Bool = true
    var price: Decimal = 0
    var allowModifier : [String] = []
 
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "product_name"
        case description
        case image
        case isAvailable = "is_available"
        case price
        case allowModifier
    }
}
