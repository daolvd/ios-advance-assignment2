//
//  OrderNumbering.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import Foundation

/// Hands out the number an order is called by across the counter.
///
/// Numbers run 0 to 999 and then start again. They are for calling out, not for
/// telling orders apart — `Order.orderID` does that — so a number coming round
/// again after a thousand orders is fine, while a four digit number shouted over a
/// busy room is not.
///
/// Reading the next number and spending it are separate on purpose: the home screen
/// shows what the next order will be called, and must not use the number up by
/// looking at it.
enum OrderNumbering {

    private static let key = "voxPOS.nextOrderNumber"
    private static let series = 0...999

    /// The number the next order will be given, without spending it.
    static func peek(in defaults: UserDefaults = .standard) -> Int {
        let stored = defaults.integer(forKey: key)

        return series.contains(stored) ? stored : series.lowerBound
    }

    /// Takes the next number and moves the series on.
    static func take(in defaults: UserDefaults = .standard) -> Int {
        let number = peek(in: defaults)

        defaults.set((number + 1) % (series.upperBound + 1), forKey: key)

        return number
    }
}
