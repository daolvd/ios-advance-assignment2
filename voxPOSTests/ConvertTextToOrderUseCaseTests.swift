//
//  ConvertTextToOrderUseCaseTests.swift
//  voxPOSTests
//
//  Verifies ConvertTextToOrderUseCase against the rules that turn spoken words
//  into a ticket that can be charged for.
//
//  HAPPY PATH   every line is priced from the menu, never from the model
//  BOUNDARY     a quantity of 0 becomes 1 — the smallest a line may be
//  ERROR CASES  .noTextToInterpret · .nothingOrdered · .nothingOnTheMenu
//               plus the two ways a request is reported rather than sold
//
//  These tests never call the model. They pin down what the app does with whatever
//  the model returns, including the nonsense it sometimes returns.
//

import Testing
import Foundation
@testable import voxPOS

struct ConvertTextToOrderUseCaseTests {

    private func makeUseCase(returning lines: [InterpretedOrderLine]) -> ConvertTextToOrderUseCase {
        ConvertTextToOrderUseCase(
            interpreter: StubOrderInterpreter(lines: lines),
            repository: Menu.repository()
        )
    }

    // MARK: - Happy path

    @Test func convertTextToOrder_pricesEveryLineFromTheMenu() async throws {
        let useCase = makeUseCase(returning: [
            makeLine("Classic Cheeseburger", quantity: 2),
            makeLine("Crispy Chicken Burger", quantity: 1, modifiers: ["No Mayonnaise"])
        ])

        let interpreted = try await useCase.execute(text: "two cheeseburgers and a chicken burger", orderNumber: 43)

        // A language model writes plausible numbers. It never sets one here.
        #expect(interpreted.order.items.count == 2)
        #expect(interpreted.order.orderTotal == Decimal(30.70))
        #expect(interpreted.unmatchedItems.isEmpty)
        #expect(interpreted.issues.isEmpty)
    }

    // MARK: - Boundary

    /// The model sometimes writes 0 for "a coffee". A line of nothing would be
    /// cooked and never charged for.
    @Test func convertTextToOrder_treatsAQuantityOfZeroAsOne() async throws {
        let useCase = makeUseCase(returning: [makeLine("Classic Cheeseburger", quantity: 0)])

        let interpreted = try await useCase.execute(text: "a cheeseburger", orderNumber: 43)

        #expect(interpreted.order.items.first?.quantity == 1)
    }

    // MARK: - Reported rather than sold

    @Test func convertTextToOrder_reportsWhatIsNotOnTodaysMenu() async throws {
        let useCase = makeUseCase(returning: [
            makeLine("Classic Cheeseburger"),
            makeLine(InterpretedOrderLine.notOnMenu, customerWords: "an iced tea"),
            makeLine("Hot Dog", customerWords: "a hot dog")
        ])

        let interpreted = try await useCase.execute(text: "a cheeseburger, an iced tea and a hot dog", orderNumber: 43)

        // One is off the menu entirely, one is on it but sold out. Both come back in
        // the customer's own words, so the staff can say what they could not sell.
        #expect(interpreted.order.items.count == 1)
        #expect(interpreted.unmatchedItems == ["an iced tea", "a hot dog"])
    }

    @Test func convertTextToOrder_keepsTheLine_butReportsAnOptionTheKitchenCannotMake() async throws {
        let useCase = makeUseCase(returning: [
            makeLine("Crispy Chicken Burger", quantity: 2, modifiers: ["No Cheese"])
        ])

        let interpreted = try await useCase.execute(text: "two chicken burgers without cheese", orderNumber: 43)

        // Losing the option quietly is worse than not hearing it: nobody would know
        // the customer had asked. A bad option costs that option, not the order.
        #expect(interpreted.order.items.first?.quantity == 2)
        #expect(interpreted.order.items.first?.modifiers.isEmpty == true)
        #expect(interpreted.issues.contains { $0.contains("No Cheese") })
    }

    // MARK: - Error cases

    @Test func convertTextToOrder_fails_whenThereAreNoWordsToRead() async {
        await #expect(throws: OrderInterpretationError.noTextToInterpret) {
            try await makeUseCase(returning: [makeLine("Classic Cheeseburger")])
                .execute(text: "   \n ", orderNumber: 43)
        }
    }

    @Test func convertTextToOrder_fails_whenTheModelFindsNoOrderInTheWords() async {
        await #expect(throws: OrderInterpretationError.nothingOrdered) {
            try await makeUseCase(returning: []).execute(text: "hello, nice weather", orderNumber: 43)
        }
    }

    @Test func convertTextToOrder_fails_whenNothingAskedForIsOnTheMenu() async {
        let useCase = makeUseCase(returning: [
            makeLine(InterpretedOrderLine.notOnMenu, customerWords: "an iced tea")
        ])

        await #expect(throws: OrderInterpretationError.nothingOnTheMenu) {
            try await useCase.execute(text: "an iced tea", orderNumber: 43)
        }
    }
}
