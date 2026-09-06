//
//  PaymentRepositoryEnvironment.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import SwiftUI

extension EnvironmentValues {
    /// Payment attempts are kept for the whole shift, not just one order, so the
    /// store is injected once at the root rather than created per order.
    @Entry var paymentRepository: PaymentRepository = LocalPaymentRepository()
}
