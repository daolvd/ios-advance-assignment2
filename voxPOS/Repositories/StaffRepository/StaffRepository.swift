//
//  StaffRepository.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation


protocol StaffRepository {


    func saveSession(staff: Staff) -> Bool

    func loadSession() -> Staff?

    func clearSession()
}
