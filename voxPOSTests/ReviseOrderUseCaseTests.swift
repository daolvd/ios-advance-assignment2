//
//  ReviseOrderUseCaseTests.swift
//  voxPOSTests
//
//  Verifies ReviseOrderUseCase against the rules of changing an order the staff
//  and the customer are still agreeing on.
//
//  HAPPY PATH   priced from the menu; an identical line is merged, not repeated
//  BOUNDARY     one is the smallest a line may be — 1 is allowed, 0 is refused
//  ERROR CASES  .orderAlreadyPaid · .soldOut · .notOnTheMenu · .lineNotInOrder
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

    // MARK: - Happy path

    @Test func addItem_pricesTheLineFromTheMenu_notFromTheCaller() throws {
        let order = makeOrder()

        // A caller holding a stale product with the wrong price must not set it.
        var stale = Menu.cheeseburger
        stale.price = 0.01

        try useCase.addItem(stale, quantity: 2, options: [], order: order)

        #expect(order.items.first?.unitPrice == Decimal(9.90))
        #expect(order.orderTotal == Decimal(19.80))
    }

    @Test func addItem_raisesTheQuantity_whenTheSameLineIsAlreadyOnTheOrder() throws {
        let order = makeOrder()

        try useCase.addItem(Menu.cheeseburger, quantity: 2, options: ["Add Bacon"], order: order)
        try useCase.addItem(Menu.cheeseburger, quantity: 1, options: ["Add Bacon"], order: order)

        // A cook should never be handed the same item on two lines and asked to add up.
        #expect(order.items.count == 1)
        #expect(order.items.first?.quantity == 3)
    }

    @Test func addItem_keepsOnlyOptionsTheKitchenCanMake_andReportsTheRest() throws {
        let order = makeOrder()

        let added = try useCase.addItem(
            Menu.chickenBurger, quantity: 1, options: ["No Mayonnaise", "No Cheese"], order: order
        )

        #expect(added.line.modifiers == ["No Mayonnaise"])
        #expect(added.droppedOptions == ["No Cheese"], "the staff must be told what was left out")
    }

    // MARK: - Boundary: one is the smallest a line may be

    @Test func setQuantity_allowsALineOfExactlyOne() throws {
        let item = makeItem(Menu.cheeseburger, quantity: 2)
        let order = makeOrder(items: [item])

        try useCase.setQuantity(1, of: item, order: order)

        #expect(item.quantity == 1)
    }

    @Test func setQuantity_fails_whenQuantityIsBelowOne() {
        let item = makeItem(Menu.cheeseburger, quantity: 2)
        let order = makeOrder(items: [item])

        #expect(throws: OrderRevisionError.quantityBelowOne) {
            try useCase.setQuantity(0, of: item, order: order)
        }

        #expect(item.quantity == 2, "a refused change must leave the line alone")
    }

    // MARK: - Error cases

    @Test func addItem_fails_whenTheOrderHasBeenPaidFor() {
        // Editing a paid order leaves the money taken and the ticket disagreeing.
        #expect(throws: OrderRevisionError.orderAlreadyPaid) {
            try useCase.addItem(Menu.cheeseburger, quantity: 1, options: [], order: paidOrder())
        }
    }

    @Test func addItem_fails_whenTheProductIsSoldOut() {
        #expect(throws: OrderRevisionError.soldOut(product: "Hot Dog")) {
            try useCase.addItem(Menu.soldOutHotDog, quantity: 1, options: [], order: makeOrder())
        }
    }

    @Test func addItem_fails_whenTheProductIsNotOnTodaysMenu() {
        let sushi = Product(id: "99", title: "Sushi", isAvailable: true, price: 12)

        #expect(throws: OrderRevisionError.notOnTheMenu(product: "Sushi")) {
            try useCase.addItem(sushi, quantity: 1, options: [], order: makeOrder())
        }
    }

    @Test func remove_fails_whenTheLineIsNotOnThisOrder() {
        #expect(throws: OrderRevisionError.lineNotInOrder) {
            try useCase.remove(item: makeItem(), order: makeOrder())
        }
    }
}
