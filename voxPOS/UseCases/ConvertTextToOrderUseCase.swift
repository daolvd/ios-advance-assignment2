//
//  ConvertTextToOrderUseCase.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import Foundation

/// The ways turning a sentence into an order can fail.
enum OrderInterpretationError: LocalizedError, Equatable {

    /// There were no words to work from.
    case noTextToInterpret

    /// The on-device model cannot be used on this device right now.
    case modelUnavailable(reason: String)

    /// The model ran but found nothing that looked like an order.
    case nothingOrdered

    /// Items were heard, but not one of them is on today's menu.
    case nothingOnTheMenu

    /// The model failed part way through.
    case interpretationFailed(reason: String)

    /// The instructions file is missing from the app bundle.
    case instructionsMissing

    var errorDescription: String? {
        switch self {
        case .noTextToInterpret:
            return "There is nothing to turn into an order yet."
        case .modelUnavailable(let reason):
            return reason
        case .nothingOrdered:
            return "We couldn't find an order in that. Please try again."
        case .nothingOnTheMenu:
            return "Nothing the customer asked for is on today's menu."
        case .interpretationFailed:
            return "We couldn't read that order. Please try again or add the items by hand."
        case .instructionsMissing:
            return "Voice ordering is not set up correctly. Please add the items by hand."
        }
    }
}

/// An order built from what a customer said, plus anything that could not be matched.
struct InterpretedOrder {

    /// The draft order, priced from the menu and ready for the staff to confirm.
    let order: Order

    /// Things the customer asked for that are not on today's menu.
    ///
    /// These are shown to the staff rather than dropped in silence, so nobody
    /// discovers a missing item after the customer has paid.
    let unmatchedItems: [String]
}

/// Turns what a customer said into a draft order.
///
/// The on-device model reads the sentence and says which products it thinks were
/// asked for. Every line it returns is then checked against today's menu: names are
/// matched to real products, options the kitchen cannot make are dropped, and the
/// price is taken from the menu — never from the model, which is free to write any
/// number it likes and must not be trusted with money.
///
/// The result is a draft. It is not saved and not paid for until the staff confirm it.
struct ConvertTextToOrderUseCase {

    private let interpreter: OrderInterpreting
    private let repository: ProductRepository

    init(interpreter: OrderInterpreting, repository: ProductRepository) {
        self.interpreter = interpreter
        self.repository = repository
    }

    /// Builds a draft order from a sentence.
    ///
    /// - Parameters:
    ///   - text: What the customer said, in the staff's language.
    ///   - orderNumber: The number this order will be called out by.
    /// - Returns: The draft order, and anything that could not be found on the menu.
    /// - Throws: ``OrderInterpretationError`` when there is nothing to read, the model
    ///   cannot run, or nothing asked for is on the menu.
    func execute(text: String, orderNumber: Int) async throws -> InterpretedOrder {
        let spokenText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !spokenText.isEmpty else {
            throw OrderInterpretationError.noTextToInterpret
        }

        let lines = try await interpreter.interpret(
            text: spokenText,
            menu: repository.menuDescription
        )

        guard !lines.isEmpty else {
            throw OrderInterpretationError.nothingOrdered
        }

        var items: [OrderItem] = []
        var unmatchedItems: [String] = []

        for line in lines {
            // Only a product that is on the menu and on sale can be ordered.
            guard
                let product = repository.product(named: line.productName),
                product.isAvailable
            else {
                unmatchedItems.append(line.productName)
                continue
            }

            items.append(
                OrderItem(
                    menuItemID: product.id,
                    itemName: product.title,
                    // The model occasionally writes 0 for "a coffee".
                    quantity: max(line.quantity, 1),
                    // Anything the kitchen cannot make is dropped.
                    modifiers: line.modifiers.filter(product.allowModifier.contains),
                    // The price comes from the menu, never from the model.
                    unitPrice: product.price
                )
            )
        }

        guard !items.isEmpty else {
            throw OrderInterpretationError.nothingOnTheMenu
        }

        let order = Order(
            orderNumber: orderNumber,
            orderTotal: items.reduce(0) { $0 + $1.lineTotal }
        )

        order.spokenText = spokenText
        order.items = items

        return InterpretedOrder(order: order, unmatchedItems: unmatchedItems)
    }
}
