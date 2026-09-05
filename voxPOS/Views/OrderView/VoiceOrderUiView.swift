//
//  VoiceOrderUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI
import Lottie

struct VoiceOrderUiView: View {

    @StateObject private var viewModel = VoiceOrderViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text(title)
                .font(.title.bold())
                .padding(.top, 20)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 2)

            // Lottie recorder
            LottieView(animation: .named("Red_recorder"))
                .playing(loopMode: .loop)
                .resizable()
                .scaledToFit()
                .frame(width: 170, height: 170)
                .frame(maxWidth: .infinity)
                .opacity(viewModel.isListening ? 1 : 0.35)
                .padding(.top, 40)

            // Detected language
            Text(viewModel.detectedLanguageCaption)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())
                .frame(maxWidth: .infinity)
                .padding(.top, 18)

            transcriptCard
                .padding(.top, 28)

            Spacer()

            primaryButton

            Button(action: cancel) {
                Text("Cancel")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .background(Color(.systemBackground))
        .animation(.default, value: viewModel.state)
        .task {
            viewModel.startListening()
        }
    }

    // MARK: - Pieces

    /// The transcript, or the reason there isn't one.
    @ViewBuilder
    private var transcriptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let errorMessage = viewModel.errorMessage {
                Text("COULDN'T HEAR THAT")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)

                Text(errorMessage)
                    .font(.body)
                    .foregroundStyle(.primary)
            } else if let transcript = viewModel.transcript {
                Text("LIVE TRANSCRIPT")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)

                Text("“\(transcript.staffText)”")
                    .font(.body)
                    .foregroundStyle(.primary)

                // Only worth showing the customer's own words when they differ.
                if transcript.wasTranslated {
                    Text("“\(transcript.spokenText)”")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("LIVE TRANSCRIPT")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)

                Text("Waiting for the customer to speak…")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .frame(minHeight: 130, alignment: .topLeading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var primaryButton: some View {
        Button(action: primaryAction) {
            Text(primaryButtonTitle)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - State to copy

    private var title: String {
        switch viewModel.state {
        case .listening: return "Listening"
        case .captured: return "Order heard"
        case .failed: return "Try again"
        case .idle: return "Ready"
        }
    }

    private var subtitle: String {
        switch viewModel.state {
        case .listening: return "We're listening for the customer."
        case .captured: return "Check it before you continue."
        case .failed: return "Nothing was captured."
        case .idle: return "Tap start when the customer is ready."
        }
    }

    private var primaryButtonTitle: String {
        switch viewModel.state {
        case .listening: return "Stop"
        case .captured: return "Continue"
        case .failed: return "Try Again"
        case .idle: return "Start"
        }
    }

    private func primaryAction() {
        switch viewModel.state {
        case .listening:
            viewModel.stopListening()
        case .captured:
            // TODO: hand the transcript to the order screen
            break
        case .failed:
            viewModel.retry()
        case .idle:
            viewModel.startListening()
        }
    }

    private func cancel() {
        viewModel.cancel()
        dismiss()
    }
}

#Preview {
    VoiceOrderUiView()
}
