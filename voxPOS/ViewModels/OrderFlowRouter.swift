//
//  OrderFlowRouter.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import Foundation
import Combine

/// The screens a staff member walks through after speaking an order.
enum OrderFlowStep: Hashable {
    case interpretedOrder
    case reviewOrder
    case customerCheck
    case payment
    case paymentComplete
    case paymentFailed
}

/// Drives the order screens.
///
/// The whole flow shares one path, so a screen deep in it can send the staff back to
/// the start — which is what "New Order" has to do after payment, rather than making
/// them tap Back four times.
@MainActor
final class OrderFlowRouter: ObservableObject {

    @Published var path: [OrderFlowStep] = []

    /// Closes the order flow entirely and returns to the till's home screen.
    var closeFlow: () -> Void = {}

    func push(_ step: OrderFlowStep) {
        path.append(step)
    }

    func back() {
        guard !path.isEmpty else { return }

        path.removeLast()
    }

    /// Returns to the screen where the staff can still change the order.
    func backToReview() {
        guard let index = path.firstIndex(of: .reviewOrder) else {
            path.removeAll()
            return
        }

        path.removeSubrange((index + 1)...)
    }
}
