//
//  Staff.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//
import Foundation

class Staff : Identifiable, Codable {
    var id: String = UUID().uuidString
    var displayName: String = ""
    var shiftCode: String = ""
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
