//
//  OrderCompleteUIView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI
import Lottie

struct OrderCompleteUiView: View {

    @EnvironmentObject private var draft: OrderDraftViewModel
    @EnvironmentObject private var router: OrderFlowRouter

    /// Staff are usually mid-queue, so the till returns to a new order on its own.
    @State private var secondsLeft = 6

    var body: some View {
           VStack(spacing: 0) {

               Spacer()
                   .frame(height: 110)

               LottieView(animation: .named("success"))
                   .playing(loopMode: .playOnce)
                   .resizable()
                   .scaledToFit()
                   .frame(width: 120, height: 120)

               Text("PAYMENT COMPLETE")
                   .font(.caption.bold())
                   .foregroundStyle(.green)
                   .padding(.top, 30)

               Text("#\(draft.orderNumber)")
                   .font(.system(size: 58, weight: .bold))
                   .padding(.top, 18)

               Text("Paid \(paidAmount) · \(paidMethod)")
                   .font(.headline)
                   .foregroundStyle(.secondary)
                   .padding(.top, 14)

               Text("Returning to new order in \(secondsLeft) second\(secondsLeft == 1 ? "" : "s")")
                   .font(.subheadline)
                   .foregroundStyle(.secondary)
                   .padding(.top, 34)

               Spacer()

               Button(action: {
                   router.closeFlow()
               }) {
                   Text("New Order")
                       .font(.headline)
                       .foregroundStyle(.white)
                       .frame(maxWidth: .infinity)
                       .frame(height: 56)
                       .background(Color.blue)
                       .clipShape(RoundedRectangle(cornerRadius: 14))
               }
           }
           .padding(.horizontal, 24)
           .padding(.bottom, 70)
           .background(Color(.systemBackground))
           .navigationBarBackButtonHidden()
           .task {
               while secondsLeft > 0 {
                   try? await Task.sleep(for: .seconds(1))

                   guard !Task.isCancelled else { return }
                   secondsLeft -= 1
               }

               router.closeFlow()
           }
       }

    private var paidAmount: String {
        (draft.payment?.amount ?? draft.total).formatted(.currency(code: "AUD"))
    }

    private var paidMethod: String {
        draft.payment?.paymentMethod.displayName ?? ""
    }
   }

#Preview {
    NavigationStack {
        OrderCompleteUiView()
    }
    .environmentObject(OrderDraftViewModel())
    .environmentObject(OrderFlowRouter())
}
