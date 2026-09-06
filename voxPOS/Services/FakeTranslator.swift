//
//  FakeTranslator.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation

/// Stands in for Apple's Translation framework until it is wired up.
///
/// It knows the canned orders ``FakeSpeechTranscriber`` produces. Anything else
/// comes back unchanged, so the screen still works while the phrase list grows.
struct FakeTranslator: TextTranslating {

    private static let englishFor = [
        "Cho tôi hai burger gà, một cái không phô mai":
            "Two chicken burgers, one without cheese",
        "Dos hamburguesas con queso y un helado de vainilla":
            "Two cheeseburgers and a vanilla sundae",
        "Cho tôi một ly trà sữa trân châu":
            "One bubble milk tea please"
    ]

    /// Pretend the language pack has not been downloaded yet.
    var isUnavailable = false

    struct TranslationUnavailable: Error {}

    func translate(
        _ text: String,
        from sourceLanguageCode: String,
        to targetLanguageCode: String
    ) async throws -> String {
        guard !isUnavailable else {
            throw TranslationUnavailable()
        }

        // A real translation round trip is not instant, so neither is this one.
        try await Task.sleep(for: .milliseconds(400))

        return Self.englishFor[text] ?? text
    }
}
