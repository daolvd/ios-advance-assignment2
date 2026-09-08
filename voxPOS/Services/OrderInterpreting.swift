//
//  OrderInterpreting.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import Foundation

/// One line the model believes the customer asked for.
///
/// This is only what the model *said*. Nothing here is trusted yet: the name still
/// has to be found on the menu, and the price comes from the menu, never from here.
struct InterpretedOrderLine: Equatable {

    /// A product name taken from the menu, or ``notOnMenu``.
    let productName: String

    /// What the customer actually asked for, in their own words.
    ///
    /// Used to tell the staff what was left out when nothing on the menu matched.
    let customerWords: String

    let quantity: Int
    let modifiers: [String]

    /// The name the model must use when a customer asks for something not on the menu.
    ///
    /// The model is only allowed to answer with real menu names, so it needs a way to
    /// say "none of these" — otherwise it substitutes the nearest product it can see
    /// and the customer is charged for something they never asked for.
    static let notOnMenu = "Not on the menu"

    var isOnMenu: Bool {
        productName != Self.notOnMenu
    }
}

/// Reads an order out of a sentence.
///
/// The adapter owns the model, the prompt and the menu wording; callers only supply
/// the customer's words and the products those words have to be matched against.
protocol OrderInterpreting {
    func interpret(text: String, menu: [Product]) async throws -> [InterpretedOrderLine]
}
