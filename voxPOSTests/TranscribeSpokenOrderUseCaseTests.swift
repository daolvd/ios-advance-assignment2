//
//  TranscribeSpokenOrderUseCaseTests.swift
//  voxPOSTests
//
//  Created by Van Dao Le on 6/9/2026.
//
//  White box, path coverage of TranscribeSpokenOrderUseCase.doTranscript.
//
//  P1  microphone throws                        -> throws .couldNotListen
//  P2  transcript empty after trimming          -> throws .noSpeechHeard
//  P3  detector returns nil                     -> throws .languageNotRecognised
//  P4  detector unsure (below the threshold)    -> throws .languageNotRecognised
//  P5  customer already speaks staff language   -> returns untranslated
//  P6  translator throws                        -> throws .couldNotTranslate
//  P7  translated                               -> returns both wordings
//
//  Boundary: confidence exactly at the threshold is trusted (P7), just under is not (P4).
//

import Testing
import Foundation
@testable import voxPOS

struct TranscribeSpokenOrderUseCaseTests {

    private func makeUseCase(
        hears text: String = "Hai burger gà",
        confidence: Double = 0.9,
        language: DetectedLanguage? = DetectedLanguage(code: "vi", confidence: 0.95),
        translation: String? = "Two chicken burgers",
        minimumLanguageConfidence: Double = 0.5
    ) -> TranscribeSpokenOrderUseCase {
        TranscribeSpokenOrderUseCase(
            transcriber: StubTranscriber(hears: text, confidence: confidence),
            detector: StubLanguageDetector(language: language),
            translator: StubTranslator(returns: translation),
            minimumLanguageConfidence: minimumLanguageConfidence
        )
    }

    // MARK: P7 — happy path

    @Test func doTranscript_translatesTheCustomerIntoTheStaffLanguage() async throws {
        let transcript = try await makeUseCase().doTranscript()

        #expect(transcript.spokenText == "Hai burger gà")
        #expect(transcript.staffText == "Two chicken burgers")
        #expect(transcript.detectedLanguage.code == "vi")
        #expect(transcript.wasTranslated)
    }

    /// Boundary: the threshold is "at least this sure", so exactly 0.5 is trusted.
    @Test func doTranscript_trustsALanguageDetectedExactlyAtTheThreshold() async throws {
        let useCase = makeUseCase(
            language: DetectedLanguage(code: "vi", confidence: 0.5),
            minimumLanguageConfidence: 0.5
        )

        let transcript = try await useCase.doTranscript()

        #expect(transcript.detectedLanguage.code == "vi")
    }

    // MARK: P5 — nothing to translate

    @Test func doTranscript_passesEnglishThrough_whenTheCustomerSpeaksTheStaffLanguage() async throws {
        let translator = StubTranslator(returns: "should never be used")
        let useCase = TranscribeSpokenOrderUseCase(
            transcriber: StubTranscriber(hears: "One iced tea please"),
            detector: StubLanguageDetector(language: DetectedLanguage(code: "en", confidence: 0.99)),
            translator: translator
        )

        let transcript = try await useCase.doTranscript()

        #expect(transcript.staffText == "One iced tea please")
        #expect(transcript.wasTranslated == false)
        #expect(translator.receivedText == nil, "English must never reach the translator")
    }

    // MARK: P1 — the microphone

    @Test func doTranscript_fails_whenTheMicrophoneCannotBeUsed() async {
        struct MicrophoneRefused: Error {}

        let useCase = TranscribeSpokenOrderUseCase(
            transcriber: StubTranscriber(failsWith: MicrophoneRefused()),
            detector: StubLanguageDetector(language: nil),
            translator: StubTranslator(returns: nil)
        )

        await #expect(throws: SpokenOrderError.self) {
            try await useCase.doTranscript()
        }
    }

    // MARK: P2 — nothing said

    @Test func doTranscript_fails_whenOnlySilenceWasHeard() async {
        let useCase = makeUseCase(hears: "   \n ")

        await #expect(throws: SpokenOrderError.noSpeechHeard) {
            try await useCase.doTranscript()
        }
    }

    // MARK: P3, P4 — the language

    @Test func doTranscript_fails_whenNoLanguageCanBePlaced() async {
        let useCase = makeUseCase(language: nil)

        await #expect(throws: SpokenOrderError.languageNotRecognised) {
            try await useCase.doTranscript()
        }
    }

    /// Boundary: just under the threshold is refused. A confident translation from
    /// the wrong language reads as a real order and is worse than no order at all.
    @Test func doTranscript_fails_whenTheLanguageIsGuessedTooWeakly() async {
        let useCase = makeUseCase(
            language: DetectedLanguage(code: "vi", confidence: 0.49),
            minimumLanguageConfidence: 0.5
        )

        await #expect(throws: SpokenOrderError.languageNotRecognised) {
            try await useCase.doTranscript()
        }
    }

    // MARK: P6 — the translator

    @Test func doTranscript_fails_whenTheLanguagePackIsUnavailable() async {
        let useCase = makeUseCase(translation: nil)

        let expected = SpokenOrderError.couldNotTranslate(
            language: DetectedLanguage(code: "vi", confidence: 0.95).displayName
        )

        await #expect(throws: expected) {
            try await useCase.doTranscript()
        }
    }
}
