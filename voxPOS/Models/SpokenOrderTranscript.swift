//
//  SpokenOrderTranscript.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation

/// A language the app believes a customer was speaking, and how sure it is.
///
/// The confidence matters as much as the code. Detection on a short order such as
/// "hai burger" is unreliable, and translating from a confidently wrong language
/// produces a sentence that reads perfectly and means something else — worse at a
/// counter than admitting the language could not be placed.
struct DetectedLanguage: Equatable {

    /// ISO code as Natural Language reports it: `vi`, `en`, `zh-Hant`, `pa-Guru`.
    /// Codes may carry a region, so callers matching on language alone trim at the
    /// first hyphen.
    let code: String

    /// How sure the detector is, from 0 to 1. ``TranscribeSpokenOrderUseCase``
    /// refuses anything below its threshold rather than guessing.
    let confidence: Double

    /// The language written out for the staff, for example "Vietnamese".
    var displayName: String {
        Locale.current.localizedString(forLanguageCode: code) ?? code
    }

    init(code: String, confidence: Double) {
        self.code = code
        self.confidence = confidence
    }
}

/// What a customer said, in their words and in the staff's.
///
/// Both wordings are kept on purpose. The staff work from ``staffText``, but when an
/// order has to be checked with the customer it is ``spokenText`` that gets shown —
/// their own sentence, not a translation of a translation.
struct SpokenOrderTranscript: Equatable {

    /// The words as the customer said them, in their own language.
    let spokenText: String

    /// The same words in the language the staff work in, English for now.
    /// Identical to ``spokenText`` when no translation was needed.
    let staffText: String

    /// The language the customer spoke, and how sure the app is about it.
    let detectedLanguage: DetectedLanguage

    /// How clearly the speech was heard, from 0 to 1. Kept separate from the
    /// language confidence: hearing the words clearly and placing the language are
    /// two different things to be unsure about.
    let recognitionConfidence: Double

    /// `false` when the customer already spoke the staff's language, so the screen
    /// does not show the same sentence twice.
    let wasTranslated: Bool
}
