//
//  StartManualOrderUseCase.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import Foundation

/// The ways opening a hand-written order can fail.
enum ManualOrderError: LocalizedError, Equatable {

    /// There is nothing on today's menu that can be sold.
    case nothingAvailableToSell

    var errorDescription: String? {
        switch self {
        case .nothingAvailableToSell:
            return "There is nothing left to sell. Please contact your manager."
        }
    }
}

/// Opens an empty ticket for an order the staff take by hand.
///
/// Every order does not arrive through the microphone. A noisy room, an accent the
/// model cannot place, or a customer who would rather point at the menu all end the
/// same way: the staff member enters the lines themselves. This is the till's way
/// back in when the spoken path cannot help.
///
/// What it produces is an ordinary ``Order`` — the same one a spoken order produces,
/// carrying the same number series and going on to the same review, the same
/// ``ReviseOrderUseCase`` rules and the same payment. Only the first line arrives by
/// hand instead of out of a transcript.
///
/// An order is refused before it is numbered when the menu has nothing on sale:
/// spending an order number on a ticket that can never hold a line leaves a gap in
/// the day's numbering that nobody can account for afterwards.
struct StartManualOrderUseCase {

    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    /// Opens the ticket.
    ///
    /// - Parameter orderNumber: The number this order will be called by.
    /// - Returns: An empty draft order, ready for its first line.
    /// - Throws: ``ManualOrderError/nothingAvailableToSell`` when the menu is empty
    ///   or entirely sold out.
    func execute(orderNumber: Int) throws -> Order {
        guard !repository.availableProducts.isEmpty else {
            throw ManualOrderError.nothingAvailableToSell
        }

        return Order(orderNumber: orderNumber)
    }
}
