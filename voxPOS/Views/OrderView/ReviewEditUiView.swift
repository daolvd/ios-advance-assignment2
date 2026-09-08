//
//  ReviewEditUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct ReviewEditUiView: View {

    @ObservedObject var draft: OrderDraftViewModel

    @EnvironmentObject private var router: OrderFlowRouter
    @EnvironmentObject private var productViewModel: ProductViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isAddingItem = false
    @State private var itemBeingEdited: OrderItem?

    private func product(for item: OrderItem) -> Product? {
        productViewModel.products.first { $0.id == item.menuItemID }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

              HStack(alignment: .firstTextBaseline) {
                  VStack(alignment: .leading, spacing: 4) {
                      Text("Review Order")
                          .font(.title.bold())

                      Text("Order #\(draft.orderNumber)")
                          .font(.body)
                          .foregroundStyle(.secondary)
                  }

                  Spacer()

                  Button(action: {
                      isAddingItem = true
                  }) {
                      Label("Add Item", systemImage: "plus")
                          .font(.subheadline.bold())
                          .foregroundStyle(.blue)
                          .padding(.horizontal, 14)
                          .padding(.vertical, 9)
                          .background(Color.blue.opacity(0.1))
                          .clipShape(Capsule())
                  }
                  .buttonStyle(.plain)
              }
              .padding(.top, 6)

              // Product card
              ScrollView {
              VStack(alignment: .leading, spacing: 0) {
              ForEach(draft.items, id: \.orderItemID) { item in
              VStack(alignment: .leading, spacing: 10) {
                  HStack(spacing: 12) {
                      // The line only keeps the product's id, so the picture comes
                      // from today's menu rather than being copied onto the order.
                      if let product = product(for: item) {
                          ProductThumbnail(product: product, size: 40)
                      }

                      Button(action: {
                          itemBeingEdited = item
                      }) {
                          HStack(spacing: 6) {
                              Text(item.itemName)
                                  .font(.headline)
                                  .foregroundStyle(.primary)

                              Image(systemName: "pencil")
                                  .font(.caption.bold())
                                  .foregroundStyle(.blue)
                          }
                      }
                      .buttonStyle(.plain)

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

                      Button(action: {
                          draft.remove(item)
                      }) {
                          Image(systemName: "trash")
                              .frame(height: 18)
                      }
                      .buttonStyle(.bordered)
                      .buttonBorderShape(.circle)
                      .tint(.red)
                  }
              }
              .padding(20)
              .background(Color(.secondarySystemBackground))
              .clipShape(RoundedRectangle(cornerRadius: 16))
              .overlay {
                  RoundedRectangle(cornerRadius: 16)
                      .stroke(Color(.separator), lineWidth: 1)
              }
              .padding(.top, item.orderItemID == draft.items.first?.orderItemID ? 30 : 14)
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

              }
              }


              if let editError = draft.editErrorMessage {
                  Text(editError)
                      .font(.footnote)
                      .foregroundStyle(.red)
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .padding(.top, 12)
              }

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
                  router.push(.customerCheck)
              }) {
                  Text("Show Customer")
                      .font(.headline)
                      .foregroundStyle(.white)
                      .frame(maxWidth: .infinity)
                      .frame(height: 60)
                      .background(draft.items.isEmpty ? Color.gray : Color.blue)
                      .clipShape(RoundedRectangle(cornerRadius: 16))
              }
              .disabled(draft.items.isEmpty)
              .padding(.top, 32)

              Button(action: {
                  draft.cancel()
                  router.closeFlow()
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
          .padding(.bottom, 40)
          .background(Color(.systemBackground))
          .toolbar(.hidden, for: .navigationBar)
          .sheet(isPresented: $isAddingItem) {
              AddItemInOrderUiView(draft: draft)
          }
          .sheet(item: $itemBeingEdited) { item in
              EditOrderItemUiView(draft: draft, item: item)
          }
      }
  }


#Preview {
    NavigationStack {
        ReviewEditUiView(draft: OrderDraftViewModel())
    }
}
