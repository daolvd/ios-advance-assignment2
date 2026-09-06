//
//  PaymentAuthorizing.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import Foundation

/// Asks for the money.
///
/// Cash never reaches here — the staff member takes the notes themselves. Card and
/// QR go to a terminal, which is the only part that can decline.
protocol PaymentAuthorizing {
    func authorize(amount: Decimal, method: PaymentMethod) async throws -> PaymentStatus
}

/// Stands in for a real card terminal until one is connected.
///
/// It approves everything after a short wait. Set ``declines`` to walk through the
/// declined path on screen.
struct SimulatedPaymentTerminal: PaymentAuthorizing {

    var declines = false

    func authorize(amount: Decimal, method: PaymentMethod) async throws -> PaymentStatus {
        // A terminal takes a moment, and the screen has to show that.
        try await Task.sleep(for: .seconds(1))

        return declines ? .declined : .approved
    }
}
