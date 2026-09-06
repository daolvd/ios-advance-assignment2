//
//  TakePaymentUseCaseTests.swift
//  voxPOSTests
//
//  Created by Van Dao Le on 6/9/2026.
//
//  White box, path coverage of TakePaymentUseCase.execute.
//
//  P1  order has no lines               -> throws .emptyOrder
//  P2  lines add up to nothing          -> throws .nothingToCharge
//  P3  order already paid for           -> throws .alreadyPaid
//  P4  cash                             -> approved without a terminal
//  P5  card, terminal approves          -> approved
//  P6  card, terminal declines          -> returns a declined attempt, order stays open
//  P7  card, terminal unreachable       -> throws .terminalUnavailable
//  P8  attempt cannot be written down   -> throws .couldNotRecordAttempt
//
//  Boundary: a total of exactly zero is refused (P2); anything above it is charged.
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

    // MARK: P4 — cash

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
        #expect(repository.recorded.count == 1)
    }

    // MARK: P5 — card approved

    @Test func takePayment_approvesCard_whenTheTerminalApproves() async throws {
        let order = makeOrder(items: [makeItem(Menu.cheeseburger)])

        let payment = try await makeUseCase().execute(order: order, method: .card)

        #expect(payment.status == .approved)
        #expect(payment.paymentMethod == .card)
        #expect(order.status == "paid")
    }

    // MARK: P6 — card declined

    @Test func takePayment_returnsADeclinedAttempt_andLeavesTheOrderOpen() async throws {
        let repository = StubPaymentRepository()
        var terminal = StubPaymentTerminal()
        terminal.outcome = .success(.declined)

        let order = makeOrder(items: [makeItem(Menu.cheeseburger)])

        // A decline is an ordinary outcome: the staff offer another method.
        let payment = try await makeUseCase(repository: repository, terminal: terminal)
            .execute(order: order, method: .card)

        #expect(payment.status == .declined)
        #expect(order.status != "paid", "a declined card must not close the order")
        #expect(repository.recorded.count == 1, "a decline is still written down")
    }

    /// A shift cannot be reconciled unless every attempt is on record, so an order
    /// paid on the second try must not look like it was only ever paid once.
    @Test func takePayment_recordsBothTheDeclineAndTheApprovalThatFollowsIt() async throws {
        let repository = StubPaymentRepository()
        var declining = StubPaymentTerminal()
        declining.outcome = .success(.declined)

        let order = makeOrder(items: [makeItem(Menu.cheeseburger)])

        _ = try await makeUseCase(repository: repository, terminal: declining)
            .execute(order: order, method: .card)
        _ = try await makeUseCase(repository: repository)
            .execute(order: order, method: .cash)

        #expect(repository.recorded.count == 2)
        #expect(repository.recorded.map(\.status) == [.declined, .approved])
    }

    // MARK: P1, P2 — nothing to charge

    @Test func takePayment_fails_whenTheOrderHasNoLines() async {
        await #expect(throws: PaymentError.emptyOrder) {
            try await makeUseCase().execute(order: makeOrder(), method: .cash)
        }
    }

    /// Boundary: a total of exactly zero is not something to charge for.
    @Test func takePayment_fails_whenTheTotalIsZero() async {
        let free = Product(id: "00", title: "Classic Cheeseburger", isAvailable: true, price: 0)
        let order = makeOrder(items: [makeItem(free, quantity: 2)])

        await #expect(throws: PaymentError.nothingToCharge) {
            try await makeUseCase().execute(order: order, method: .cash)
        }
    }

    // MARK: P3 — paying twice

    @Test func takePayment_fails_whenTheOrderHasAlreadyBeenPaidFor() async throws {
        let repository = StubPaymentRepository()
        let order = makeOrder(items: [makeItem(Menu.cheeseburger)])

        _ = try await makeUseCase(repository: repository).execute(order: order, method: .cash)

        await #expect(throws: PaymentError.alreadyPaid) {
            try await makeUseCase(repository: repository).execute(order: order, method: .card)
        }

        #expect(repository.recorded.count == 1, "the customer must not be charged twice")
    }

    // MARK: P7 — the terminal

    @Test func takePayment_fails_whenTheCardTerminalCannotBeReached() async {
        var terminal = StubPaymentTerminal()
        terminal.outcome = .failure(StubPaymentTerminal.OutOfOrder())

        let order = makeOrder(items: [makeItem(Menu.cheeseburger)])

        await #expect(throws: PaymentError.self) {
            try await makeUseCase(terminal: terminal).execute(order: order, method: .card)
        }
    }

    // MARK: P8 — the record

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
