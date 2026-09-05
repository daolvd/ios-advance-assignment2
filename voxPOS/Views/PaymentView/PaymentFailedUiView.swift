//
//  PaymentFailedUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct PaymentFailedUiView: View {
    var body: some View {
            VStack(spacing: 0) {

                Spacer()
                    .frame(height: 110)

                Image(systemName: "exclamationmark")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.orange)
                    .frame(width: 96, height: 96)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(Circle())

                Text("Payment didn't\ngo through")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top, 38)

                Text("Ask the customer for another card, or\ntry a different payment method.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 18)

                Text("Order #43 · $24.00 still open")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.top, 48)

                Spacer()

                Button(action: {
                    // TODO: Try payment again
                }) {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button(action: {
                    // TODO: Change payment method
                }) {
                    Text("Change Method")
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
                    // TODO: Return to order
                }) {
                    Text("Back to Order")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 64)
            .background(Color(.systemBackground))
        }
    }


#Preview {
    PaymentFailedUiView()
}
