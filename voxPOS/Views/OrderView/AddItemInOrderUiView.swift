//
//  AddItemInOrderUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct AddItemInOrderUiView: View {
    var body: some View {
          VStack(alignment: .leading, spacing: 0) {

              // Header
              HStack {
      
                  Spacer()

                  Button("Cancel") {
                      // TODO
                  }
                  .font(.subheadline.bold())
              }

              Text("Add Item")
                  .font(.title.bold())
                  .padding(.top, 24)

              Text("Order #43")
                  .font(.body)
                  .foregroundStyle(.secondary)
                  .padding(.top, 4)

              // Search box
              HStack(spacing: 14) {
                  Image(systemName: "magnifyingglass")
                      .foregroundStyle(.secondary)

                  Text("Search menu")
                      .foregroundStyle(.secondary)

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

              // Product name and price
              HStack {
                  Text("Chicken Burger")
                      .font(.headline)

                  Spacer()

                  Text("$10.00")
                      .font(.headline)
              }
              .padding(.top, 30)

              // Quantity
              HStack {
                  Text("Quantity")
                      .font(.subheadline.bold())
                      .foregroundStyle(.secondary)

                  Spacer()

                  Button(action: {
                      // TODO: Decrease quantity
                  }) {
                      Image(systemName: "minus")
                          .frame(height: 18)
                  }
                  .buttonStyle(.bordered)
                  .buttonBorderShape(.circle)

                  Text("1")
                      .font(.headline)
                      .padding(.horizontal, 10)

                  Button(action: {
                      // TODO: Increase quantity
                  }) {
                      Image(systemName: "plus")
                          .frame(height: 18)
                  }
                  .buttonStyle(.bordered)
                  .buttonBorderShape(.circle)
              }
              .padding(.top, 16)

              // Modifiers
              Text("Chose option:")
                  .font(.subheadline.bold())
                  .foregroundStyle(.secondary)
                  .padding(.top, 10
                  )

              HStack(spacing: 10) {
                  Text("No cheese")
                      .font(.subheadline)
                      .padding(.horizontal, 12)
                      .padding(.vertical, 8)
                      .background(Color(.systemBackground))
                      .clipShape(Capsule())
                      .overlay {
                          Capsule()
                              .stroke(Color(.separator), lineWidth: 1)
                      }

                  Text("Extra pickles")
                      .font(.subheadline)
                      .padding(.horizontal, 12)
                      .padding(.vertical, 8)
                      .background(Color(.systemBackground))
                      .clipShape(Capsule())
                      .overlay {
                          Capsule()
                              .stroke(Color(.separator), lineWidth: 1)
                      }
              }
              .padding(.top, 10)

     
              Spacer()

              Button(action: {
                  // TODO: Add item to order
              }) {
                  Text("Add to Order · $10.00")
                      .font(.headline)
                      .foregroundStyle(.white)
                      .frame(maxWidth: .infinity)
                      .frame(height: 56)
                      .background(Color.blue)
                      .clipShape(RoundedRectangle(cornerRadius: 14))
              }
          }
          .padding(.horizontal, 24)
          .padding(.top, 24)
          .padding(.bottom, 40)
          .background(Color(.systemBackground))
      }
  }
#Preview {
    AddItemInOrderUiView()
}
