//
//  TakePaymentUseCaseTests.swift
//  voxPOSTests
//
//  Verifies TakePaymentUseCase against the rules of taking money for an order.
//
//  HAPPY PATH   cash is approved without a terminal, and closes the order
//  BOUNDARY     a total of exactly zero is not something to charge for
//  ERROR CASES  .emptyOrder · .alreadyPaid · .terminalUnavailable
//               · .couldNotRecordAttempt
//               plus the declined outcome, which is not an error at all
//

import Testing
import Foundation
@testable import voxPOS

struct TakePaymentUseCaseTests {

    private func makeUseCase(
        repository: StubPaymentRepository = StubPaymentRepository(),
        terminal: StubPaymentTerminal = StubPaymentTerminal()
    ) -> TakePaymentUseCase {
        TakePaymentUseCase(repository: repository, terminal: terminal)
    }

    // MARK: - Happy path

    @Test func takePayment_approvesCashWithoutAskingATerminal() async throws {
        let repository = StubPaymentRepository()
        var terminal = StubPaymentTerminal()
        terminal.outcome = .failure(StubPaymentTerminal.OutOfOrder())

        let order = makeOrder(items: [makeItem(Menu.cheeseburger, quantity: 2)])

        // The staff member has the notes in hand, so a broken terminal is irrelevant.
        let payment = try await makeUseCase(repository: repository, terminal: terminal)
            .execute(order: order, method: .cash)

        #expect(payment.status == .approved)
        #expect(payment.amount == Decimal(19.80))
        #expect(order.status == "paid")
        #expect(order.confirmedAt != nil)
    }

    // MARK: - A decline is an outcome, not an error

    @Test func takePayment_returnsADeclinedAttempt_andLeavesTheOrderOpen() async throws {
        let repository = StubPaymentRepository()
        var terminal = StubPaymentTerminal()
        terminal.outcome = .success(.declined)

        let order = makeOrder(items: [makeItem(Menu.cheeseburger)])

        let payment = try await makeUseCase(repository: repository, terminal: terminal)
            .execute(order: order, method: .card)

        #expect(payment.status == .declined)
        #expect(order.status != "paid", "a declined card must not close the order")
        #expect(repository.recorded.count == 1, "a decline is still written down")
    }

    /// A shift cannot be reconciled from approvals alone: an order paid on the
    /// second try must not look like it was only ever paid once.
    @Test func takePayment_recordsBothTheDeclineAndTheApprovalThatFollowsIt() async throws {
        let repository = StubPaymentRepository()
        var declining = StubPaymentTerminal()
        declining.outcome = .success(.declined)

        let order = makeOrder(items: [makeItem(Menu.cheeseburger)])

        _ = try await makeUseCase(repository: repository, terminal: declining)
            .execute(order: order, method: .card)
        _ = try await makeUseCase(repository: repository).execute(order: order, method: .cash)

        #expect(repository.recorded.map(\.status) == [.declined, .approved])
    }

    // MARK: - Boundary

    /// Exactly zero is the line between something to charge for and nothing.
    @Test func takePayment_fails_whenTheTotalIsExactlyZero() async {
        let free = Product(id: "00", title: "Classic Cheeseburger", isAvailable: true, price: 0)
        let order = makeOrder(items: [makeItem(free, quantity: 2)])

        await #expect(throws: PaymentError.nothingToCharge) {
            try await makeUseCase().execute(order: order, method: .cash)
        }
    }

    // MARK: - Error cases

    @Test func takePayment_fails_whenTheOrderHasNoLines() async {
        await #expect(throws: PaymentError.emptyOrder) {
            try await makeUseCase().execute(order: makeOrder(), method: .cash)
        }
    }

    @Test func takePayment_fails_whenTheOrderHasAlreadyBeenPaidFor() async throws {
        let repository = StubPaymentRepository()
        let order = makeOrder(items: [makeItem(Menu.cheeseburger)])

        _ = try await makeUseCase(repository: repository).execute(order: order, method: .cash)

        await #expect(throws: PaymentError.alreadyPaid) {
            try await makeUseCase(repository: repository).execute(order: order, method: .card)
        }

        #expect(repository.recorded.count == 1, "the customer must not be charged twice")
    }

    @Test func takePayment_fails_whenTheCardTerminalCannotBeReached() async {
        var terminal = StubPaymentTerminal()
        terminal.outcome = .failure(StubPaymentTerminal.OutOfOrder())

        let order = makeOrder(items: [makeItem(Menu.cheeseburger)])

        await #expect(throws: PaymentError.self) {
            try await makeUseCase(terminal: terminal).execute(order: order, method: .card)
        }
    }

    @Test func takePayment_fails_whenTheAttemptCannotBeWrittenDown() async {
        let repository = StubPaymentRepository()
        repository.recordingSucceeds = false

        let order = makeOrder(items: [makeItem(Menu.cheeseburger)])

        // Better to refuse than to take money nobody can account for afterwards.
        await #expect(throws: PaymentError.couldNotRecordAttempt) {
            try await makeUseCase(repository: repository).execute(order: order, method: .cash)
        }

        #expect(order.status != "paid")
    }
}
