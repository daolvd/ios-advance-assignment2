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
    static let samples = [
        "Cho tôi hai burger gà, một cái không phô mai",
        "One iced tea please, no sugar",
        "Dos cafés con leche por favor"
    ]

    /// Shortest believable listen, so the Stop button cannot fire before the animation shows.
    private let minimumListeningTime: Duration = .milliseconds(600)

    /// How long to keep listening if nobody taps Stop.
    private let maximumListeningTime: Duration = .seconds(4)

    private let lock = NSLock()
    private var stopRequested = false
    private var nextSampleIndex = 0

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
        lock.lock()
        defer { lock.unlock() }

        let sample = Self.samples[nextSampleIndex % Self.samples.count]
        nextSampleIndex += 1

        return sample
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
