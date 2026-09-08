//
//  ReviseOrderUseCase.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import Foundation

//The ways changing an order can fail.
enum OrderRevisionError: LocalizedError, Equatable {

    case orderAlreadyPaid

    case notOnTheMenu(product: String)

    case soldOut(product: String)

    case quantityBelowOne

    case lineNotInOrder

    var errorDescription: String? {
        switch self {
        case .orderAlreadyPaid:
            return "This order has been paid for and can't be changed."
        case .notOnTheMenu(let product):
            return "\(product) is not on today's menu."
        case .soldOut(let product):
            return "\(product) is sold out."
        case .quantityBelowOne:
            return "An order line needs at least one item."
        case .lineNotInOrder:
            return "That item is no longer part of this order."
        }
    }
}

/// What adding an item to an order did.
struct AddedOrderLine {
    let line: OrderItem

    let droppedOptions: [String]
}

//Changes an order the staff are still working on.
struct ReviseOrderUseCase {

    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    // Adds an item to an order, or grows the matching line if one is already there.
    @discardableResult
    func addItem(
        _ product: Product,
        quantity: Int,
        options: [String],
        order: Order
    ) throws -> AddedOrderLine {
        try checkStillOpen(order: order)

        guard quantity >= 1 else {
            throw OrderRevisionError.quantityBelowOne
        }

        // The caller may hand over a stale copy, so the menu is the authority on
        // whether this is still sellable and what it costs.
        guard let onMenu = repository.product(named: product.title) else {
            throw OrderRevisionError.notOnTheMenu(product: product.title)
        }

        guard onMenu.isAvailable else {
            throw OrderRevisionError.soldOut(product: onMenu.title)
        }

        let supported = options.filter(onMenu.allowModifier.contains)
        let dropped = options.filter { !onMenu.allowModifier.contains($0) }

        let line: OrderItem

        if let existing = order.items.first(where: {
            $0.menuItemID == onMenu.id && $0.modifiers == supported
        }) {
            existing.quantity += quantity
            existing.lineTotal = existing.unitPrice * Decimal(existing.quantity)
            line = existing
        } else {
            let added = OrderItem(
                menuItemID: onMenu.id,
                itemName: onMenu.title,
                quantity: quantity,
                modifiers: supported,
                unitPrice: onMenu.price
            )

            order.items.append(added)
            line = added
        }

        recalculateTotal(of: order)

        return AddedOrderLine(line: line, droppedOptions: dropped)
    }

    // Sets how many of one product's quantity which the customer wants.
    func setQuantity(_ quantity: Int, of item: OrderItem,  order: Order) throws {
        try checkStillOpen(order: order)
        try checkBelongs(item, to: order)

        guard quantity >= 1 else {
            throw OrderRevisionError.quantityBelowOne
        }

        item.quantity = quantity
        item.lineTotal = item.unitPrice * Decimal(quantity)

        recalculateTotal(of: order)
    }

    /// Changes which options a line is made with.
    ///
    /// If the change makes the line identical to another one already on the ticket,
    /// the two are merged — a cook should never be handed the same item twice with
    /// the same options.
    ///
    /// - Returns: Options that were asked for but the kitchen cannot make.
    @discardableResult
    func setOptions(_ options: [String], of item: OrderItem, order: Order) throws -> [String] {
        try checkStillOpen(order: order)
        try checkBelongs(item, to: order)

        guard let product = repository.products.first(where: { $0.id == item.menuItemID }) else {
            throw OrderRevisionError.notOnTheMenu(product: item.itemName)
        }

        let supported = options.filter(product.allowModifier.contains)
        let dropped = options.filter { !product.allowModifier.contains($0) }

        if let twin = order.items.first(where: {
            $0.orderItemID != item.orderItemID
                && $0.menuItemID == item.menuItemID
                && $0.modifiers == supported
        }) {
            twin.quantity += item.quantity
            twin.lineTotal = twin.unitPrice * Decimal(twin.quantity)
            order.items.removeAll { $0.orderItemID == item.orderItemID }
        } else {
            item.modifiers = supported
        }

        recalculateTotal(of: order)

        return dropped
    }

    // remove item in order
    func remove(item: OrderItem, order: Order) throws {
        try checkStillOpen(order: order)
        try checkBelongs(item, to: order)

        order.items.removeAll { $0.orderItemID == item.orderItemID }

        recalculateTotal(of: order)
    }

    private func checkStillOpen(order: Order) throws {
        guard order.status != "paid" else {
            throw OrderRevisionError.orderAlreadyPaid
        }
    }

    private func checkBelongs(_ item: OrderItem, to order: Order) throws {
        guard order.items.contains(where: { $0.orderItemID == item.orderItemID }) else {
            throw OrderRevisionError.lineNotInOrder
        }
    }

    private func recalculateTotal(of order: Order) {
        order.orderTotal = order.items.reduce(0) { $0 + $1.lineTotal }
    }
}
