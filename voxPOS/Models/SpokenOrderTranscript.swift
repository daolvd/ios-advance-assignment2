//
//  SpokenOrderTranscript.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation

struct DetectedLanguage: Equatable {

    // ISO code such as vi,end,zh-Hant
    let code: String

    // from 0 to 1.
    let confidence: Double

    var displayName: String {
        Locale.current.localizedString(forLanguageCode: code) ?? code
    }

    init(code: String, confidence: Double) {
        self.code = code
        self.confidence = confidence
    }
}

struct SpokenOrderTranscript: Equatable {

    let spokenText: String

    // default in english
    let staffText: String

    // The language the customer spoke.
    let detectedLanguage: DetectedLanguage

    //How clearly the speech was heard, from 0 to 1.
    let recognitionConfidence: Double

    //`false` when the customer already spoke the staff's language.
    let wasTranslated: Bool
}
