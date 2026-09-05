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
    let productName: String
    let quantity: Int
    let modifiers: [String]
}

/// Reads an order out of a sentence.
///
/// The adapter owns the model and the prompt; callers only supply the customer's
/// words and the menu those words have to be matched against.
protocol OrderInterpreting {
    func interpret(text: String, menu: String) async throws -> [InterpretedOrderLine]
}
