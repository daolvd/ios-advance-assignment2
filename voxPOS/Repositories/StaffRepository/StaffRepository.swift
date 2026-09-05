//
//  StaffRepository.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation

protocol StaffRepository {
    func getStaff(username:String) -> Staff?
    func login(with username: String, password: String) -> Staff?
    func createStaff(staff: Staff) -> Bool
}
