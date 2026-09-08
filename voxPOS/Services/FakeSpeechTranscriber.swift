//
//  FakeSpeechTranscriber.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation

/// Stands in for the microphone until the Speech framework is wired up.
///
/// It waits like a real recogniser would, then hands back one of a few canned
/// orders, cycling through them so each listen exercises a different language.
class FakeSpeechTranscriber: SpeechTranscribing, @unchecked Sendable {

    /// The orders this stand-in knows how to "hear".
    /// Four orders, each landing on a different screen state: a plain order, an
    /// option the kitchen cannot make, an order in English that needs no translating,
    /// and an order of nothing the till sells — in a language the staff cannot read,
    /// which is the case the customer-facing notice exists for.
    static let samples = [
        "Cho tôi hai burger gà, một cái không phô mai",
        "One coke with no ice and a large fries please",
        "Dos hamburguesas con queso y un helado de vainilla",
        "Cho tôi một ly trà sữa trân châu"
    ]

    /// Shortest believable listen, so the Stop button cannot fire before the animation shows.
    private let minimumListeningTime: Duration = .milliseconds(600)

    /// How long to keep listening if nobody taps Stop.
    private let maximumListeningTime: Duration = .seconds(4)

    private let lock = NSLock()
    private var stopRequested = false

    /// Which order gets "heard" next.
    ///
    /// Random by default, so working through the app keeps landing on a different
    /// case. A test must not be left guessing which order it got, so it fixes this
    /// to one sample and asserts against that.
    var chooseSample: @Sendable ([String]) -> String = { $0.randomElement() ?? "" }

    init() {}

    /// A transcriber that always hears the same thing, for tests.
    init(alwaysSaying sentence: String) {
        chooseSample = { _ in sentence }
    }

    /// Set to return an empty transcript, to try the "we didn't catch that" path.
    var hearsNothing = false

    func transcribe() async throws -> SpeechTranscription {
        // Cleared at the end, not the start: a Stop that lands before this task is
        // scheduled must still be honoured rather than swallowed.
        defer { setStopRequested(false) }

        try await Task.sleep(for: minimumListeningTime)

        // Poll in small steps so Stop is felt straight away.
        let step = Duration.milliseconds(100)
        let steps = maximumListeningTime / step

        for _ in 0..<Int(steps) {
            if isStopRequested { break }
            try await Task.sleep(for: step)
        }

        guard !hearsNothing else {
            return SpeechTranscription(text: "", confidence: 0)
        }

        return SpeechTranscription(text: nextSample(), confidence: 0.86)
    }

    func stopListening() {
        setStopRequested(true)
    }

    private func nextSample() -> String {
        chooseSample(Self.samples)
    }

    private var isStopRequested: Bool {
        lock.lock()
        defer { lock.unlock() }

        return stopRequested
    }

    private func setStopRequested(_ value: Bool) {
        lock.lock()
        defer { lock.unlock() }

        stopRequested = value
    }
}
