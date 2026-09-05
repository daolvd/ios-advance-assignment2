//
//  ORDER.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation
import SwiftData

@Model
class Order {
        
        var orderID: String = UUID().uuidString
        var orderNumber: Int
        var status: String
        var spokenText: String?
        var detectedLanguage: String?
        var recognitionConfidence: Double?
        var orderTotal: Decimal
        var createdAt: Date
        var confirmedAt: Date?

        @Relationship(deleteRule: .cascade, inverse: \OrderItem.order)
        var items: [OrderItem] = []

        init(
          
            orderNumber: Int,
            status: String = "draft",
            orderTotal: Decimal = 0,
            createdAt: Date = Date()
        ) {
            self.orderNumber = orderNumber
            self.status = status
            self.orderTotal = orderTotal
            self.createdAt = createdAt
        }
}

@Model
class OrderItem {
        var orderItemID: String = UUID().uuidString
        var menuItemID: String
        var itemName: String
        var quantity: Int
        var modifiers: [String]
        var unitPrice: Decimal
        var lineTotal: Decimal

        var order: Order?

        init(
            menuItemID: String,
            itemName: String,
            quantity: Int,
            modifiers: [String] = [],
            unitPrice: Decimal
        ) {
            
            self.menuItemID = menuItemID
            self.itemName = itemName
            self.quantity = quantity
            self.modifiers = modifiers
            self.unitPrice = unitPrice
            self.lineTotal = unitPrice * Decimal(quantity)
        }
}
