//
//  ReviewEditUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct ReviewEditUiView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {


              Text("Review Order")
                  .font(.title.bold())
                  .padding(.top, 24)

              Text("Order #43")
                  .font(.body)
                  .foregroundStyle(.secondary)
                  .padding(.top, 4)

              // Product card
              VStack(alignment: .leading, spacing: 10) {
                  HStack {
                      Text("Chicken Burger")
                          .font(.headline)

                      Spacer()

                      Text("$10.00")
                          .font(.headline)
                  }

                  Text("No cheese")
                      .foregroundStyle(.secondary)

                  HStack(spacing: 16) {
                      Button(action: {
                          // TODO: Decrease quantity
                      }) {
                          Image(systemName: "minus")
                              .frame(height: 18)
                      }
                      .buttonStyle(.bordered)
                     
                      .buttonBorderShape(.circle)
                      // number of item
                      Text("2")
                          .font(.headline)

                      Button(action: {
                          // TODO: Increase quantity
                      }) {
                          Image(systemName: "plus")
                              .frame(height: 18)
                      }
                      .buttonStyle(.bordered)
                      .buttonBorderShape(.circle)

                      Spacer()

                      Text("$20.00")
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
              .padding(.top, 44)

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

                  Text("$24.00")
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
                  // TODO: Cancel order
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
    ReviewEditUiView()
}
