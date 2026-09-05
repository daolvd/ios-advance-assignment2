//
//  Payment.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//
import Foundation
import SwiftData

enum PaymentMethod: String, Codable, CaseIterable {
    case cash
    case card
 
    /// Label shown to staff on the checkout screen type cash or card.
    var displayName: String {
        switch self {
        case .cash: return "Cash"
        case .card: return "Card"
        }
    }
}

enum PaymentStatus: String, Codable {
    case approved
    case declined
    case cancelled
}

class Payment {
    class Payment {

        @Attribute(.unique) var paymentID: String
        var orderID: String

        /// The order total this attempt was for.
        var amount: Decimal

        var paymentMethod: PaymentMethod
        var status: PaymentStatus
        var attemptedAt: Date

        init(
            paymentID: String = UUID().uuidString,
            orderID: String,
            amount: Decimal,
            paymentMethod: PaymentMethod,
            status: PaymentStatus,
            attemptedAt: Date = Date()
        ) {
            self.paymentID = paymentID
            self.orderID = orderID
            self.amount = amount
            self.paymentMethod = paymentMethod
            self.status = status
            self.attemptedAt = attemptedAt
        }
    }
}
