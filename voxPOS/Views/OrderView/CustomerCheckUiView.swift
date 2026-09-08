//
//  CustomerCheckUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct CustomerCheckUiView: View {

    @EnvironmentObject private var draft: OrderDraftViewModel
    @EnvironmentObject private var router: OrderFlowRouter

    var body: some View {
          VStack(alignment: .leading, spacing: 0) {

              Text("Please check\nyour order")
                  .font(.system(size: 30, weight: .bold))
                  .padding(.top, 50)

              Text("Order #\(draft.orderNumber)")
                  .font(.subheadline.bold())
                  .foregroundStyle(.secondary)
                  .padding(.top, 14)

              // Order summary
              VStack(alignment: .leading, spacing: 18) {
                  ForEach(draft.items, id: \.orderItemID) { item in
                      Text("\(item.quantity) × \(item.itemName)")
                          .font(.headline)

                      if !item.modifiers.isEmpty {
                          Text(item.modifiers.joined(separator: ", "))
                              .font(.body)
                              .foregroundStyle(.secondary)
                              .padding(.leading, 16)
                      }
                  }
              }
              .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
              .padding(20)
              .background(Color(.secondarySystemBackground))
              .clipShape(RoundedRectangle(cornerRadius: 16))
              .overlay {
                  RoundedRectangle(cornerRadius: 16)
                      .stroke(Color(.separator), lineWidth: 1)
              }
              .padding(.top, 38)

              // Total
              VStack(alignment: .leading, spacing: 8) {
                  Text("TOTAL")
                      .font(.caption.bold())
                      .foregroundStyle(.secondary)

                  Text(draft.total, format: .currency(code: "AUD"))
                      .font(.system(size: 38, weight: .bold))
                      .frame(maxWidth: .infinity, alignment: .trailing)
              }
              .padding(18)
              .background(Color(.secondarySystemBackground))
              .clipShape(RoundedRectangle(cornerRadius: 16))
              .padding(.top, 30)

              Spacer()

              Button(action: {
                  router.push(.payment)
              }) {
                  Text("Confirm")
                      .font(.headline)
                      .foregroundStyle(.white)
                      .frame(maxWidth: .infinity)
                      .frame(height: 56)
                      .background(Color.blue)
                      .clipShape(RoundedRectangle(cornerRadius: 14))
              }

              Button(action: {
                  router.back()
              }) {
                  Text("Change Order")
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
              .padding(.top, 14)
          }
          .padding(.horizontal, 24)
          .padding(.bottom, 64)
          .background(Color(.systemBackground))
          .navigationBarBackButtonHidden()
      }
  }

#Preview {
    NavigationStack {
        CustomerCheckUiView()
    }
    .environmentObject(OrderDraftViewModel())
    .environmentObject(OrderFlowRouter())
}
