//
//  SpeechServices.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation

/// One pass of listening to a customer.
struct SpeechTranscription: Equatable {

    /// The words that were heard.
    let text: String

    /// How clearly they were heard, from 0 to 1.
    let confidence: Double
}

/// Listens to the customer and returns what they said.
///
/// The adapter owns the microphone, the audio session and permissions;
/// the use case only asks for the finished transcript.
protocol SpeechTranscribing {

    /// Listens until the customer stops talking or ``stopListening()`` is called.
    func transcribe() async throws -> SpeechTranscription

    /// Ends listening early and returns whatever has been heard so far.
    func stopListening()
}

/// Works out which language a piece of text is written in.
protocol LanguageDetecting {
    func detectLanguage(of text: String) -> DetectedLanguage?
}

/// Translates text between two languages.
protocol TextTranslating {
    func translate(
        _ text: String,
        from sourceLanguageCode: String,
        to targetLanguageCode: String
    ) async throws -> String
}
