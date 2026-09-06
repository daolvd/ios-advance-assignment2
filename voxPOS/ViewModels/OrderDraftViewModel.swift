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

    /// The most recent payment attempt, once one has been made.
    private(set) var payment: Payment?

    private let interpreter: OrderInterpreting

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

        let useCase = ConvertTextToOrderUseCase(
            interpreter: interpreter,
            repository: repository
        )

        do {
            let interpreted = try await useCase.execute(
                text: text,
                orderNumber: Self.takeNextOrderNumber()
            )

            order = interpreted.order
            unmatchedItems = interpreted.unmatchedItems
            issues = interpreted.issues
            state = .ready
        } catch {
            order = nil
            unmatchedItems = []
            issues = []
            state = .failed(error.localizedDescription)
        }
    }

    func increaseQuantity(of item: OrderItem) {
        setQuantity(item.quantity + 1, on: item)
    }

    func decreaseQuantity(of item: OrderItem) {
        setQuantity(max(item.quantity - 1, 1), on: item)
    }

    /// Adds a product the staff picked from the menu by hand.
    ///
    /// An identical line — same product, same options — has its quantity raised
    /// instead of appearing twice on the ticket.
    func add(_ product: Product, quantity: Int, modifiers: [String]) {
        guard let order, quantity > 0 else { return }

        objectWillChange.send()

        let allowed = modifiers.filter(product.allowModifier.contains)

        if let existing = order.items.first(where: {
            $0.menuItemID == product.id && $0.modifiers == allowed
        }) {
            existing.quantity += quantity
            existing.lineTotal = existing.unitPrice * Decimal(existing.quantity)
        } else {
            order.items.append(
                OrderItem(
                    menuItemID: product.id,
                    itemName: product.title,
                    quantity: quantity,
                    modifiers: allowed,
                    // The price comes from the menu, the same as a spoken line.
                    unitPrice: product.price
                )
            )
        }

        order.orderTotal = total
    }

    func remove(_ item: OrderItem) {
        guard let order else { return }

        objectWillChange.send()
        order.items.removeAll { $0.orderItemID == item.orderItemID }
        order.orderTotal = total
    }

    /// Records the outcome of a payment attempt so the result screens can show it.
    func recordPayment(_ payment: Payment) {
        objectWillChange.send()
        self.payment = payment
    }

    func cancel() {
        payment = nil
        order = nil
        unmatchedItems = []
        issues = []
        state = .idle
    }

    private func setQuantity(_ quantity: Int, on item: OrderItem) {
        objectWillChange.send()

        item.quantity = quantity
        item.lineTotal = item.unitPrice * Decimal(quantity)
        order?.orderTotal = total
    }

    private static func takeNextOrderNumber() -> Int {
        let defaults = UserDefaults.standard
        let key = "voxPOS.nextOrderNumber"
        let next = max(defaults.integer(forKey: key), 43)

        defaults.set(next + 1, forKey: key)

        return next
    }
}
