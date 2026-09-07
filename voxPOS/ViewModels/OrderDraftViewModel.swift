//
//  OrderDraftViewModel.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import Foundation
import Combine

/// Holds the draft order from the moment it is read out of speech until the staff
/// confirm or cancel it.
///
/// The same draft is shared by the interpreted screen and the review screen, so an
/// edit made while reviewing is the order that gets confirmed.
@MainActor
final class OrderDraftViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case converting
        case ready
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    /// The draft order, once the text has been read.
    private(set) var order: Order?

    /// Things the customer asked for that are not on today's menu.
    private(set) var unmatchedItems: [String] = []

    /// Options the customer asked for that the kitchen cannot make.
    private(set) var issues: [String] = []

    /// Why the last conversion failed, when it did.
    private(set) var failure: OrderInterpretationError?

    /// The most recent payment attempt, once one has been made.
    private(set) var payment: Payment?

    /// Set when a change to the order was refused, for example on a paid order.
    private(set) var editErrorMessage: String?

    private let interpreter: OrderInterpreting
    private var reviseOrder = ReviseOrderUseCase(repository: LocalProductRepository())

    init(interpreter: OrderInterpreting = FoundationModelsOrderInterpreter()) {
        self.interpreter = interpreter
    }

    var items: [OrderItem] {
        order?.items ?? []
    }

    var orderNumber: Int {
        order?.orderNumber ?? 0
    }

    var spokenText: String {
        order?.spokenText ?? ""
    }

    var total: Decimal {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    /// Everything the staff have to be told before they confirm this order.
    var warnings: [String] {
        unmatchedItems.map { "Not on today's menu: \($0)" } + issues
    }

    /// Reading the same words again cannot help when nothing said was on the menu,
    /// or when no order could be found in them. The customer has to order again.
    var needsNewRecording: Bool {
        switch failure {
        case .nothingOnTheMenu, .nothingOrdered, .noTextToInterpret:
            return true
        default:
            return false
        }
    }

    var errorMessage: String? {
        guard case .failed(let message) = state else { return nil }

        return message
    }

    var isReady: Bool {
        state == .ready
    }

    /// Reads an order out of what the customer said.
    ///
    /// - Parameters:
    ///   - text: The customer's words, in the staff's language.
    ///   - repository: Today's menu, which every line is matched against.
    func convert(text: String, repository: ProductRepository) async {
        state = .converting

        reviseOrder = ReviseOrderUseCase(repository: repository)

        let useCase = ConvertTextToOrderUseCase(
            interpreter: interpreter,
            repository: repository
        )

        do {
            let interpreted = try await useCase.execute(
                text: text,
                orderNumber: OrderNumbering.take()
            )

            failure = nil
            order = interpreted.order
            unmatchedItems = interpreted.unmatchedItems
            issues = interpreted.issues
            state = .ready
        } catch {
            failure = error as? OrderInterpretationError
            order = nil
            unmatchedItems = []
            issues = []
            state = .failed(error.localizedDescription)
        }
    }

    /// Opens an empty ticket for an order the staff enter themselves.
    ///
    /// The rules live in ``StartManualOrderUseCase``; this only holds the result and
    /// wires up the same editing rules a spoken order gets.
    func startManualOrder(repository: ProductRepository) {
        guard order == nil else { return }

        reviseOrder = ReviseOrderUseCase(repository: repository)

        do {
            order = try StartManualOrderUseCase(repository: repository)
                .execute(orderNumber: OrderNumbering.take())

            unmatchedItems = []
            issues = []
            failure = nil
            state = .ready
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func increaseQuantity(of item: OrderItem) {
        change { try reviseOrder.setQuantity(item.quantity + 1, of: item, order: $0) }
    }

    /// A line never drops below one, so the button is simply ignored at one.
    func decreaseQuantity(of item: OrderItem) {
        guard item.quantity > 1 else { return }

        change { try reviseOrder.setQuantity(item.quantity - 1, of: item, order: $0) }
    }

    /// Adds a product the staff picked from the menu by hand.
    func add(_ product: Product, quantity: Int, modifiers: [String]) {
        change { try reviseOrder.addItem(product, quantity: quantity, options: modifiers, order: $0) }
    }

    /// Changes the options on a line the staff are editing.
    func setOptions(_ options: [String], of item: OrderItem) {
        change { try reviseOrder.setOptions(options, of: item, order: $0) }
    }

    /// Sets a line's quantity outright, used by the edit sheet.
    func setQuantity(_ quantity: Int, of item: OrderItem) {
        change { try reviseOrder.setQuantity(quantity, of: item, order: $0) }
    }

    func remove(_ item: OrderItem) {
        change { try reviseOrder.remove(item: item, order: $0) }
    }

    /// Records the outcome of a payment attempt so the result screens can show it.
    func recordPayment(_ payment: Payment) {
        objectWillChange.send()
        self.payment = payment
    }

    func cancel() {
        failure = nil
        editErrorMessage = nil
        payment = nil
        order = nil
        unmatchedItems = []
        issues = []
        state = .idle
    }

    /// Runs one change to the order.
    ///
    /// `Order` and `OrderItem` are SwiftData models, so changing them does not
    /// publish on its own — the notice has to be sent by hand, before the change.
    private func change(_ edit: (Order) throws -> Void) {
        guard let order else { return }

        objectWillChange.send()

        do {
            try edit(order)
            editErrorMessage = nil
        } catch {
            editErrorMessage = error.localizedDescription
        }
    }

    // the ordernumeber in range [from 0 to 999]
}
