//
//  CustomerCheckUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct CustomerCheckUiView: View {
    var body: some View {
          VStack(alignment: .leading, spacing: 0) {

              Text("Please check\nyour order")
                  .font(.system(size: 30, weight: .bold))
                  .padding(.top, 50)

              Text("Ordered in Vietnamese")
                  .font(.subheadline.bold())
                  .foregroundStyle(.secondary)
                  .padding(.top, 14)

              // Order summary
              VStack(alignment: .leading, spacing: 18) {
                  Text("2 × Chicken Burger")
                      .font(.headline)

                  Text("No cheese ×1")
                      .font(.body)
                      .foregroundStyle(.secondary)
                      .padding(.leading, 16)

                  Text("1 × Iced Tea")
                      .font(.headline)
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

                  Text("$24.00")
                      .font(.system(size: 38, weight: .bold))
                      .frame(maxWidth: .infinity, alignment: .trailing)
              }
              .padding(18)
              .background(Color(.secondarySystemBackground))
              .clipShape(RoundedRectangle(cornerRadius: 16))
              .padding(.top, 30)

              Spacer()

              Button(action: {
                  // TODO: Confirm order
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
                  // TODO: Return to review order
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
      }
  }

#Preview {
    CustomerCheckUiView()
}
