//
//  Payment.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//
import Foundation
import SwiftData

/// How the customer is paying.
///
/// The two differ in who can refuse. Cash is settled between two people at the
/// counter and cannot be declined by the till; a card goes to a terminal that can.
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

/// How one attempt to take money ended.
///
/// ``declined`` is an ordinary outcome, not an error: the staff simply offer another
/// method. It is recorded exactly like an approval, because a shift cannot be
/// reconciled from approvals alone — an order paid on the second tap must not look
/// like it was only ever paid once.
enum PaymentStatus: String, Codable {
    case approved
    case declined
    case cancelled
}


/// One attempt to take money for an order.
///
/// A payment is a record of something that happened, so nothing here is ever edited
/// after the fact. A second try writes a second `Payment`; the pair of them is what
/// makes the till's day add up.
class Payment {

        var paymentID: String

        /// The order this was for, as `Order.orderID`. More than one payment may
        /// carry the same id when a first attempt was declined.
        var orderID: String

        /// The order total this attempt was for.
        var amount: Decimal

        var paymentMethod: PaymentMethod

        /// Whether the money was taken. Only ``PaymentStatus/approved`` closes the
        /// order; the others leave it open for another attempt.
        var status: PaymentStatus

        /// When the attempt was made, which is what a cash-up is read in order of.
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
