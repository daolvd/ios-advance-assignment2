//
//  ConvertTextToOrderUseCaseTests.swift
//  voxPOSTests
//
//  Created by Van Dao Le on 6/9/2026.
//
//  White box, path coverage of ConvertTextToOrderUseCase.execute.
//
//  P1  nothing was said                        -> throws .noTextToInterpret
//  P2  model returns no lines                  -> throws .nothingOrdered
//  P3  line the model itself marks off-menu    -> reported as unmatched
//  P4  name that matches nothing on the menu   -> reported as unmatched
//  P5  product sold out since the prompt       -> reported as unmatched
//  P6  option the kitchen refuses              -> line kept, option reported as an issue
//  P7  every line unmatched                    -> throws .nothingOnTheMenu
//  P8  at least one line matched               -> returns a priced draft order
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

    // MARK: P8 — happy path

    @Test func convertTextToOrder_pricesEveryLineFromTheMenu() async throws {
        let useCase = makeUseCase(returning: [
            makeLine("Classic Cheeseburger", quantity: 2),
            makeLine("Crispy Chicken Burger", quantity: 1, modifiers: ["No Mayonnaise"])
        ])

        let interpreted = try await useCase.execute(text: "two cheeseburgers and a chicken burger", orderNumber: 43)

        #expect(interpreted.order.items.count == 2)
        #expect(interpreted.order.orderTotal == Decimal(30.70))
        #expect(interpreted.order.orderNumber == 43)
        #expect(interpreted.unmatchedItems.isEmpty)
        #expect(interpreted.issues.isEmpty)
    }

    /// The model writes prices happily and gets them wrong. It never touches money.
    @Test func convertTextToOrder_ignoresAnyPriceTheModelMightSuggest() async throws {
        let useCase = makeUseCase(returning: [makeLine("Classic Cheeseburger", quantity: 1)])

        let interpreted = try await useCase.execute(text: "a cheeseburger", orderNumber: 43)

        #expect(interpreted.order.items.first?.unitPrice == Decimal(9.90))
    }

    /// Boundary: the model sometimes writes 0 for "a coffee". A line of nothing
    /// would be cooked and never charged for.
    @Test func convertTextToOrder_treatsAQuantityOfZeroAsOne() async throws {
        let useCase = makeUseCase(returning: [makeLine("Classic Cheeseburger", quantity: 0)])

        let interpreted = try await useCase.execute(text: "a cheeseburger", orderNumber: 43)

        #expect(interpreted.order.items.first?.quantity == 1)
    }

    @Test func convertTextToOrder_matchesProductNamesRegardlessOfCase() async throws {
        let useCase = makeUseCase(returning: [makeLine("classic cheeseburger")])

        let interpreted = try await useCase.execute(text: "a cheeseburger", orderNumber: 43)

        #expect(interpreted.order.items.first?.menuItemID == "01")
    }

    // MARK: P3, P4, P5 — things that cannot be sold

    @Test func convertTextToOrder_reportsWhatTheModelCouldNotPlaceOnTheMenu() async throws {
        let useCase = makeUseCase(returning: [
            makeLine("Classic Cheeseburger"),
            makeLine(InterpretedOrderLine.notOnMenu, customerWords: "an iced tea")
        ])

        let interpreted = try await useCase.execute(text: "a cheeseburger and an iced tea", orderNumber: 43)

        #expect(interpreted.order.items.count == 1)
        #expect(interpreted.unmatchedItems == ["an iced tea"], "in the customer's own words")
    }

    @Test func convertTextToOrder_reportsANameThatMatchesNothingOnTheMenu() async throws {
        let useCase = makeUseCase(returning: [
            makeLine("Classic Cheeseburger"),
            makeLine("Sushi Roll", customerWords: "a sushi roll")
        ])

        let interpreted = try await useCase.execute(text: "a cheeseburger and a sushi roll", orderNumber: 43)

        #expect(interpreted.order.items.count == 1)
        #expect(interpreted.unmatchedItems == ["a sushi roll"])
    }

    @Test func convertTextToOrder_reportsAProductThatSoldOutSinceThePromptWasBuilt() async throws {
        let useCase = makeUseCase(returning: [
            makeLine("Classic Cheeseburger"),
            makeLine("Hot Dog", customerWords: "a hot dog")
        ])

        let interpreted = try await useCase.execute(text: "a cheeseburger and a hot dog", orderNumber: 43)

        #expect(interpreted.order.items.count == 1)
        #expect(interpreted.unmatchedItems == ["a hot dog"])
    }

    // MARK: P6 — an option the kitchen refuses

    @Test func convertTextToOrder_keepsTheLine_butReportsAnOptionTheKitchenCannotMake() async throws {
        let useCase = makeUseCase(returning: [
            makeLine("Crispy Chicken Burger", quantity: 2, modifiers: ["No Cheese"])
        ])

        let interpreted = try await useCase.execute(text: "two chicken burgers without cheese", orderNumber: 43)

        // Losing the option quietly is worse than not hearing it: nobody would know
        // the customer had asked.
        #expect(interpreted.order.items.count == 1)
        #expect(interpreted.order.items.first?.quantity == 2)
        #expect(interpreted.order.items.first?.modifiers.isEmpty == true)
        #expect(interpreted.issues.contains { $0.contains("No Cheese") })
    }

    // MARK: P1, P2, P7 — nothing usable

    @Test func convertTextToOrder_fails_whenThereAreNoWordsToRead() async {
        let useCase = makeUseCase(returning: [makeLine("Classic Cheeseburger")])

        await #expect(throws: OrderInterpretationError.noTextToInterpret) {
            try await useCase.execute(text: "   \n ", orderNumber: 43)
        }
    }

    @Test func convertTextToOrder_fails_whenTheModelFindsNoOrderInTheWords() async {
        let useCase = makeUseCase(returning: [])

        await #expect(throws: OrderInterpretationError.nothingOrdered) {
            try await useCase.execute(text: "hello, nice weather", orderNumber: 43)
        }
    }

    @Test func convertTextToOrder_fails_whenNothingAskedForIsOnTheMenu() async {
        let useCase = makeUseCase(returning: [
            makeLine(InterpretedOrderLine.notOnMenu, customerWords: "an iced tea"),
            makeLine("Hot Dog", customerWords: "a hot dog")
        ])

        await #expect(throws: OrderInterpretationError.nothingOnTheMenu) {
            try await useCase.execute(text: "an iced tea and a hot dog", orderNumber: 43)
        }
    }
}
