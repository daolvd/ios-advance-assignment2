//
//  OrderFlowView.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import SwiftUI

/// Holds one order from the first word spoken until it is paid for or abandoned.
///
/// The draft and the path live here rather than in any one screen, so every screen
/// edits the same order and any of them can send the staff back to the start.
struct OrderFlowView: View {

    @Binding var isPresented: Bool

    @StateObject private var draft = OrderDraftViewModel()
    @StateObject private var router = OrderFlowRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            VoiceOrderUiView()
                .navigationDestination(for: OrderFlowStep.self) { step in
                    switch step {
                    case .interpretedOrder:
                        InterpretedOrderUiView(draft: draft)
                    case .reviewOrder:
                        ReviewEditUiView(draft: draft)
                    case .customerCheck:
                        CustomerCheckUiView()
                    case .payment:
                        PaymentMethodUiView()
                    case .paymentComplete:
                        OrderCompleteUiView()
                    case .paymentFailed:
                        PaymentFailedUiView()
                    }
                }
        }
        .environmentObject(draft)
        .environmentObject(router)
        .onAppear {
            router.closeFlow = { isPresented = false }
        }
    }
}
