//
//  LocalPaymentRepositoy.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

/// Keeps this shift's payment attempts in memory.
///
/// Attempts are lost when the app quits. That is acceptable while orders are not
/// stored either; both move together when SwiftData is turned on.
class LocalPaymentRepository : PaymentRepository {

    private var payments: [Payment] = []

    func paymentHistory() -> [Payment] {
        payments
    }

    func approvedPayment(orderID: String) -> Payment? {
        payments.first { $0.orderID == orderID && $0.status == .approved }
    }

    func recordPaymentAttempt(_ payment: Payment) throws {
        payments.append(payment)
    }
}
