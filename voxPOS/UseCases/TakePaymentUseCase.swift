//
//  TakePaymentUseCase.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import Foundation

/// The ways taking money for an order can fail.
enum PaymentError: LocalizedError, Equatable {

    /// There is nothing to charge for.
    case emptyOrder

    /// The order total is zero or less.
    case nothingToCharge

    /// This order has already been paid for.
    case alreadyPaid

    /// The terminal could not be reached.
    case terminalUnavailable(reason: String)

    /// The attempt could not be written down.
    case couldNotRecordAttempt

    var errorDescription: String? {
        switch self {
        case .emptyOrder:
            return "There is nothing in this order."
        case .nothingToCharge:
            return "This order has no amount to charge."
        case .alreadyPaid:
            return "This order has already been paid for."
        case .terminalUnavailable:
            return "The card terminal isn't responding. Try cash, or try again."
        case .couldNotRecordAttempt:
            return "The payment could not be recorded. Please try again."
        }
    }
}

/// Takes payment for a finished order.
///
/// Cash is settled by the staff member at the counter, so it is approved as soon as
/// they say they have taken it. Card and QR go to the terminal, which may decline.
///
/// Every attempt is written down before this returns — approved or declined. A
/// decline that went unrecorded would leave a shift that cannot be reconciled, and
/// an order paid on the second try must not look like it was only ever paid once.
///
/// A declined payment is a normal outcome, not an error: it comes back as a
/// ``Payment`` with ``PaymentStatus/declined`` so the staff can offer another method.
/// Only something that stops the attempt being made at all is thrown.
struct TakePaymentUseCase {

    private let repository: PaymentRepository
    private let terminal: PaymentAuthorizing

    init(repository: PaymentRepository, terminal: PaymentAuthorizing = SimulatedPaymentTerminal()) {
        self.repository = repository
        self.terminal = terminal
    }

    /// Charges an order.
    ///
    /// - Parameters:
    ///   - order: The order being paid for.
    ///   - method: How the customer is paying.
    /// - Returns: The attempt, approved or declined.
    /// - Throws: ``PaymentError`` when the attempt cannot be made or recorded.
    func execute(order: Order, method: PaymentMethod) async throws -> Payment {
        guard !order.items.isEmpty else {
            throw PaymentError.emptyOrder
        }

        let amount = order.items.reduce(Decimal(0)) { $0 + $1.lineTotal }

        guard amount > 0 else {
            throw PaymentError.nothingToCharge
        }

        guard repository.approvedPayment(orderID: order.orderID) == nil else {
            throw PaymentError.alreadyPaid
        }

        let status: PaymentStatus

        switch method {
        case .cash:
            // The staff member has the notes in hand; there is nothing to authorise.
            status = .approved

        case .card:
            do {
                status = try await terminal.authorize(amount: amount, method: method)
            } catch {
                throw PaymentError.terminalUnavailable(reason: error.localizedDescription)
            }
        }

        let payment = Payment(
            orderID: order.orderID,
            amount: amount,
            paymentMethod: method,
            status: status
        )

        do {
            try repository.recordPaymentAttempt(payment)
        } catch {
            throw PaymentError.couldNotRecordAttempt
        }

        if status == .approved {
            order.status = "paid"
            order.confirmedAt = Date()
            order.orderTotal = amount
        }

        return payment
    }
}
