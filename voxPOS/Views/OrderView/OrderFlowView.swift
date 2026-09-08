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

    /// Where the order comes from. Both kinds share every screen after the first.
    enum Start {
        case spokenOrder
        case manualOrder
    }

    @Binding var isPresented: Bool
    var start: Start = .spokenOrder

    @EnvironmentObject private var productViewModel: ProductViewModel

    @StateObject private var draft = OrderDraftViewModel()
    @StateObject private var router = OrderFlowRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                switch start {
                case .spokenOrder:
                    VoiceOrderUiView()
                case .manualOrder:
                    ReviewEditUiView(draft: draft)
                }
            }
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

            if start == .manualOrder {
                draft.startManualOrder(repository: productViewModel.repository)
            }
        }
    }
}
