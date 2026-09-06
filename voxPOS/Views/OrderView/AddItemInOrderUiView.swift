//
//  AddItemInOrderUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct AddItemInOrderUiView: View {

    @ObservedObject var draft: OrderDraftViewModel

    @EnvironmentObject private var productViewModel: ProductViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selected: Product?
    @State private var quantity = 1
    @State private var chosenOptions: Set<String> = []

    /// Sold out products are never offered, the same rule the model works under.
    private var matches: [Product] {
        let onSale = productViewModel.products.filter(\.isAvailable)
        let wanted = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !wanted.isEmpty else { return onSale }

        return onSale.filter { $0.title.localizedCaseInsensitiveContains(wanted) }
    }

    private var lineTotal: Decimal {
        (selected?.price ?? 0) * Decimal(quantity)
    }

    var body: some View {
          VStack(alignment: .leading, spacing: 0) {

              // Header
              HStack {
      
                  Spacer()

                  Button("Cancel") {
                      dismiss()
                  }
                  .font(.subheadline.bold())
              }

              Text("Add Item")
                  .font(.title.bold())
                  .padding(.top, 24)

              Text("Order #\(draft.orderNumber)")
                  .font(.body)
                  .foregroundStyle(.secondary)
                  .padding(.top, 4)

              // Search box
              HStack(spacing: 14) {
                  Image(systemName: "magnifyingglass")
                      .foregroundStyle(.secondary)

                  TextField("Search menu", text: $searchText)
                      .autocorrectionDisabled()

                  Spacer()
              }
              .padding(.horizontal, 16)
              .frame(height: 52)
              .background(Color(.secondarySystemBackground))
              .clipShape(RoundedRectangle(cornerRadius: 12))
              .overlay {
                  RoundedRectangle(cornerRadius: 12)
                      .stroke(Color(.separator), lineWidth: 1)
              }
              .padding(.top, 28)

              if let product = selected {
                  ItemOptionsEditor(
                      product: product,
                      quantity: $quantity,
                      chosenOptions: $chosenOptions,
                      onChooseAnother: { selected = nil }
                  )
              } else {
                  menuList
              }

              Spacer(minLength: 12)

              Button(action: addToOrder) {
                  Text(selected == nil
                       ? "Choose an item"
                       : "Add to Order · \(lineTotal.formatted(.currency(code: "AUD")))")
                      .font(.headline)
                      .foregroundStyle(.white)
                      .frame(maxWidth: .infinity)
                      .frame(height: 56)
                      .background(selected == nil ? Color.gray : Color.blue)
                      .clipShape(RoundedRectangle(cornerRadius: 14))
              }
              .disabled(selected == nil)
          }
          .padding(.horizontal, 24)
          .padding(.top, 24)
          .padding(.bottom, 40)
          .background(Color(.systemBackground))
      }

    private var menuList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(matches) { product in
                    Button {
                        selected = product
                        quantity = 1
                        chosenOptions = []
                    } label: {
                        HStack(spacing: 14) {
                            ProductThumbnail(product: product, size: 56)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                if let description = product.description {
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()

                            Text(product.price, format: .currency(code: "AUD"))
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)

                    Divider()
                }
            }
        }
        .padding(.top, 12)
    }

    private func addToOrder() {
        guard let product = selected else { return }

        draft.add(product, quantity: quantity, modifiers: Array(chosenOptions))
        dismiss()
    }
}

#Preview {
    AddItemInOrderUiView(draft: OrderDraftViewModel())
        .environmentObject(ProductViewModel(repository: JSONProductRepository()))
}
