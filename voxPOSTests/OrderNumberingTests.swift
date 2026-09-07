//
//  OrderNumberingTests.swift
//  voxPOSTests
//
//  Created by Van Dao Le on 6/9/2026.
//
//  White box, path coverage of OrderNumbering.
//
//  N1  nothing stored yet          -> the series starts at 0
//  N2  a number stored in range    -> that number is next
//  N3  a number stored out of range-> the series restarts rather than shouting junk
//  N4  take                        -> hands out the number and moves on
//  N5  take at the top of series   -> wraps back to 0
//
//  Each test runs against its own defaults suite, so the app's real numbering is
//  never touched and the tests never see each other's state.
//

import Testing
import Foundation
@testable import voxPOS

struct OrderNumberingTests {

    private func makeDefaults() -> UserDefaults {
        let suite = "voxPOSTests.numbering.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)

        return defaults
    }

    // MARK: N1, N2 — reading without spending

    @Test func peek_startsTheSeriesAtZero_onAFreshTill() {
        #expect(OrderNumbering.peek(in: makeDefaults()) == 0)
    }

    @Test func peek_doesNotUseTheNumberUp() {
        let defaults = makeDefaults()

        // The home screen reads this on every appearance; reading must not burn a
        // number, or the counter would skip one each time nobody ordered.
        #expect(OrderNumbering.peek(in: defaults) == 0)
        #expect(OrderNumbering.peek(in: defaults) == 0)
        #expect(OrderNumbering.peek(in: defaults) == 0)
    }

    // MARK: N4 — spending

    @Test func take_handsOutTheNumberAndMovesTheSeriesOn() {
        let defaults = makeDefaults()

        #expect(OrderNumbering.take(in: defaults) == 0)
        #expect(OrderNumbering.take(in: defaults) == 1)
        #expect(OrderNumbering.peek(in: defaults) == 2, "the home screen agrees with the till")
    }

    // MARK: N5 — boundary, the top of the series

    @Test func take_wrapsBackToZero_afterTheLastNumberInTheSeries() {
        let defaults = makeDefaults()
        defaults.set(999, forKey: "voxPOS.nextOrderNumber")

        // Numbers are called across a room, so a fourth digit is worse than a repeat.
        #expect(OrderNumbering.take(in: defaults) == 999)
        #expect(OrderNumbering.peek(in: defaults) == 0)
    }

    // MARK: N3 — stored value outside the series

    @Test func peek_restartsTheSeries_whenTheStoredNumberIsOutOfRange() {
        let defaults = makeDefaults()
        defaults.set(4321, forKey: "voxPOS.nextOrderNumber")

        #expect(OrderNumbering.peek(in: defaults) == 0)
    }
}
