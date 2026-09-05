//
//  InterpretedOrderUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct InterpretedOrderUiView: View {
    var body: some View {
            VStack(alignment: .leading, spacing: 0) {

                Text("voxPOS")
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)

                Text("Order created")
                    .font(.title.bold())
                    .padding(.top, 24)

                Text("Draft order · not saved yet")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)

                // Order information
                VStack(alignment: .leading, spacing: 14) {
                    Text("2 × Chicken Burger")
                        .font(.headline)

                    Text("No cheese ×1")
                        .foregroundStyle(.secondary)
                        .padding(.leading, 18)

                    Text("1 × Iced Tea")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(22)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.separator), lineWidth: 1)
                }
                .padding(.top, 44)

                // Recognition status
                VStack(alignment: .leading, spacing: 6) {
                    Text("Recognised clearly")
                        .font(.headline)

                    Text("Check before confirming.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.top, 24)

                // What we heard
                Button(action: {
                    // TODO: Show transcript
                }) {
                    HStack {
                        Text("What we heard")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                    }
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
                .padding(.top, 22)

                Spacer()

                Button(action: {
                    // TODO: Open review order
                }) {
                    Text("Review Order")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button(action: {
                    // TODO: Record again
                }) {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.separator), lineWidth: 1)
                        }
                }
                .padding(.top, 14)

                Button(action: {
                    // TODO: Enter order manually
                }) {
                    Text("Enter Manually")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 40)
            .background(Color(.systemBackground))
        }
    }

#Preview {
    InterpretedOrderUiView()
}
