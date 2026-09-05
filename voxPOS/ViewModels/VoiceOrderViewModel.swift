//
//  VoiceOrderViewModel.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation
import Combine

@MainActor
class VoiceOrderViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case listening
        case captured(SpokenOrderTranscript)
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    /// The microphone session belongs to the screen, so the view model holds it
    /// directly and lets the use case own the transcribe-detect-translate pipeline.
    private let transcriber: SpeechTranscribing
    private let useCase: TranscribeSpokenOrderUseCase
    private var listeningTask: Task<Void, Never>?

    init(
        transcriber: SpeechTranscribing = FakeSpeechTranscriber(),
        detector: LanguageDetecting = NaturalLanguageDetector(),
        translator: TextTranslating = FakeTranslator()
    ) {
        self.transcriber = transcriber
        self.useCase = TranscribeSpokenOrderUseCase(
            transcriber: transcriber,
            detector: detector,
            translator: translator
        )
    }

    var isListening: Bool {
        state == .listening
    }

    var transcript: SpokenOrderTranscript? {
        guard case .captured(let transcript) = state else { return nil }

        return transcript
    }

    var errorMessage: String? {
        guard case .failed(let message) = state else { return nil }

        return message
    }

    /// Caption for the language chip, for example "Detected: Vietnamese".
    var detectedLanguageCaption: String {
        guard let transcript else { return "Listening…" }

        return "Detected: \(transcript.detectedLanguage.displayName)"
    }

    func startListening() {
        guard !isListening else { return }

        state = .listening

        listeningTask = Task { [useCase] in
            do {
                let transcript = try await useCase.doTranscript()

                guard !Task.isCancelled else { return }
                state = .captured(transcript)
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed(error.localizedDescription)
            }
        }
    }

    /// The customer has finished speaking: finalise what was heard.
    func stopListening() {
        transcriber.stopListening()
    }

    /// Leave the screen without keeping anything.
    func cancel() {
        listeningTask?.cancel()
        listeningTask = nil
        transcriber.stopListening()

        state = .idle
    }

    func retry() {
        state = .idle
        startListening()
    }
}
