//
//  PaymentRepository.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation

protocol PaymentRepository {
    func paymentHistory() -> [Payment]
    func approvedPayment(orderID: String) -> Payment?
    func recordPaymentAttempt(_ payment: Payment) throws
}
