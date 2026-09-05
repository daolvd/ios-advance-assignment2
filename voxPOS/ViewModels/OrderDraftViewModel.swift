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
            state = .ready
        } catch {
            order = nil
            unmatchedItems = []
            state = .failed(error.localizedDescription)
        }
    }

    func increaseQuantity(of item: OrderItem) {
        setQuantity(item.quantity + 1, on: item)
    }

    func decreaseQuantity(of item: OrderItem) {
        setQuantity(max(item.quantity - 1, 1), on: item)
    }

    func remove(_ item: OrderItem) {
        guard let order else { return }

        objectWillChange.send()
        order.items.removeAll { $0.orderItemID == item.orderItemID }
        order.orderTotal = total
    }

    func cancel() {
        order = nil
        unmatchedItems = []
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
