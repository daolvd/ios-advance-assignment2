//
//  StartManualOrderUseCaseTests.swift
//  voxPOSTests
//
//  Created by Van Dao Le on 6/9/2026.
//
//  White box, path coverage of StartManualOrderUseCase.execute.
//
//  P1  menu has nothing on sale   -> throws .nothingAvailableToSell
//  P2  menu has something on sale -> returns an empty draft carrying the number
//
//  Boundary: one product still on sale is enough to open a ticket, even when the
//  rest of the menu is sold out.
//

import Testing
import Foundation
@testable import voxPOS

struct StartManualOrderUseCaseTests {

    // MARK: P2 — happy path

    @Test func startManualOrder_opensAnEmptyTicketWithTheGivenNumber() throws {
        let useCase = StartManualOrderUseCase(repository: Menu.repository())

        let order = try useCase.execute(orderNumber: 91)

        #expect(order.orderNumber == 91)
        #expect(order.items.isEmpty, "the staff add the first line themselves")
        #expect(order.orderTotal == 0)
        #expect(order.status == "draft", "nothing is owed until a line exists")
    }

    /// A hand-written order is an ordinary order: the same editing rules apply to it
    /// from its first line onward.
    @Test func startManualOrder_producesATicketTheOrdinaryEditingRulesAccept() throws {
        let repository = Menu.repository()
        let order = try StartManualOrderUseCase(repository: repository).execute(orderNumber: 91)

        try ReviseOrderUseCase(repository: repository)
            .addItem(Menu.cheeseburger, quantity: 2, options: ["Add Bacon"], order: order)

        #expect(order.items.count == 1)
        #expect(order.orderTotal == Decimal(19.80), "priced from the menu, as always")
    }

    /// Boundary: one product left on sale is enough.
    @Test func startManualOrder_opensATicket_whenOnlyOneProductIsLeftOnSale() throws {
        let repository = Menu.repository([Menu.cheeseburger, Menu.soldOutHotDog])

        let order = try StartManualOrderUseCase(repository: repository).execute(orderNumber: 91)

        #expect(order.orderNumber == 91)
    }

    // MARK: P1 — nothing to sell

    @Test func startManualOrder_fails_whenEveryProductIsSoldOut() {
        let useCase = StartManualOrderUseCase(repository: Menu.repository([Menu.soldOutHotDog]))

        // Numbering a ticket that can never hold a line leaves a gap in the day's
        // order numbers that nobody can account for afterwards.
        #expect(throws: ManualOrderError.nothingAvailableToSell) {
            try useCase.execute(orderNumber: 91)
        }
    }

    @Test func startManualOrder_fails_whenTheMenuIsEmpty() {
        let useCase = StartManualOrderUseCase(repository: Menu.repository([]))

        #expect(throws: ManualOrderError.nothingAvailableToSell) {
            try useCase.execute(orderNumber: 91)
        }
    }
}
