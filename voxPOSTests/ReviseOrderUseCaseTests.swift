//
//  ReviseOrderUseCaseTests.swift
//  voxPOSTests
//
//  Created by Van Dao Le on 6/9/2026.
//
//  White box, path coverage of ReviseOrderUseCase.
//
//  addItem
//    A1  order already paid            -> throws .orderAlreadyPaid
//    A2  quantity below one            -> throws .quantityBelowOne
//    A3  product not on the menu       -> throws .notOnTheMenu
//    A4  product sold out              -> throws .soldOut
//    A5  no matching line              -> appends a new line
//    A6  matching line already there   -> raises its quantity instead
//    A7  option the kitchen refuses    -> kept out of the line, returned as dropped
//
//  setQuantity
//    S1  order already paid            -> throws .orderAlreadyPaid
//    S2  line not on this order        -> throws .lineNotInOrder
//    S3  quantity below one            -> throws .quantityBelowOne
//    S4  valid                         -> line and order total both follow
//
//  remove
//    R1  line not on this order        -> throws .lineNotInOrder
//    R2  valid                         -> line gone, order total follows
//
//  Boundary: one is the smallest quantity a line may hold (A2, S3, S4).
//

import Testing
import Foundation
@testable import voxPOS

struct ReviseOrderUseCaseTests {

    private let useCase = ReviseOrderUseCase(repository: Menu.repository())

    private func paidOrder() -> Order {
        let order = makeOrder(items: [makeItem()])
        order.status = "paid"

        return order
    }

    // MARK: A5, A7 — adding a line

    @Test func addItem_pricesTheLineFromTheMenu_notFromTheCaller() throws {
        let order = makeOrder()

        // A caller holding a stale product with the wrong price must not set it.
        var stale = Menu.cheeseburger
        stale.price = 0.01

        try useCase.addItem(stale, quantity: 2, options: [], order: order)

        let line = try #require(order.items.first)
        #expect(line.unitPrice == Decimal(9.90))
        #expect(line.lineTotal == Decimal(19.80))
        #expect(order.orderTotal == Decimal(19.80))
    }

    @Test func addItem_keepsOnlyOptionsTheKitchenCanMake_andReportsTheRest() throws {
        let order = makeOrder()

        let added = try useCase.addItem(
            Menu.chickenBurger,
            quantity: 1,
            options: ["No Mayonnaise", "No Cheese"],
            order: order
        )

        #expect(added.line.modifiers == ["No Mayonnaise"])
        #expect(added.droppedOptions == ["No Cheese"], "the staff must be told what was left out")
    }

    // MARK: A6 — the same thing twice

    @Test func addItem_raisesTheQuantity_whenTheSameLineIsAlreadyOnTheOrder() throws {
        let order = makeOrder()

        try useCase.addItem(Menu.cheeseburger, quantity: 2, options: ["Add Bacon"], order: order)
        try useCase.addItem(Menu.cheeseburger, quantity: 1, options: ["Add Bacon"], order: order)

        // A cook should never be handed the same item on two lines.
        #expect(order.items.count == 1)
        #expect(order.items.first?.quantity == 3)
        #expect(order.orderTotal == Decimal(29.70))
    }

    @Test func addItem_startsASecondLine_whenTheOptionsDiffer() throws {
        let order = makeOrder()

        try useCase.addItem(Menu.cheeseburger, quantity: 1, options: ["Add Bacon"], order: order)
        try useCase.addItem(Menu.cheeseburger, quantity: 1, options: [], order: order)

        #expect(order.items.count == 2, "different options are different things to cook")
    }

    // MARK: A1 to A4 — refusals

    @Test func addItem_fails_whenTheOrderHasBeenPaidFor() {
        // Changing a paid order leaves the money taken and the ticket disagreeing.
        #expect(throws: OrderRevisionError.orderAlreadyPaid) {
            try useCase.addItem(Menu.cheeseburger, quantity: 1, options: [], order: paidOrder())
        }
    }

    /// Boundary: one is the smallest a line may be, so zero is refused.
    @Test func addItem_fails_whenQuantityIsBelowOne() {
        let order = makeOrder()

        #expect(throws: OrderRevisionError.quantityBelowOne) {
            try useCase.addItem(Menu.cheeseburger, quantity: 0, options: [], order: order)
        }

        #expect(order.items.isEmpty)
    }

    @Test func addItem_fails_whenTheProductIsNotOnTodaysMenu() {
        let sushi = Product(id: "99", title: "Sushi", isAvailable: true, price: 12)

        #expect(throws: OrderRevisionError.notOnTheMenu(product: "Sushi")) {
            try useCase.addItem(sushi, quantity: 1, options: [], order: makeOrder())
        }
    }

    @Test func addItem_fails_whenTheProductIsSoldOut() {
        #expect(throws: OrderRevisionError.soldOut(product: "Hot Dog")) {
            try useCase.addItem(Menu.soldOutHotDog, quantity: 1, options: [], order: makeOrder())
        }
    }

    // MARK: S4 — changing a quantity

    @Test func setQuantity_updatesTheLineAndTheOrderTotal() throws {
        let item = makeItem(Menu.cheeseburger, quantity: 1)
        let order = makeOrder(items: [item])

        try useCase.setQuantity(3, of: item, order: order)

        #expect(item.quantity == 3)
        #expect(item.lineTotal == Decimal(29.70))
        #expect(order.orderTotal == Decimal(29.70))
    }

    /// Boundary: one is allowed, and is where the minus button has to stop.
    @Test func setQuantity_allowsALineOfExactlyOne() throws {
        let item = makeItem(Menu.cheeseburger, quantity: 2)
        let order = makeOrder(items: [item])

        try useCase.setQuantity(1, of: item, order: order)

        #expect(item.quantity == 1)
    }

    // MARK: S1 to S3 — refusals

    @Test func setQuantity_fails_whenQuantityIsBelowOne() {
        let item = makeItem(Menu.cheeseburger, quantity: 2)
        let order = makeOrder(items: [item])

        #expect(throws: OrderRevisionError.quantityBelowOne) {
            try useCase.setQuantity(0, of: item, order: order)
        }

        #expect(item.quantity == 2, "a refused change must leave the line alone")
    }

    @Test func setQuantity_fails_whenTheLineIsNotOnThisOrder() {
        let strayItem = makeItem(Menu.cheeseburger)

        #expect(throws: OrderRevisionError.lineNotInOrder) {
            try useCase.setQuantity(2, of: strayItem, order: makeOrder())
        }
    }

    @Test func setQuantity_fails_whenTheOrderHasBeenPaidFor() {
        let order = paidOrder()
        let item = try! #require(order.items.first)

        #expect(throws: OrderRevisionError.orderAlreadyPaid) {
            try useCase.setQuantity(5, of: item, order: order)
        }
    }

    // MARK: R1, R2 — removing a line

    @Test func remove_takesTheLineOffAndFollowsWithTheTotal() throws {
        let staying = makeItem(Menu.cheeseburger, quantity: 1)
        let going = makeItem(Menu.chickenBurger, quantity: 2)
        let order = makeOrder(items: [staying, going])

        try useCase.remove(item: going, order: order)

        #expect(order.items.count == 1)
        #expect(order.items.first?.orderItemID == staying.orderItemID)
        #expect(order.orderTotal == Decimal(9.90))
    }

    @Test func remove_fails_whenTheLineIsNotOnThisOrder() {
        #expect(throws: OrderRevisionError.lineNotInOrder) {
            try useCase.remove(item: makeItem(), order: makeOrder())
        }
    }
}
