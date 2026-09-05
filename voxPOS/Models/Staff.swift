//
//  Staff.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//
import Foundation

class Staff : Identifiable {
    var id: String = UUID().uuidString
    var displayName: String = ""
    var shiftCode: String = ""
}
