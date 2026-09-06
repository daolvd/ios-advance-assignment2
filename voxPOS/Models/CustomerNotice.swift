//
//  CustomerNotice.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import Foundation

/// A short line the staff can turn the screen around and show the customer.
///
/// The wording lives in `Resources/CustomerNotices.json`, so a sentence can be
/// corrected or a language added without touching code. These are read by customers
/// at the moment an order has already gone wrong, so they are written by a person
/// rather than run through the translator.
enum CustomerNotice: String {

    /// Nothing the customer asked for is sold here.
    case notOnTheMenu

    /// The words could not be made out.
    case couldNotHear

    /// The line in the customer's language, falling back to English.
    func text(in languageCode: String) -> String {
        // Detection returns codes like "zh-Hans", and the file is keyed by language.
        let language = languageCode.split(separator: "-").first.map(String.init) ?? languageCode
        let lines = Self.book[rawValue] ?? [:]

        return lines[language] ?? lines["en"] ?? ""
    }

    private static let book: [String: [String: String]] = {
        guard
            let url = Bundle.main.url(forResource: "CustomerNotices", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            return [:]
        }

        return (try? JSONDecoder().decode([String: [String: String]].self, from: data)) ?? [:]
    }()
}
