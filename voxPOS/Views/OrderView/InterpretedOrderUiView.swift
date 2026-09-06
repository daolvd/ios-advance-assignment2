//
//  InterpretedOrderUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct InterpretedOrderUiView: View {

    @ObservedObject var draft: OrderDraftViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingTranscript = false
    @State private var isReviewingOrder = false

    var body: some View {
            VStack(alignment: .leading, spacing: 0) {

                Text("Order #\(draft.orderNumber) created")
                    .font(.title.bold())
                    .padding(.top, 24)

                Text("Draft order · not saved yet")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)

                // Order information
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(draft.items, id: \.orderItemID) { item in
                        Text("\(item.quantity) × \(item.itemName)")
                            .font(.headline)

                        ForEach(item.modifiers, id: \.self) { modifier in
                            Text(modifier)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 18)
                        }
                    }
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
                    Text(draft.warnings.isEmpty ? "Recognised clearly" : "Check these before confirming")
                        .font(.headline)

                    if draft.warnings.isEmpty {
                        Text("Check before confirming.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(draft.warnings, id: \.self) { warning in
                            Text("• \(warning)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.top, 24)

                // What we heard
                Button(action: {
                    isShowingTranscript.toggle()
                }) {
                    VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("What we heard")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: isShowingTranscript ? "chevron.up" : "chevron.down")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 60)

                    if isShowingTranscript {
                        Text("“\(draft.spokenText)”")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 16)
                    }
                    }
                    .padding(.horizontal, 20)
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
                    isReviewingOrder = true
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
                    draft.cancel()
                    dismiss()
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
                    isReviewingOrder = true
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
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $isReviewingOrder) {
                ReviewEditUiView(draft: draft)
            }
        }
    }

#Preview {
    NavigationStack {
        InterpretedOrderUiView(draft: OrderDraftViewModel())
    }
}
