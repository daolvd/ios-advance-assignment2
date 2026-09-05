//
//  NaturalLanguageDetector.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation
import NaturalLanguage

// Detects the customer's language on device with Apple's Natural Language framework.
struct NaturalLanguageDetector: LanguageDetecting {

    func detectLanguage(of text: String) -> DetectedLanguage? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)

        guard let language = recognizer.dominantLanguage else {
            return nil
        }
        
        let confidence = recognizer.languageHypotheses(withMaximum: 1)[language] ?? 0

        return DetectedLanguage(code: language.rawValue, confidence: confidence)
    }
}
