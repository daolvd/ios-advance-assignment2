//
//  EditOrderItemUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import SwiftUI

/// Changes a line already on the ticket: how many, which options, or take it off.
struct EditOrderItemUiView: View {

    @ObservedObject var draft: OrderDraftViewModel
    let item: OrderItem

    @EnvironmentObject private var productViewModel: ProductViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var quantity = 1
    @State private var chosenOptions: Set<String> = []

    /// The line was priced from this product, so its options are the ones offered.
    private var product: Product? {
        productViewModel.products.first { $0.id == item.menuItemID }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .font(.subheadline.bold())
            }

            Text("Edit Item")
                .font(.title.bold())
                .padding(.top, 24)

            Text("Order #\(draft.orderNumber)")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            if let product {
                ItemOptionsEditor(
                    product: product,
                    quantity: $quantity,
                    chosenOptions: $chosenOptions,
                    onChooseAnother: nil
                )
            } else {
                Text("\(item.itemName) is no longer on the menu.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.top, 30)
            }

            Spacer(minLength: 12)

            Button(action: save) {
                Text("Save · \(lineTotal.formatted(.currency(code: "AUD")))")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(product == nil ? Color.gray : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(product == nil)

            Button(role: .destructive) {
                draft.remove(item)
                dismiss()
            } label: {
                Text("Remove from Order")
                    .font(.headline)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 40)
        .background(Color(.systemBackground))
        .onAppear {
            quantity = item.quantity
            chosenOptions = Set(item.modifiers)
        }
    }

    private var lineTotal: Decimal {
        item.unitPrice * Decimal(quantity)
    }

    private func save() {
        // Options first: changing them can merge this line into another one, and the
        // quantity has to be applied to whichever line survives.
        draft.setOptions(Array(chosenOptions), of: item)
        draft.setQuantity(quantity, of: item)
        dismiss()
    }
}

/// A product's picture, or a plate icon when it has none.
///
/// The image name comes from the menu data, so a typo there or a product added
/// without artwork must still lay out the same. `Image(_:)` renders nothing at all
/// for a missing asset, which would leave a hole in the row.
struct ProductThumbnail: View {

    let product: Product
    let size: CGFloat

    private var artwork: Image? {
        guard let name = product.image, UIImage(named: name) != nil else { return nil }

        return Image(name)
    }

    var body: some View {
        Group {
            if let artwork {
                artwork
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "fork.knife")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.secondarySystemBackground))
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.separator), lineWidth: 0.5)
        }
    }
}

/// Quantity stepper plus the option chips, shared by adding and editing a line.
struct ItemOptionsEditor: View {

    let product: Product
    @Binding var quantity: Int
    @Binding var chosenOptions: Set<String>

    /// Only the add screen lets you go back to the menu list.
    let onChooseAnother: (() -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                HStack(spacing: 14) {
                    ProductThumbnail(product: product, size: 72)

                    Text(product.title)
                        .font(.headline)

                    Spacer()

                    Text(product.price, format: .currency(code: "AUD"))
                        .font(.headline)
                }
                .padding(.top, 30)

                if let onChooseAnother {
                    Button("Choose a different item", action: onChooseAnother)
                        .font(.subheadline)
                        .padding(.top, 6)
                }

                // Quantity
                HStack {
                    Text("Quantity")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button(action: { quantity = max(quantity - 1, 1) }) {
                        Image(systemName: "minus")
                            .frame(height: 18)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    .disabled(quantity <= 1)

                    Text("\(quantity)")
                        .font(.headline)
                        .padding(.horizontal, 10)

                    Button(action: { quantity += 1 }) {
                        Image(systemName: "plus")
                            .frame(height: 18)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                }
                .padding(.top, 16)

                // Only this product's own options, so nothing unmakeable can be chosen.
                if !product.allowModifier.isEmpty {
                    Text("Chose option:")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                        .padding(.top, 10)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(rows, id: \.self) { row in
                            HStack(spacing: 10) {
                                ForEach(row, id: \.self) { option in
                                    chip(option)
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
    }

    private func chip(_ option: String) -> some View {
        let isChosen = chosenOptions.contains(option)

        return Button {
            if isChosen { chosenOptions.remove(option) } else { chosenOptions.insert(option) }
        } label: {
            Text(option)
                .font(.subheadline)
                .foregroundStyle(isChosen ? Color.white : Color.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isChosen ? Color.blue : Color(.systemBackground))
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color(.separator), lineWidth: isChosen ? 0 : 1)
                }
        }
        .buttonStyle(.plain)
    }

    /// Two per row keeps long option names readable without measuring text.
    private var rows: [[String]] {
        stride(from: 0, to: product.allowModifier.count, by: 2).map {
            Array(product.allowModifier[$0..<min($0 + 2, product.allowModifier.count)])
        }
    }
}
