//
//  LocalStaffRepository.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation


class LocalStaffRepository : StaffRepository {

    private let sessionKey = "voxPOS.currentShiftStaff"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func saveSession(staff: Staff) -> Bool {
        guard let data = try? JSONEncoder().encode(staff) else {
            return false
        }

        defaults.set(data, forKey: sessionKey)
        return true
    }

    func loadSession() -> Staff? {
        guard let data = defaults.data(forKey: sessionKey) else {
            return nil
        }

        return try? JSONDecoder().decode(Staff.self, from: data)
    }

    func clearSession() {
        defaults.removeObject(forKey: sessionKey)
    }
}
