//
//  ReviewEditUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct ReviewEditUiView: View {

    @ObservedObject var draft: OrderDraftViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {


              Text("Review Order")
                  .font(.title.bold())
                  .padding(.top, 24)

              Text("Order #\(draft.orderNumber)")
                  .font(.body)
                  .foregroundStyle(.secondary)
                  .padding(.top, 4)

              // Product card
              ForEach(draft.items, id: \.orderItemID) { item in
              VStack(alignment: .leading, spacing: 10) {
                  HStack {
                      Text(item.itemName)
                          .font(.headline)

                      Spacer()

                      Text(item.unitPrice, format: .currency(code: "AUD"))
                          .font(.headline)
                  }

                  if !item.modifiers.isEmpty {
                      Text(item.modifiers.joined(separator: ", "))
                          .foregroundStyle(.secondary)
                  }

                  HStack(spacing: 16) {
                      Button(action: {
                          draft.decreaseQuantity(of: item)
                      }) {
                          Image(systemName: "minus")
                              .frame(height: 18)
                      }
                      .buttonStyle(.bordered)
                      .buttonBorderShape(.circle)
                      .disabled(item.quantity <= 1)
                      // number of item
                      Text("\(item.quantity)")
                          .font(.headline)

                      Button(action: {
                          draft.increaseQuantity(of: item)
                      }) {
                          Image(systemName: "plus")
                              .frame(height: 18)
                      }
                      .buttonStyle(.bordered)
                      .buttonBorderShape(.circle)

                      Spacer()

                      Text(item.lineTotal, format: .currency(code: "AUD"))
                          .font(.headline)
                  }
              }
              .padding(20)
              .background(Color(.secondarySystemBackground))
              .clipShape(RoundedRectangle(cornerRadius: 16))
              .overlay {
                  RoundedRectangle(cornerRadius: 16)
                      .stroke(Color(.separator), lineWidth: 1)
              }
              .padding(.top, item.orderItemID == draft.items.first?.orderItemID ? 44 : 14)
              }

              if !draft.warnings.isEmpty {
                  VStack(alignment: .leading, spacing: 6) {
                      Text("Check with the customer")
                          .font(.headline)

                      ForEach(draft.warnings, id: \.self) { warning in
                          Text("• \(warning)")
                              .foregroundStyle(.secondary)
                      }
                  }
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding(20)
                  .background(Color.orange.opacity(0.12))
                  .clipShape(RoundedRectangle(cornerRadius: 16))
                  .padding(.top, 20)
              }

              // Add item
              Button(action: {
                  // TODO: Add item
              }) {
                  HStack(spacing: 18) {
                      Image(systemName: "plus")
                      Text("Add Item")
                          .font(.headline)

                      Spacer()
                  }
                  .foregroundStyle(.blue)
                  .padding(.horizontal, 20)
                  .frame(height: 60)
                  .background(Color(.systemBackground))
                  .clipShape(RoundedRectangle(cornerRadius: 14))
                  .overlay {
                      RoundedRectangle(cornerRadius: 14)
                          .stroke(Color(.separator), lineWidth: 1)
                  }
              }
              .buttonStyle(.plain)
              .padding(.top, 20)

              Spacer()

              // Total
              HStack {
                  Text("Total")
                      .font(.headline)

                  Spacer()

                  Text(draft.total, format: .currency(code: "AUD"))
                      .font(.system(size: 30, weight: .bold))
              }
              .padding(20)
              .background(Color(.secondarySystemBackground))
              .clipShape(RoundedRectangle(cornerRadius: 16))

              Button(action: {
                  // TODO: Show customer screen
              }) {
                  Text("Show Customer")
                      .font(.headline)
                      .foregroundStyle(.white)
                      .frame(maxWidth: .infinity)
                      .frame(height: 60)
                      .background(Color.blue)
                      .clipShape(RoundedRectangle(cornerRadius: 16))
              }
              .padding(.top, 32)

              Button(action: {
                  draft.cancel()
                  dismiss()
              }) {
                  Text("Cancel Order")
                      .font(.headline)
                      .foregroundStyle(.red)
                      .frame(maxWidth: .infinity)
                      .frame(height: 50)
              }
              .padding(.top, 10)
          }
          .padding(.horizontal, 24)
          .padding(.top, 24)
          .padding(.bottom, 40)
          .background(Color(.systemBackground))
      }
  }


#Preview {
    NavigationStack {
        ReviewEditUiView(draft: OrderDraftViewModel())
    }
}
