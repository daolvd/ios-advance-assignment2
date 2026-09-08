//
//  Staff.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//
import Foundation

/// The person working the till, and the shift they are working.
///
/// One staff member holds the till at a time. Storing them is what makes takings
/// attributable at the end of the day, and it is deliberately kept on the device:
/// a crash or a relaunch mid-queue must not sign someone out and lose that link.
///
/// `Codable`, because the whole record is written to storage as one value when the
/// shift opens and read back when the app starts.
class Staff : Identifiable, Codable {

    var id: String = UUID().uuidString

    /// The name this person is known by on the floor, shown on the till header.
    /// Not a login: nobody is authenticated, they are identified.
    var displayName: String = ""

    /// The shift being worked, such as `AM-12`. Written by the staff member, and
    /// what a manager reconciles the day's orders against.
    var shiftCode: String = ""

    /// When this shift began, so its length can be shown or reported later.
    var shiftStartedAt: Date = Date()

    init(
        id: String = UUID().uuidString,
        displayName: String,
        shiftCode: String,
        shiftStartedAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.shiftCode = shiftCode
        self.shiftStartedAt = shiftStartedAt
    }
}
