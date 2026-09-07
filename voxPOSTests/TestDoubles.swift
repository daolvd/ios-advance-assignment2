//
//  TestDoubles.swift
//  voxPOSTests
//
//  Created by Van Dao Le on 6/9/2026.
//
//  Stand-ins for everything the use cases talk to, plus small builders so each test
//  states only the thing it is about. Nothing here touches UserDefaults, the disk,
//  the microphone or the on-device model: a use case test must fail because a rule
//  is wrong, never because a device was busy.
//

import Foundation
@testable import voxPOS

// MARK: - Staff

final class StubStaffRepository: StaffRepository {

    /// Set false to stand in for a device that cannot store the shift.
    var saveSucceeds = true

    private(set) var savedStaff: Staff?
    private(set) var clearSessionCallCount = 0

    func saveSession(staff: Staff) -> Bool {
        guard saveSucceeds else { return false }

        savedStaff = staff
        return true
    }

    func loadSession() -> Staff? { savedStaff }

    func clearSession() {
        savedStaff = nil
        clearSessionCallCount += 1
    }
}

// MARK: - Speech

struct StubTranscriber: SpeechTranscribing {
    var result: Result<SpeechTranscription, Error>

    init(hears text: String, confidence: Double = 0.9) {
        result = .success(SpeechTranscription(text: text, confidence: confidence))
    }

    init(failsWith error: Error) {
        result = .failure(error)
    }

    func transcribe() async throws -> SpeechTranscription { try result.get() }
    func stopListening() {}
}

struct StubLanguageDetector: LanguageDetecting {
    var language: DetectedLanguage?

    func detectLanguage(of text: String) -> DetectedLanguage? { language }
}

final class StubTranslator: TextTranslating, @unchecked Sendable {
    private let translation: String?
    private(set) var receivedText: String?

    init(returns translation: String?) {
        self.translation = translation
    }

    struct Unavailable: Error {}

    func translate(_ text: String, from: String, to: String) async throws -> String {
        receivedText = text

        guard let translation else { throw Unavailable() }

        return translation
    }
}

// MARK: - Products

final class StubProductRepository: ProductRepository {
    private(set) var products: [Product]

    init(products: [Product]) { self.products = products }

    func load() -> [Product] { products }
    func add(_ product: Product) { products.append(product) }
    func update(_ product: Product) {}
    func delete(_ product: Product) {}
}

struct StubOrderInterpreter: OrderInterpreting {
    var lines: [InterpretedOrderLine]

    func interpret(text: String, menu: [Product]) async throws -> [InterpretedOrderLine] { lines }
}

// MARK: - Payment

final class StubPaymentRepository: PaymentRepository {

    /// Set false to stand in for a store that cannot write the attempt down.
    var recordingSucceeds = true

    private(set) var recorded: [Payment] = []

    struct CouldNotWrite: Error {}

    func paymentHistory() -> [Payment] { recorded }

    func approvedPayment(orderID: String) -> Payment? {
        recorded.first { $0.orderID == orderID && $0.status == .approved }
    }

    func recordPaymentAttempt(_ payment: Payment) throws {
        guard recordingSucceeds else { throw CouldNotWrite() }

        recorded.append(payment)
    }
}

struct StubPaymentTerminal: PaymentAuthorizing {
    var outcome: Result<PaymentStatus, Error> = .success(.approved)

    struct OutOfOrder: Error {}

    func authorize(amount: Decimal, method: PaymentMethod) async throws -> PaymentStatus {
        try outcome.get()
    }
}

// MARK: - Builders

enum Menu {

    static let cheeseburger = Product(
        id: "01",
        title: "Classic Cheeseburger",
        isAvailable: true,
        price: 9.90,
        allowModifier: ["No Cheese", "Add Bacon"]
    )

    static let chickenBurger = Product(
        id: "02",
        title: "Crispy Chicken Burger",
        isAvailable: true,
        price: 10.90,
        allowModifier: ["No Mayonnaise"]
    )

    static let soldOutHotDog = Product(
        id: "07",
        title: "Hot Dog",
        isAvailable: false,
        price: 7.90,
        allowModifier: ["No Ketchup"]
    )

    static let all = [cheeseburger, chickenBurger, soldOutHotDog]

    static func repository(_ products: [Product] = all) -> StubProductRepository {
        StubProductRepository(products: products)
    }
}

func makeOrder(number: Int = 43, items: [OrderItem] = []) -> Order {
    let order = Order(orderNumber: number)
    order.items = items
    order.orderTotal = items.reduce(0) { $0 + $1.lineTotal }

    return order
}

func makeItem(
    _ product: Product = Menu.cheeseburger,
    quantity: Int = 1,
    modifiers: [String] = []
) -> OrderItem {
    OrderItem(
        menuItemID: product.id,
        itemName: product.title,
        quantity: quantity,
        modifiers: modifiers,
        unitPrice: product.price
    )
}

func makeLine(
    _ name: String,
    quantity: Int = 1,
    modifiers: [String] = [],
    customerWords: String = "what the customer said"
) -> InterpretedOrderLine {
    InterpretedOrderLine(
        productName: name,
        customerWords: customerWords,
        quantity: quantity,
        modifiers: modifiers
    )
}
