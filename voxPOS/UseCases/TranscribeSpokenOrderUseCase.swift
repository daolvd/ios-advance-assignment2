//
//  TranscribeSpokenOrderUseCase.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation

// The ways listening to a customer can fail.

enum SpokenOrderError: LocalizedError, Equatable {

    case noSpeechHeard

    case couldNotListen(reason: String)

    case languageNotRecognised

    case couldNotTranslate(language: String)

    var errorDescription: String? {
        switch self {
        case .noSpeechHeard:
            return "We didn't catch that. Please ask the customer to say it again."
        case .couldNotListen:
            return "The microphone isn't available. Please check the app's permissions."
        case .languageNotRecognised:
            return "We couldn't tell which language that was. Please try again."
        case .couldNotTranslate(let language):
            return "We couldn't translate from \(language). Please take this order manually."
        }
    }
}

struct TranscribeSpokenOrderUseCase {

    private let transcriber: SpeechTranscribing
    private let detector: LanguageDetecting
    private let translator: TextTranslating

    // The language the staff works in. English for now.
    private let staffLanguageCode: String

    private let minimumLanguageConfidence: Double

    init( transcriber: SpeechTranscribing, detector: LanguageDetecting, translator: TextTranslating, staffLanguageCode: String = "en", minimumLanguageConfidence: Double = 0.5
    ) {
        self.transcriber = transcriber
        self.detector = detector
        self.translator = translator
        self.staffLanguageCode = staffLanguageCode
        self.minimumLanguageConfidence = minimumLanguageConfidence
    }

    
    func doTranscript() async throws -> SpokenOrderTranscript {
        let heard: SpeechTranscription

        do {
            heard = try await transcriber.transcribe()
        } catch {
            throw SpokenOrderError.couldNotListen(reason: error.localizedDescription)
        }

        let spokenText = heard.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !spokenText.isEmpty else {
            throw SpokenOrderError.noSpeechHeard
        }

        guard
            let language = detector.detectLanguage(of: spokenText),
            language.confidence >= minimumLanguageConfidence
        else {
            throw SpokenOrderError.languageNotRecognised
        }

        // The customer already speaks the staff's language, so there is nothing to translate.
        guard language.code != staffLanguageCode else {
            return SpokenOrderTranscript(
                spokenText: spokenText,
                staffText: spokenText,
                detectedLanguage: language,
                recognitionConfidence: heard.confidence,
                wasTranslated: false
            )
        }

        let staffText: String

        do {
            staffText = try await translator.translate(
                spokenText,
                from: language.code,
                to: staffLanguageCode
            )
        } catch {
            throw SpokenOrderError.couldNotTranslate(language: language.displayName)
        }

        return SpokenOrderTranscript(
            spokenText: spokenText,
            staffText: staffText,
            detectedLanguage: language,
            recognitionConfidence: heard.confidence,
            wasTranslated: true
        )
    }
}
