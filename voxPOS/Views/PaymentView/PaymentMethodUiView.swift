//
//  PaymentMethodUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct PaymentMethodUiView: View {

    @EnvironmentObject private var draft: OrderDraftViewModel
    @EnvironmentObject private var router: OrderFlowRouter
    @Environment(\.paymentRepository) private var paymentRepository

    var body: some View {
           VStack(alignment: .leading, spacing: 0) {


               Text("Payment")
                   .font(.title.bold())
                   .padding(.top, 24)

               Text("Order #\(draft.orderNumber)")
                   .font(.body)
                   .foregroundStyle(.secondary)
                   .padding(.top, 4)

               Text("AMOUNT DUE")
                   .font(.caption.bold())
                   .foregroundStyle(.secondary)
                   .padding(.top, 56)

               Text(draft.total, format: .currency(code: "AUD"))
                   .font(.system(size: 42, weight: .bold))
                   .frame(maxWidth: .infinity)
                   .padding(.top, 10)

               Text("Choose a payment method")
                   .font(.subheadline.bold())
                   .foregroundStyle(.secondary)
                   .frame(maxWidth: .infinity)
                   .padding(.top, 44)

               Button(action: {
                   take(.cash)
               }) {
                   Text("Cash")
                       .font(.headline)
                       .foregroundStyle(.primary)
                       .frame(maxWidth: .infinity)
                       .frame(height: 56)
                       .background(Color(.systemBackground))
                       .clipShape(RoundedRectangle(cornerRadius: 14))
                       .overlay {
                           RoundedRectangle(cornerRadius: 14)
                               .stroke(Color(.separator), lineWidth: 1)
                       }
               }
               .buttonStyle(.plain)
               .padding(.top, 28)

               Button(action: {
                   take(.card)
               }) {
                   Text("Card")
                       .font(.headline)
                       .foregroundStyle(.primary)
                       .frame(maxWidth: .infinity)
                       .frame(height: 56)
                       .background(Color(.systemBackground))
                       .clipShape(RoundedRectangle(cornerRadius: 14))
                       .overlay {
                           RoundedRectangle(cornerRadius: 14)
                               .stroke(Color(.separator), lineWidth: 1)
                       }
               }
               .buttonStyle(.plain)
               .padding(.top, 14)

               Text(draft.paymentErrorMessage ?? "Payment is recorded by staff.")
                   .font(.footnote)
                   .foregroundStyle(draft.paymentErrorMessage == nil ? Color.secondary : Color.red)
                   .multilineTextAlignment(.center)
                   .frame(maxWidth: .infinity)
                   .padding(.top, 28)

               Spacer()
           }
           .padding(.horizontal, 24)
           .padding(.top, 24)
           .background(Color(.systemBackground))
           .navigationBarBackButtonHidden()
           .disabled(draft.isTakingPayment)
           .overlay {
               if draft.isTakingPayment {
                   ProgressView("Taking payment…")
                       .padding(24)
                       .background(Color(.secondarySystemBackground))
                       .clipShape(RoundedRectangle(cornerRadius: 16))
               }
           }
       }

    private func take(_ method: PaymentMethod) {
        Task {
            // A decline is a normal outcome and moves to its own screen; only a
            // payment that could not be attempted stays here as a message.
            guard await draft.takePayment(method: method, repository: paymentRepository) else { return }

            router.push(draft.payment?.status == .approved ? .paymentComplete : .paymentFailed)
        }
    }
}

#Preview {
    NavigationStack {
        PaymentMethodUiView()
    }
    .environmentObject(OrderDraftViewModel())
    .environmentObject(OrderFlowRouter())
}
