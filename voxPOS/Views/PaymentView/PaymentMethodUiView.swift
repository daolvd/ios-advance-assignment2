//
//  PaymentMethodUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct PaymentMethodUiView: View {
    var body: some View {
           VStack(alignment: .leading, spacing: 0) {


               Text("Payment")
                   .font(.title.bold())
                   .padding(.top, 24)

               Text("Order #43")
                   .font(.body)
                   .foregroundStyle(.secondary)
                   .padding(.top, 4)

               Text("AMOUNT DUE")
                   .font(.caption.bold())
                   .foregroundStyle(.secondary)
                   .padding(.top, 56)

               Text("$24.00")
                   .font(.system(size: 42, weight: .bold))
                   .frame(maxWidth: .infinity)
                   .padding(.top, 10)

               Text("Choose a payment method")
                   .font(.subheadline.bold())
                   .foregroundStyle(.secondary)
                   .frame(maxWidth: .infinity)
                   .padding(.top, 44)

               Button(action: {
                   // TODO: Pay by cash
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
                   // TODO: Pay by card
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

               Button(action: {
                   // TODO: Pay by QR transfer
               }) {
                   Text("QR Transfer")
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

               Text("Payment is recorded by staff.")
                   .font(.footnote)
                   .foregroundStyle(.secondary)
                   .frame(maxWidth: .infinity)
                   .padding(.top, 28)

               Spacer()
           }
           .padding(.horizontal, 24)
           .padding(.top, 24)
           .background(Color(.systemBackground))
       }
   }
#Preview {
    PaymentMethodUiView()
}
